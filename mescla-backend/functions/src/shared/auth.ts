//A AUTENTICAÇÃO DO USUARIO POR TOKEN

import {CallableRequest, HttpsError} from "firebase-functions/https";

import { AuthenticatedUser } from "./typesAuth";

export function requireAuthenticatedUser(request: CallableRequest): AuthenticatedUser {
    if (!request.auth) {
    throw new HttpsError(
      "unauthenticated",
      "Usuario precisa estar autenticado para acessar esta funcao."
    );
  }

  return {
    uid: request.auth.uid,
    email: request.auth.token.email as string | undefined,
  };
}