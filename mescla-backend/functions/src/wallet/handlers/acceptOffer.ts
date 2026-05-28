// Autor: Gabriel Padreca Nicoletti
// RA: 20013009

import {FieldValue, Timestamp} from "firebase-admin/firestore";
import {HttpsError, onCall} from "firebase-functions/v2/https";

import {requireAuthenticatedUser} from "../../shared/auth";
import {db} from "../../shared/firebase";
import {startupsCollection} from "../../startups/repositories/startupsRepository";
import {usersCollection} from "../../users/repositories/usersRepository";
import {UserDocument} from "../../users/types/usersTypes";
import {
  buildUserAsset,
  calculateAveragePriceCents,
  deleteUserAssetInTransaction,
  fetchUserAssetInTransaction,
  saveUserAssetInTransaction,
} from "../repositories/assetsRepository";
import {
  saveTokenTransactionInTransaction,
  toTokenTransactionView,
} from "../repositories/transactionsRepository";
import {TokenTransactionDocument} from "../types/transactionTypes";

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
}

const requireOfferId = (value: unknown): string => {
  if (typeof value !== "string" || !value.trim()) {
    throw new HttpsError("invalid-argument", "Campo offerId é obrigatório.");
  }

  return value.trim();
};

export const acceptOffer = onCall(async (request) => {
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

      if (offer.status !== "open") {
        throw new HttpsError(
          "failed-precondition",
          "Esta oferta não está mais disponível.",
        );
      }

      if (offer.creatorUid === user.uid) {
        throw new HttpsError(
          "failed-precondition",
          "Você não pode aceitar sua própria oferta.",
        );
      }

      const startupRef = startupsCollection.doc(offer.startupId);
      const creatorRef = usersCollection.doc(offer.creatorUid);
      const acceptorRef = usersCollection.doc(user.uid);
      const [startupSnap, creatorSnap, acceptorSnap] = await Promise.all([
        transaction.get(startupRef),
        transaction.get(creatorRef),
        transaction.get(acceptorRef),
      ]);

      if (!startupSnap.exists) {
        throw new HttpsError("not-found", "Startup não encontrada.");
      }

      if (!creatorSnap.exists) {
        throw new HttpsError("not-found", "Criador da oferta não encontrado.");
      }

      if (!acceptorSnap.exists) {
        throw new HttpsError("not-found", "Usuário não encontrado.");
      }

      const acceptor = acceptorSnap.data() as UserDocument;
      const now = Timestamp.now();
      let tokenTransaction: TokenTransactionDocument;
      let counterpartyUid = offer.creatorUid;
      let acceptorBalanceCents = acceptor.balanceCents ?? 0;

      if (offer.type === "sell") {
        const acceptorAsset = await fetchUserAssetInTransaction(
          transaction,
          user.uid,
          offer.startupId,
        );

        const acceptorBalance = acceptor.balanceCents ?? 0;

        if (acceptorBalance < offer.totalCents) {
          throw new HttpsError(
            "failed-precondition",
            `Saldo insuficiente. Necessário R$ ${(
              offer.totalCents / 100
            ).toFixed(2)}.`,
          );
        }

        const currentQty = acceptorAsset?.quantity ?? 0;
        const currentAvg = acceptorAsset?.averagePriceCents ?? offer.priceCents;
        const newAvg = calculateAveragePriceCents({
          currentQuantity: currentQty,
          currentAveragePriceCents: currentAvg,
          addedQuantity: offer.quantity,
          addedPriceCents: offer.priceCents,
        });
        const nextQty = currentQty + offer.quantity;
        const acceptorAssetData = buildUserAsset({
          startupId: offer.startupId,
          startupName: offer.startupName,
          coverImageUrl: offer.coverImageUrl ?? undefined,
          quantity: nextQty,
          averagePriceCents: newAvg,
          now,
        });

        transaction.update(acceptorRef, {
          balanceCents: FieldValue.increment(-offer.totalCents),
          updatedAt: now,
        });
        transaction.update(creatorRef, {
          balanceCents: FieldValue.increment(offer.totalCents),
          updatedAt: now,
        });
        saveUserAssetInTransaction(transaction, user.uid, acceptorAssetData);
        transaction.set(
          startupRef.collection("investors").doc(user.uid),
          {
            uid: user.uid,
            email: user.email ?? null,
            startupId: offer.startupId,
            startupName: offer.startupName,
            quantity: nextQty,
            updatedAt: now,
          },
          {merge: true},
        );

        acceptorBalanceCents = acceptorBalance - offer.totalCents;
        tokenTransaction = {
          type: "buy",
          startupId: offer.startupId,
          startupName: offer.startupName,
          buyerUid: user.uid,
          sellerUid: offer.creatorUid,
          actorUid: user.uid,
          quantity: offer.quantity,
          priceCents: offer.priceCents,
          totalCents: offer.totalCents,
          createdAt: now,
        };
      } else {
        const [acceptorAsset, creatorAsset] = await Promise.all([
          fetchUserAssetInTransaction(transaction, user.uid, offer.startupId),
          fetchUserAssetInTransaction(
            transaction,
            offer.creatorUid,
            offer.startupId,
          ),
        ]);

        if (!acceptorAsset || acceptorAsset.quantity < offer.quantity) {
          throw new HttpsError(
            "failed-precondition",
            `Tokens insuficientes. Você possui ${
              acceptorAsset?.quantity ?? 0
            }, a oferta exige ${offer.quantity}.`,
          );
        }

        const remainingAcceptorQty = acceptorAsset.quantity - offer.quantity;

        if (remainingAcceptorQty === 0) {
          deleteUserAssetInTransaction(transaction, user.uid, offer.startupId);
          transaction.delete(startupRef.collection("investors").doc(user.uid));
        } else {
          saveUserAssetInTransaction(transaction, user.uid, {
            ...acceptorAsset,
            quantity: remainingAcceptorQty,
            lastUpdatedAt: now,
          });
          transaction.set(
            startupRef.collection("investors").doc(user.uid),
            {quantity: remainingAcceptorQty, updatedAt: now},
            {merge: true},
          );
        }

        transaction.update(acceptorRef, {
          balanceCents: FieldValue.increment(offer.totalCents),
          updatedAt: now,
        });

        const currentCreatorQty = creatorAsset?.quantity ?? 0;
        const currentCreatorAvg =
          creatorAsset?.averagePriceCents ?? offer.priceCents;
        const newCreatorAvg = calculateAveragePriceCents({
          currentQuantity: currentCreatorQty,
          currentAveragePriceCents: currentCreatorAvg,
          addedQuantity: offer.quantity,
          addedPriceCents: offer.priceCents,
        });
        const nextCreatorQty = currentCreatorQty + offer.quantity;
        const creatorAssetData = buildUserAsset({
          startupId: offer.startupId,
          startupName: offer.startupName,
          coverImageUrl: offer.coverImageUrl ?? null,
          quantity: nextCreatorQty,
          averagePriceCents: newCreatorAvg,
          now,
        });

        saveUserAssetInTransaction(
          transaction,
          offer.creatorUid,
          creatorAssetData,
        );
        transaction.set(
          startupRef.collection("investors").doc(offer.creatorUid),
          {
            uid: offer.creatorUid,
            startupId: offer.startupId,
            startupName: offer.startupName,
            quantity: nextCreatorQty,
            updatedAt: now,
          },
          {merge: true},
        );

        acceptorBalanceCents = (acceptor.balanceCents ?? 0) + offer.totalCents;
        tokenTransaction = {
          type: "sell",
          startupId: offer.startupId,
          startupName: offer.startupName,
          buyerUid: offer.creatorUid,
          sellerUid: user.uid,
          actorUid: user.uid,
          quantity: offer.quantity,
          priceCents: offer.priceCents,
          totalCents: offer.totalCents,
          createdAt: now,
        };
      }

      const transactionId = saveTokenTransactionInTransaction(
        transaction,
        user.uid,
        offer.startupId,
        tokenTransaction,
      );

      transaction.set(
        usersCollection
          .doc(counterpartyUid)
          .collection("transactions")
          .doc(transactionId),
        tokenTransaction,
      );
      transaction.update(offerRef, {
        status: "accepted",
        acceptedBy: user.uid,
        acceptedAt: now,
        transactionId,
        updatedAt: now,
      });

      return {
        offerId,
        transaction: toTokenTransactionView(transactionId, tokenTransaction),
        acceptorBalanceCents,
      };
    });

    return {data: result};
  } catch (error) {
    if (error instanceof HttpsError) {
      throw error;
    }

    console.error("Erro ao aceitar oferta:", error);
    throw new HttpsError("internal", "Erro ao aceitar oferta.");
  }
});
