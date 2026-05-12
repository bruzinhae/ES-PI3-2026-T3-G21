// Autor: Gabriel Padreca Nicoletti
// RA: 20013009

import { HttpsError, onCall } from "firebase-functions/v2/https";

import { requireAuthenticatedUser } from "../../shared/auth";
import { verifyAndConsumeMfaChallenge } from "../repositories/mfaRepository";

// Valida o código no fluxo de login com MFA. Front faz signInWithEmailAndPassword,
// chama getMe, se mfaEnabled for true mostra a tela de código, dispara sendMfaCodeByEmail
// e chama esse aqui com o código que o usuário digitou. Se voltar ok, libera a navegação.
// Se não, mantém o usuário na tela do código.
export const verifyMfaLoginCode = onCall(async (request) => {
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

    return {
      message: "Código verificado com sucesso.",
    };
  } catch (error) {
    if (error instanceof HttpsError) {
      throw error;
    }

    console.error("Erro ao verificar código MFA:", error);
    throw new HttpsError("internal", "Erro ao verificar código.");
  }
});
