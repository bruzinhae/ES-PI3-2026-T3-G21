// Autor: Gabriel Padreca Nicoletti
// RA: 20013009

import { HttpsError, onCall } from "firebase-functions/v2/https";

import { requireAuthenticatedUser } from "../../shared/auth";
import { fetchUserAssets } from "../repositories/assetsRepository";
import { getUserBalanceCents } from "../repositories/walletRepository";
import { UserAssetView } from "../types/assetsTypes";

export const getUserWallet = onCall(async (request) => {
  try {
    const user = requireAuthenticatedUser(request);

    const [balanceCents, assets] = await Promise.all([
      getUserBalanceCents(user.uid),
      fetchUserAssets(user.uid),
    ]);

    const assetsView: UserAssetView[] = assets.map((asset) => ({
      startupId: asset.startupId,
      startupName: asset.startupName,
      coverImageUrl: asset.coverImageUrl,
      quantity: asset.quantity,
      averagePriceCents: asset.averagePriceCents,
      lastUpdatedAt: asset.lastUpdatedAt?.toDate?.()?.toISOString?.() ?? null,
    }));

    return {
      data: {
        balanceCents,
        assets: assetsView,
        assetsCount: assetsView.length,
      },
    };
  } catch (error) {
    if (error instanceof HttpsError) {
      throw error;
    }

    console.error("Erro ao buscar carteira do usuário:", error);
    throw new HttpsError("internal", "Erro ao buscar carteira do usuário.");
  }
});
