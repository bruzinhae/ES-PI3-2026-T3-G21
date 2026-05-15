// Autor: Gabriel Padreca Nicoletti
// RA: 20013009

import {HttpsError, onCall} from "firebase-functions/v2/https";

import {requireAuthenticatedUser} from "../../shared/auth";
import {
  fetchUserTokenTransactions,
} from "../repositories/transactionsRepository";

export const listUserTransactions = onCall(async (request) => {
  try {
    const user = requireAuthenticatedUser(request);
    const transactions = await fetchUserTokenTransactions(user.uid);

    return {
      count: transactions.length,
      data: transactions,
    };
  } catch (error) {
    if (error instanceof HttpsError) {
      throw error;
    }

    console.error("Erro ao listar transações do usuário:", error);
    throw new HttpsError("internal", "Erro ao listar transações do usuário.");
  }
});
