// Autor: Gabriel Padreca Nicoletti
// RA: 20013009

import { HttpsError, onCall } from "firebase-functions/v2/https";

import { requireAuthenticatedUser } from "../../shared/auth";
import { incrementUserBalanceCents } from "../repositories/walletRepository";

// Recarga simulada de saldo. O documento de visão (seção 5.3) deixa claro que a carteira
// é fictícia, então o usuário pode adicionar qualquer valor pra testar o trading depois.
// Em sistema real isso seria integrado a gateway de pagamento (Pix, cartão, etc).
export const depositToUserWallet = onCall(async (request) => {
  try {
    const user = requireAuthenticatedUser(request);
    const { amountCents } = request.data;

    if (
      typeof amountCents !== "number" ||
      !Number.isInteger(amountCents) ||
      amountCents <= 0
    ) {
      throw new HttpsError(
        "invalid-argument",
        "Campo amountCents deve ser um inteiro positivo (em centavos)."
      );
    }

    const newBalanceCents = await incrementUserBalanceCents(
      user.uid,
      amountCents
    );

    return {
      data: {
        balanceCents: newBalanceCents,
      },
    };
  } catch (error) {
    if (error instanceof HttpsError) {
      throw error;
    }

    console.error("Erro ao depositar saldo:", error);
    throw new HttpsError("internal", "Erro ao depositar saldo.");
  }
});
