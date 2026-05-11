//Nome: Mateus Souza Marinho
//RA: 24005497

import { HttpsError, onCall } from "firebase-functions/https";
import { requireAuthenticatedUser } from "../../shared/auth";
import { normalizeString } from "../shared/validation";

import {
  getStartupById,
  listPublicQuestions,
  userIsInvestor,
} from "../repositories/startupsRepository";

export const getStartupDetails = onCall(async (request) => {
  
  requireAuthenticatedUser(request);
  const startupId = normalizeString(request.data?.startupId);

  if (!startupId) {
    throw new HttpsError(
      "invalid-argument",
      "Informe o parametro id da startup."
    );
  }

  const startup = await getStartupById(startupId);

  if (!startup) {
    throw new HttpsError(
      "not-found",
      "Startup nao encontrada."
    );
  }

  const uid = request.auth?.uid;

  const isInvestor = uid? await userIsInvestor(startupId, uid): false;

  const questions = await listPublicQuestions(startupId);

return {
    data: {
      id: startupId,

      ...startup,

      createdAt: startup.createdAt
        ? new Date(
            ((startup.createdAt as any)._seconds ??
              (startup.createdAt as any).seconds) * 1000
          ).toISOString()
        : null,

      updatedAt: startup.updatedAt
        ? new Date(
            ((startup.updatedAt as any)._seconds ??
              (startup.updatedAt as any).seconds) * 1000
          ).toISOString()
        : null,

      publicQuestions: questions,

      access: {
        isInvestor: isInvestor,
        canTradeTokens: isInvestor,
        canSendPrivateQuestions: isInvestor,
      },
    },
  };
});