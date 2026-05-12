// Autor: Gabriel Padreca Nicoletti
// RA: 20013009

import {FieldValue, Timestamp} from "firebase-admin/firestore";
import {HttpsError, onCall} from "firebase-functions/v2/https";

import {requireAuthenticatedUser} from "../../shared/auth";
import {db} from "../../shared/firebase";
import {
  startupsCollection,
} from "../../startups/repositories/startupsRepository";
import {StartupDocument} from "../../startups/types/startupTypes";
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
import {
  calculateTradeTotalCents,
  requireStartupId,
  requireTokenPrice,
  requireTokenQuantity,
  TRADING_COUNTERPARTY_UID,
} from "../shared/tradingValidation";
import {UserAssetDocument} from "../types/assetsTypes";
import {TokenTransactionDocument} from "../types/transactionTypes";

export const sellTokens = onCall(async (request) => {
  try {
    const user = requireAuthenticatedUser(request);
    const startupId = requireStartupId(request.data?.startupId);
    const quantity = requireTokenQuantity(request.data?.quantity);

    if (user.uid === TRADING_COUNTERPARTY_UID) {
      throw new HttpsError(
        "failed-precondition",
        "Usuário de liquidez não pode negociar pelo aplicativo.",
      );
    }

    const result = await db.runTransaction(async (transaction) => {
      const startupReference = startupsCollection.doc(startupId);
      const sellerReference = usersCollection.doc(user.uid);
      const buyerReference = usersCollection.doc(TRADING_COUNTERPARTY_UID);

      const [startupSnapshot, sellerSnapshot, buyerSnapshot] =
        await Promise.all([
          transaction.get(startupReference),
          transaction.get(sellerReference),
          transaction.get(buyerReference),
        ]);

      if (!startupSnapshot.exists) {
        throw new HttpsError("not-found", "Startup não encontrada.");
      }

      if (!sellerSnapshot.exists) {
        throw new HttpsError(
          "not-found",
          "Usuário vendedor não encontrado.",
        );
      }

      if (!buyerSnapshot.exists) {
        throw new HttpsError(
          "failed-precondition",
          "Usuário de liquidez não configurado.",
        );
      }

      const startup = startupSnapshot.data() as StartupDocument;
      const seller = sellerSnapshot.data() as UserDocument;
      const buyer = buyerSnapshot.data() as UserDocument;
      const priceCents = requireTokenPrice(startup.currentTokenPriceCents);
      const totalCents = calculateTradeTotalCents(quantity, priceCents);
      const buyerBalanceCents = buyer.balanceCents ?? 0;

      if (buyerBalanceCents < totalCents) {
        throw new HttpsError(
          "failed-precondition",
          "Saldo insuficiente no balcão para comprar seus tokens.",
        );
      }

      const [sellerAsset, buyerAsset] = await Promise.all([
        fetchUserAssetInTransaction(transaction, user.uid, startupId),
        fetchUserAssetInTransaction(
          transaction,
          TRADING_COUNTERPARTY_UID,
          startupId,
        ),
      ]);

      if (!sellerAsset || sellerAsset.quantity < quantity) {
        throw new HttpsError(
          "failed-precondition",
          "Você não possui tokens suficientes para vender.",
        );
      }

      const now = Timestamp.now();
      const sellerRemainingQuantity = sellerAsset.quantity - quantity;
      const currentBuyerQuantity = buyerAsset?.quantity ?? 0;
      const currentBuyerAverage = buyerAsset?.averagePriceCents ?? priceCents;
      const nextBuyerQuantity = currentBuyerQuantity + quantity;
      const buyerAveragePriceCents = calculateAveragePriceCents({
        currentQuantity: currentBuyerQuantity,
        currentAveragePriceCents: currentBuyerAverage,
        addedQuantity: quantity,
        addedPriceCents: priceCents,
      });
      const buyerAssetData = buildUserAsset({
        startupId,
        startupName: startup.name,
        coverImageUrl: startup.coverImageUrl,
        quantity: nextBuyerQuantity,
        averagePriceCents: buyerAveragePriceCents,
        now,
      });

      transaction.update(sellerReference, {
        balanceCents: FieldValue.increment(totalCents),
        updatedAt: now,
      });
      transaction.update(buyerReference, {
        balanceCents: FieldValue.increment(-totalCents),
        updatedAt: now,
      });

      saveUserAssetInTransaction(
        transaction,
        TRADING_COUNTERPARTY_UID,
        buyerAssetData,
      );

      let sellerAssetData: UserAssetDocument | null = null;

      if (sellerRemainingQuantity === 0) {
        deleteUserAssetInTransaction(transaction, user.uid, startupId);
        transaction.delete(
          startupReference.collection("investors").doc(user.uid),
        );
      } else {
        sellerAssetData = {
          ...sellerAsset,
          startupName: startup.name,
          coverImageUrl: startup.coverImageUrl,
          quantity: sellerRemainingQuantity,
          lastUpdatedAt: now,
        };

        saveUserAssetInTransaction(transaction, user.uid, sellerAssetData);
        transaction.set(
          startupReference.collection("investors").doc(user.uid),
          {
            uid: user.uid,
            email: user.email ?? null,
            startupId,
            startupName: startup.name,
            quantity: sellerRemainingQuantity,
            updatedAt: now,
          },
          {merge: true},
        );
      }

      const tokenTransaction: TokenTransactionDocument = {
        type: "sell",
        startupId,
        startupName: startup.name,
        buyerUid: TRADING_COUNTERPARTY_UID,
        sellerUid: user.uid,
        actorUid: user.uid,
        quantity,
        priceCents,
        totalCents,
        createdAt: now,
      };
      const transactionId = saveTokenTransactionInTransaction(
        transaction,
        user.uid,
        startupId,
        tokenTransaction,
      );

      return {
        balanceCents: (seller.balanceCents ?? 0) + totalCents,
        asset: sellerAssetData ?
          {
            ...sellerAssetData,
            lastUpdatedAt: sellerAssetData.lastUpdatedAt.toDate().toISOString(),
          } :
          null,
        transaction: toTokenTransactionView(transactionId, tokenTransaction),
      };
    });

    return {data: result};
  } catch (error) {
    if (error instanceof HttpsError) {
      throw error;
    }

    console.error("Erro ao vender tokens:", error);
    throw new HttpsError("internal", "Erro ao vender tokens.");
  }
});
