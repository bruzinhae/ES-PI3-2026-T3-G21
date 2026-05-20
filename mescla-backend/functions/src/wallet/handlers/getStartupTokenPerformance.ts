// Autor: Gabriel Padreca Nicoletti
// RA: 20013009

import {Timestamp} from "firebase-admin/firestore";
import {HttpsError, onCall} from "firebase-functions/v2/https";

import {requireAuthenticatedUser} from "../../shared/auth";
import {
  startupsCollection,
} from "../../startups/repositories/startupsRepository";
import {StartupDocument} from "../../startups/types/startupTypes";
import {
  availablePerformancePeriods,
  calculatePercentChange,
  getPeriodStart,
  requirePerformancePeriod,
} from "../shared/performancePeriods";
import {requireStartupId} from "../shared/tradingValidation";
import {TokenTransactionDocument} from "../types/transactionTypes";

const timestampToIso = (timestamp: Timestamp): string => {
  return timestamp.toDate().toISOString();
};

export const getStartupTokenPerformance = onCall(async (request) => {
  try {
    requireAuthenticatedUser(request);

    const startupId = requireStartupId(request.data?.startupId);
    const period = requirePerformancePeriod(request.data?.period);
    const startAt = getPeriodStart(period);
    const startupReference = startupsCollection.doc(startupId);
    const startupSnapshot = await startupReference.get();

    if (!startupSnapshot.exists) {
      throw new HttpsError("not-found", "Startup não encontrada.");
    }

    const startup = startupSnapshot.data() as StartupDocument;
    const currentPriceCents = startup.currentTokenPriceCents ?? 0;

    if (currentPriceCents <= 0) {
      throw new HttpsError(
        "failed-precondition",
        "Startup sem preço atual valido para valorizacao.",
      );
    }

    const [beforeSnapshot, periodSnapshot] = await Promise.all([
      startupReference
        .collection("transactions")
        .where("createdAt", "<", startAt)
        .orderBy("createdAt", "desc")
        .limit(1)
        .get(),
      startupReference
        .collection("transactions")
        .where("createdAt", ">=", startAt)
        .orderBy("createdAt", "asc")
        .limit(200)
        .get(),
    ]);

    const transactions = periodSnapshot.docs.map((doc) => {
      return doc.data() as TokenTransactionDocument;
    });
    const previousTransaction = beforeSnapshot.docs[0]?.data() as
      TokenTransactionDocument | undefined;
    const initialPriceCents =
      previousTransaction?.priceCents ??
      transactions[0]?.priceCents ??
      currentPriceCents;
    const volumeCents = transactions.reduce((total, transaction) => {
      return total + transaction.totalCents;
    }, 0);
    const tokenVolume = transactions.reduce((total, transaction) => {
      return total + transaction.quantity;
    }, 0);
    const points = [
      {
        date: timestampToIso(startAt),
        priceCents: initialPriceCents,
        volumeCents: 0,
        quantity: 0,
      },
      ...transactions.map((transaction) => ({
        date: timestampToIso(transaction.createdAt),
        priceCents: transaction.priceCents,
        volumeCents: transaction.totalCents,
        quantity: transaction.quantity,
      })),
    ];

    if (points[points.length - 1].priceCents !== currentPriceCents) {
      points.push({
        date: Timestamp.now().toDate().toISOString(),
        priceCents: currentPriceCents,
        volumeCents: 0,
        quantity: 0,
      });
    }

    return {
      data: {
        startupId,
        startupName: startup.name,
        period,
        availablePeriods: availablePerformancePeriods,
        initialPriceCents,
        currentPriceCents,
        variationCents: currentPriceCents - initialPriceCents,
        variationPercent: calculatePercentChange(
          initialPriceCents,
          currentPriceCents,
        ),
        volumeCents,
        tokenVolume,
        transactionsCount: transactions.length,
        points,
      },
    };
  } catch (error) {
    if (error instanceof HttpsError) {
      throw error;
    }

    console.error("Erro ao buscar valorizacao da startup:", error);
    throw new HttpsError(
      "internal",
      "Erro ao buscar valorizacao da startup.",
    );
  }
});
