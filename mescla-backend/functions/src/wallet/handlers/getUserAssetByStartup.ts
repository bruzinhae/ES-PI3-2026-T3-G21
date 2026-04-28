// Autor: Gabriel Padreca Nicoletti
// RA: 20013009

import { HttpsError, onCall } from "firebase-functions/v2/https";

import { requireAuthenticatedUser } from "../../shared/auth";
import { fetchUserAsset } from "../repositories/assetsRepository";
import { UserAssetView } from "../types/assetsTypes";

export const getUserAssetByStartup = onCall(async (request) => {
  try {
    const user = requireAuthenticatedUser(request);
    const { startupId } = request.data;

    if (!startupId || typeof startupId !== "string") {
      throw new HttpsError("invalid-argument", "Campo startupId é obrigatório.");
    }

    const asset = await fetchUserAsset(user.uid, startupId.trim());

    if (!asset) {
      throw new HttpsError("not-found", "Você não possui ativos dessa startup.");
    }

    const data: UserAssetView = {
      startupId: asset.startupId,
      startupName: asset.startupName,
      coverImageUrl: asset.coverImageUrl,
      quantity: asset.quantity,
      averagePriceCents: asset.averagePriceCents,
      lastUpdatedAt: asset.lastUpdatedAt?.toDate?.()?.toISOString?.() ?? null,
    };

    return { data };
  } catch (error) {
    if (error instanceof HttpsError) {
      throw error;
    }

    console.error("Erro ao buscar ativo do usuário:", error);
    throw new HttpsError("internal", "Erro ao buscar ativo do usuário.");
  }
});
