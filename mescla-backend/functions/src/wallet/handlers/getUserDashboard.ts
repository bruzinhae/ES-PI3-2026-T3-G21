// Autor: Gabriel Padreca Nicoletti
// RA: 20013009

import {HttpsError, onCall} from "firebase-functions/v2/https";

import {requireAuthenticatedUser} from "../../shared/auth";
import {
  startupsCollection,
} from "../../startups/repositories/startupsRepository";
import {StartupDocument} from "../../startups/types/startupTypes";
import {
  fetchUserAssets,
} from "../repositories/assetsRepository";
import {
  fetchUserTokenTransactions,
  fetchUserTokenTransactionsSince,
} from "../repositories/transactionsRepository";
import {getUserBalanceCents} from "../repositories/walletRepository";
import {
  availablePerformancePeriods,
  calculatePercentChange,
  getPeriodStart,
  requirePerformancePeriod,
} from "../shared/performancePeriods";
import {UserAssetDocument} from "../types/assetsTypes";

const safePriceCents = (
  startup: StartupDocument | undefined,
  asset: UserAssetDocument,
): number => {
  const price = startup?.currentTokenPriceCents ?? 0;

  if (price > 0) {
    return price;
  }

  return asset.averagePriceCents;
};

export const getUserDashboard = onCall(async (request) => {
  try {
    const user = requireAuthenticatedUser(request);
    const period = requirePerformancePeriod(request.data?.period);
    const periodStartAt = getPeriodStart(period);
    const [balanceCents, assets, transactions, periodTransactions] =
      await Promise.all([
      getUserBalanceCents(user.uid),
      fetchUserAssets(user.uid),
      fetchUserTokenTransactions(user.uid, 10),
      fetchUserTokenTransactionsSince(user.uid, periodStartAt),
    ]);
    const startupSnapshots = await Promise.all(
      assets.map((asset) => startupsCollection.doc(asset.startupId).get()),
    );
    const startupsById = new Map<string, StartupDocument>();

    startupSnapshots.forEach((snapshot) => {
      if (snapshot.exists) {
        startupsById.set(snapshot.id, snapshot.data() as StartupDocument);
      }
    });

    const dashboardAssets = assets.map((asset) => {
      const startup = startupsById.get(asset.startupId);
      const currentTokenPriceCents = safePriceCents(startup, asset);
      const investedCents = asset.quantity * asset.averagePriceCents;
      const currentValueCents = asset.quantity * currentTokenPriceCents;

      return {
        startupId: asset.startupId,
        startupName: asset.startupName,
        coverImageUrl: asset.coverImageUrl,
        quantity: asset.quantity,
        averagePriceCents: asset.averagePriceCents,
        currentTokenPriceCents,
        investedCents,
        currentValueCents,
        resultCents: currentValueCents - investedCents,
        resultPercent: calculatePercentChange(
          investedCents,
          currentValueCents,
        ),
        lastUpdatedAt:
          asset.lastUpdatedAt?.toDate?.()?.toISOString?.() ?? null,
      };
    });
    const investedCents = dashboardAssets.reduce((total, asset) => {
      return total + asset.investedCents;
    }, 0);
    const currentPortfolioValueCents = dashboardAssets.reduce(
      (total, asset) => {
        return total + asset.currentValueCents;
      },
      0,
    );
    const periodBoughtCents = periodTransactions
      .filter((transaction) => transaction.type === "buy")
      .reduce((total, transaction) => total + transaction.totalCents, 0);
    const periodSoldCents = periodTransactions
      .filter((transaction) => transaction.type === "sell")
      .reduce((total, transaction) => total + transaction.totalCents, 0);

    return {
      data: {
        balanceCents,
        assetsCount: dashboardAssets.length,
        investedCents,
        currentPortfolioValueCents,
        totalPatrimonyCents: balanceCents + currentPortfolioValueCents,
        resultCents: currentPortfolioValueCents - investedCents,
        resultPercent: calculatePercentChange(
          investedCents,
          currentPortfolioValueCents,
        ),
        period,
        availablePeriods: availablePerformancePeriods,
        periodSummary: {
          startAt: periodStartAt.toDate().toISOString(),
          boughtCents: periodBoughtCents,
          soldCents: periodSoldCents,
          netMovedCents: periodBoughtCents - periodSoldCents,
          transactionsCount: periodTransactions.length,
        },
        assets: dashboardAssets,
        recentTransactions: transactions,
      },
    };
  } catch (error) {
    if (error instanceof HttpsError) {
      throw error;
    }

    console.error("Erro ao buscar dashboard do usuario:", error);
    throw new HttpsError("internal", "Erro ao buscar dashboard do usuario.");
  }
});
