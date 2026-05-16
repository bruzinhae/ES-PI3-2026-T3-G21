// Autor: Alinne Monteiro de Melo
// RA: 24801649

import { HttpsError, onCall } from "firebase-functions/v2/https";
import { requireAuthenticatedUser } from "../../shared/auth";
import { fetchUserAsset } from "../repositories/assetsRepository";
import { TRADING_COUNTERPARTY_UID } from "../shared/tradingValidation";

export const listStartupOffers = onCall(async (request) => {
  try {
    requireAuthenticatedUser(request);

    const { startupId } = request.data;

    if (!startupId || typeof startupId !== "string") {
      throw new HttpsError(
        "invalid-argument",
        "Campo startupId é obrigatório."
      );
    }

    // busca os tokens disponíveis do market maker pra essa startup
    const asset = await fetchUserAsset(TRADING_COUNTERPARTY_UID, startupId);

    if (!asset) {
      return {
        data: {
          startupId,
          availableQuantity: 0,
          priceCents: 0,
          offers: [],
        },
      };
    }

    return {
      data: {
        startupId,
        availableQuantity: asset.quantity,
        priceCents: asset.averagePriceCents,
        // formatação como lista de ofertas
        offers: [
          {
            quantity: asset.quantity,
            priceCents: asset.averagePriceCents,
            totalCents: asset.quantity * asset.averagePriceCents,
          },
        ],
      },
    };
  } catch (error) {
    if (error instanceof HttpsError) throw error;
    console.error("Erro ao listar ofertas:", error);
    throw new HttpsError("internal", "Erro ao listar ofertas.");
  }
});