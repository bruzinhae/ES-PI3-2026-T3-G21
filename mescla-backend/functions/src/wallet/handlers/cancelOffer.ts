// Autor: Gabriel Padreca Nicoletti
// RA: 20013009

import {FieldValue, Timestamp} from "firebase-admin/firestore";
import {HttpsError, onCall} from "firebase-functions/v2/https";

import {requireAuthenticatedUser} from "../../shared/auth";
import {db} from "../../shared/firebase";
import {startupsCollection} from "../../startups/repositories/startupsRepository";
import {usersCollection} from "../../users/repositories/usersRepository";
import {
  buildUserAsset,
  calculateAveragePriceCents,
  fetchUserAssetInTransaction,
  saveUserAssetInTransaction,
} from "../repositories/assetsRepository";

interface OfferDocument {
  type: "buy" | "sell";
  status: "open" | "accepted" | "cancelled";
  startupId: string;
  startupName: string;
  coverImageUrl?: string | null;
  creatorUid: string;
  priceCents: number;
  quantity: number;
  totalCents: number;
  reservedAveragePriceCents?: number;
}

const requireOfferId = (value: unknown): string => {
  if (typeof value !== "string" || !value.trim()) {
    throw new HttpsError("invalid-argument", "Campo offerId é obrigatório.");
  }

  return value.trim();
};

const getReservedAveragePriceCents = (offer: OfferDocument): number => {
  if (
    typeof offer.reservedAveragePriceCents === "number" &&
    Number.isInteger(offer.reservedAveragePriceCents) &&
    offer.reservedAveragePriceCents > 0
  ) {
    return offer.reservedAveragePriceCents;
  }

  return offer.priceCents;
};

export const cancelOffer = onCall(async (request) => {
  try {
    const user = requireAuthenticatedUser(request);
    const offerId = requireOfferId(request.data?.offerId);

    const result = await db.runTransaction(async (transaction) => {
      const offerRef = db.collection("offers").doc(offerId);
      const offerSnap = await transaction.get(offerRef);

      if (!offerSnap.exists) {
        throw new HttpsError("not-found", "Oferta não encontrada.");
      }

      const offer = offerSnap.data() as OfferDocument;

      if (offer.creatorUid !== user.uid) {
        throw new HttpsError(
          "permission-denied",
          "Somente o criador pode cancelar esta oferta.",
        );
      }

      if (offer.status !== "open") {
        throw new HttpsError(
          "failed-precondition",
          "Apenas ofertas abertas podem ser canceladas.",
        );
      }

      const now = Timestamp.now();
      const creatorRef = usersCollection.doc(user.uid);
      const creatorSnap = await transaction.get(creatorRef);

      if (!creatorSnap.exists) {
        throw new HttpsError("not-found", "Usuário criador não encontrado.");
      }

      if (offer.type === "buy") {
        transaction.update(creatorRef, {
          balanceCents: FieldValue.increment(offer.totalCents),
          updatedAt: now,
        });
      } else {
        const startupRef = startupsCollection.doc(offer.startupId);
        const currentAsset = await fetchUserAssetInTransaction(
          transaction,
          user.uid,
          offer.startupId,
        );
        const currentQuantity = currentAsset?.quantity ?? 0;
        const currentAveragePriceCents =
          currentAsset?.averagePriceCents ?? getReservedAveragePriceCents(offer);
        const restoredAveragePriceCents = calculateAveragePriceCents({
          currentQuantity,
          currentAveragePriceCents,
          addedQuantity: offer.quantity,
          addedPriceCents: getReservedAveragePriceCents(offer),
        });
        const restoredQuantity = currentQuantity + offer.quantity;
        const asset = buildUserAsset({
          startupId: offer.startupId,
          startupName: offer.startupName,
          coverImageUrl: offer.coverImageUrl ?? undefined,
          quantity: restoredQuantity,
          averagePriceCents: restoredAveragePriceCents,
          now,
        });

        saveUserAssetInTransaction(transaction, user.uid, asset);
        transaction.set(
          startupRef.collection("investors").doc(user.uid),
          {
            uid: user.uid,
            email: user.email ?? null,
            startupId: offer.startupId,
            startupName: offer.startupName,
            quantity: restoredQuantity,
            updatedAt: now,
          },
          {merge: true},
        );
      }

      transaction.update(offerRef, {
        status: "cancelled",
        cancelledBy: user.uid,
        cancelledAt: now,
        updatedAt: now,
      });

      return {
        offerId,
        status: "cancelled",
      };
    });

    return {data: result};
  } catch (error) {
    if (error instanceof HttpsError) {
      throw error;
    }

    console.error("Erro ao cancelar oferta:", error);
    throw new HttpsError("internal", "Erro ao cancelar oferta.");
  }
});
