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

export const buyTokens = onCall(async (request) => {
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
      const buyerReference = usersCollection.doc(user.uid);
      const sellerReference = usersCollection.doc(TRADING_COUNTERPARTY_UID);

      const [startupSnapshot, buyerSnapshot, sellerSnapshot] =
        await Promise.all([
          transaction.get(startupReference),
          transaction.get(buyerReference),
          transaction.get(sellerReference),
        ]);

      if (!startupSnapshot.exists) {
        throw new HttpsError("not-found", "Startup não encontrada.");
      }

      if (!buyerSnapshot.exists) {
        throw new HttpsError(
          "not-found",
          "Usuário comprador não encontrado.",
        );
      }

      if (!sellerSnapshot.exists) {
        throw new HttpsError(
          "failed-precondition",
          "Usuário de liquidez não configurado.",
        );
      }

      const startup = startupSnapshot.data() as StartupDocument;
      const buyer = buyerSnapshot.data() as UserDocument;
      const priceCents = requireTokenPrice(startup.currentTokenPriceCents);
      const totalCents = calculateTradeTotalCents(quantity, priceCents);
      const buyerBalanceCents = buyer.balanceCents ?? 0;

      if (buyerBalanceCents < totalCents) {
        throw new HttpsError(
          "failed-precondition",
          "Saldo insuficiente para comprar tokens.",
        );
      }

      const [buyerAsset, sellerAsset] = await Promise.all([
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
          "Tokens insuficientes disponíveis no balcão.",
        );
      }

      const now = Timestamp.now();
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
      const sellerRemainingQuantity = sellerAsset.quantity - quantity;

      transaction.update(buyerReference, {
        balanceCents: FieldValue.increment(-totalCents),
        updatedAt: now,
      });
      transaction.update(sellerReference, {
        balanceCents: FieldValue.increment(totalCents),
        updatedAt: now,
      });

      saveUserAssetInTransaction(transaction, user.uid, buyerAssetData);

      if (sellerRemainingQuantity === 0) {
        deleteUserAssetInTransaction(
          transaction,
          TRADING_COUNTERPARTY_UID,
          startupId,
        );
      } else {
        const sellerAssetData: UserAssetDocument = {
          ...sellerAsset,
          startupName: startup.name,
          coverImageUrl: startup.coverImageUrl,
          quantity: sellerRemainingQuantity,
          lastUpdatedAt: now,
        };

        saveUserAssetInTransaction(
          transaction,
          TRADING_COUNTERPARTY_UID,
          sellerAssetData,
        );
      }

      transaction.set(
        startupReference.collection("investors").doc(user.uid),
        {
          uid: user.uid,
          email: user.email ?? null,
          startupId,
          startupName: startup.name,
          quantity: nextBuyerQuantity,
          updatedAt: now,
        },
        {merge: true},
      );

      const tokenTransaction: TokenTransactionDocument = {
        type: "buy",
        startupId,
        startupName: startup.name,
        buyerUid: user.uid,
        sellerUid: TRADING_COUNTERPARTY_UID,
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
        balanceCents: buyerBalanceCents - totalCents,
        asset: {
          ...buyerAssetData,
          lastUpdatedAt: buyerAssetData.lastUpdatedAt.toDate().toISOString(),
        },
        transaction: toTokenTransactionView(transactionId, tokenTransaction),
      };
    });

    return {data: result};
  } catch (error) {
    if (error instanceof HttpsError) {
      throw error;
    }

    console.error("Erro ao comprar tokens:", error);
    throw new HttpsError("internal", "Erro ao comprar tokens.");
  }
});
