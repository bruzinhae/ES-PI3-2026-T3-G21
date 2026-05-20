// Autor: Gabriel Padreca Nicoletti
// RA: 20013009

import { HttpsError, onCall } from "firebase-functions/v2/https";
import { Timestamp } from "firebase-admin/firestore";

import { requireAuthenticatedUser } from "../../shared/auth";
import { usersCollection } from "../repositories/usersRepository";

// Desativa MFA pro usuário logado.
// Front só precisa garantir que o usuário tá autenticado.
export const disableMfa = onCall(async (request) => {
  try {
    const user = requireAuthenticatedUser(request);

    await usersCollection.doc(user.uid).update({
      mfaEnabled: false,
      updatedAt: Timestamp.now(),
    });

    return {
      message: "MFA desativado com sucesso.",
    };
  } catch (error) {
    if (error instanceof HttpsError) {
      throw error;
    }

    console.error("Erro ao desativar MFA:", error);
    throw new HttpsError("internal", "Erro ao desativar MFA.");
  }
});
