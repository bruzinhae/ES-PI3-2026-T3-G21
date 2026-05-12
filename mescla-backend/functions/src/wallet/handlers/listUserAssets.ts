// Autor: Gabriel Padreca Nicoletti
// RA: 20013009

import { HttpsError, onCall } from "firebase-functions/v2/https";

import { requireAuthenticatedUser } from "../../shared/auth";
import { fetchUserAssets } from "../repositories/assetsRepository";
import { UserAssetView } from "../types/assetsTypes";

export const listUserAssets = onCall(async (request) => {
  try {
    const user = requireAuthenticatedUser(request);
    const assets = await fetchUserAssets(user.uid);

    const data: UserAssetView[] = assets.map((asset) => ({
      startupId: asset.startupId,
      startupName: asset.startupName,
      coverImageUrl: asset.coverImageUrl,
      quantity: asset.quantity,
      averagePriceCents: asset.averagePriceCents,
      lastUpdatedAt: asset.lastUpdatedAt?.toDate?.()?.toISOString?.() ?? null,
    }));

    return {
      count: data.length,
      data,
    };
  } catch (error) {
    if (error instanceof HttpsError) {
      throw error;
    }

    console.error("Erro ao listar ativos do usuário:", error);
    throw new HttpsError("internal", "Erro ao listar ativos do usuário.");
  }
});
