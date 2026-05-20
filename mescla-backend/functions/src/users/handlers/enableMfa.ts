// Autor: Gabriel Padreca Nicoletti
// RA: 20013009

import { HttpsError, onCall } from "firebase-functions/v2/https";
import { Timestamp } from "firebase-admin/firestore";

import { requireAuthenticatedUser } from "../../shared/auth";
import { usersCollection } from "../repositories/usersRepository";
import { verifyAndConsumeMfaChallenge } from "../repositories/mfaRepository";

// Confirmação pra ativar o MFA. Antes de chamar, o front precisa ter chamado
// sendMfaCodeByEmail e pedido pro usuário digitar o código que chegou no e-mail.
export const enableMfa = onCall(async (request) => {
  try {
    const user = requireAuthenticatedUser(request);
    const { code } = request.data;

    if (!code || typeof code !== "string") {
      throw new HttpsError("invalid-argument", "Campo code é obrigatório.");
    }

    const isValid = await verifyAndConsumeMfaChallenge(user.uid, code.trim());

    if (!isValid) {
      throw new HttpsError("invalid-argument", "Código inválido ou expirado.");
    }

    await usersCollection.doc(user.uid).update({
      mfaEnabled: true,
      updatedAt: Timestamp.now(),
    });

    return {
      message: "MFA ativado com sucesso.",
    };
  } catch (error) {
    if (error instanceof HttpsError) {
      throw error;
    }

    console.error("Erro ao ativar MFA:", error);
    throw new HttpsError("internal", "Erro ao ativar MFA.");
  }
});
