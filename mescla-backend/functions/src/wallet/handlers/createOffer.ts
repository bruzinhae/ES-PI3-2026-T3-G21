// Autor: Gabriel Padreca Nicoletti
// RA: 20013009

import {FieldValue, Timestamp} from "firebase-admin/firestore";
import {HttpsError, onCall} from "firebase-functions/v2/https";

import {requireAuthenticatedUser} from "../../shared/auth";
import {db} from "../../shared/firebase";
import {startupsCollection} from "../../startups/repositories/startupsRepository";
import {StartupDocument} from "../../startups/types/startupTypes";
import {usersCollection} from "../../users/repositories/usersRepository";
import {UserDocument} from "../../users/types/usersTypes";
import {fetchUserAssetInTransaction} from "../repositories/assetsRepository";
import {
  calculateTradeTotalCents,
  requireStartupId,
  requireTokenPrice,
  requireTokenQuantity,
} from "../shared/tradingValidation";

type OfferType = "buy" | "sell";

const requireOfferType = (value: unknown): OfferType => {
  if (value !== "buy" && value !== "sell") {
    throw new HttpsError(
      "invalid-argument",
      "Campo type deve ser 'buy' ou 'sell'.",
    );
  }

  return value;
};

const requireOfferPriceCents = (value: unknown): number => {
  if (
    typeof value !== "number" ||
    !Number.isInteger(value) ||
    !Number.isSafeInteger(value) ||
    value <= 0
  ) {
    throw new HttpsError(
      "invalid-argument",
      "Campo priceCents deve ser um inteiro positivo.",
    );
  }

  return value;
};

export const createOffer = onCall(async (request) => {
  try {
    const user = requireAuthenticatedUser(request);
    const type = requireOfferType(request.data?.type);
    const startupId = requireStartupId(request.data?.startupId);
    const quantity = requireTokenQuantity(request.data?.quantity);
    const priceCents = requireOfferPriceCents(request.data?.priceCents);
    const totalCents = calculateTradeTotalCents(quantity, priceCents);

    const result = await db.runTransaction(async (transaction) => {
      const startupRef = startupsCollection.doc(startupId);
      const creatorRef = usersCollection.doc(user.uid);
      const [startupSnap, creatorSnap] = await Promise.all([
        transaction.get(startupRef),
        transaction.get(creatorRef),
      ]);

      if (!startupSnap.exists) {
        throw new HttpsError("not-found", "Startup não encontrada.");
      }

      if (!creatorSnap.exists) {
        throw new HttpsError("not-found", "Usuário não encontrado.");
      }

      const startup = startupSnap.data() as StartupDocument;
      const creator = creatorSnap.data() as UserDocument;

      requireTokenPrice(startup.currentTokenPriceCents);

      const now = Timestamp.now();
      const offerRef = db.collection("offers").doc();
      let reservedAveragePriceCents: number | null = null;

      if (type === "sell") {
        const creatorAsset = await fetchUserAssetInTransaction(
          transaction,
          user.uid,
          startupId,
        );

        if (!creatorAsset || creatorAsset.quantity < quantity) {
          throw new HttpsError(
            "failed-precondition",
            `Tokens insuficientes. Você possui ${
              creatorAsset?.quantity ?? 0
            }, tentou ofertar ${quantity}.`,
          );
        }

        reservedAveragePriceCents = creatorAsset.averagePriceCents;
        const remainingQuantity = creatorAsset.quantity - quantity;

        if (remainingQuantity === 0) {
          transaction.delete(
            usersCollection.doc(user.uid).collection("assets").doc(startupId),
          );
          transaction.delete(startupRef.collection("investors").doc(user.uid));
        } else {
          transaction.update(
            usersCollection.doc(user.uid).collection("assets").doc(startupId),
            {quantity: remainingQuantity, lastUpdatedAt: now},
          );
          transaction.set(
            startupRef.collection("investors").doc(user.uid),
            {quantity: remainingQuantity, updatedAt: now},
            {merge: true},
          );
        }
      } else {
        const creatorBalance = creator.balanceCents ?? 0;

        if (creatorBalance < totalCents) {
          throw new HttpsError(
            "failed-precondition",
            `Saldo insuficiente. Necessário R$ ${(
              totalCents / 100
            ).toFixed(2)}, disponível R$ ${(creatorBalance / 100).toFixed(2)}.`,
          );
        }

        transaction.update(creatorRef, {
          balanceCents: FieldValue.increment(-totalCents),
          updatedAt: now,
        });
      }

      transaction.set(offerRef, {
        type,
        status: "open",
        startupId,
        startupName: startup.name,
        coverImageUrl: startup.coverImageUrl ?? null,
        creatorUid: user.uid,
        priceCents,
        quantity,
        totalCents,
        createdAt: now,
        updatedAt: now,
        acceptedBy: null,
        acceptedAt: null,
        cancelledBy: null,
        cancelledAt: null,
        transactionId: null,
        reservedAveragePriceCents,
      });

      return {
        offerId: offerRef.id,
        type,
        startupId,
        quantity,
        priceCents,
        totalCents,
      };
    });

    return {data: result};
  } catch (error) {
    if (error instanceof HttpsError) {
      throw error;
    }

    console.error("Erro ao criar oferta:", error);
    throw new HttpsError("internal", "Erro ao criar oferta.");
  }
});
