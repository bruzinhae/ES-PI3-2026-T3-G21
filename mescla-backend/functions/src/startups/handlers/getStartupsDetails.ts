import { HttpsError, onCall } from "firebase-functions/https";
import { requireAuthenticatedUser } from "../../shared/auth";
import { normalizeString } from "../shared/validation";
import { getTokenPriceHistory } from '../../tokens/repositories/tokensRepository';

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

  const isInvestor = uid
    ? await userIsInvestor(startupId, uid)
    : false;

  const questions = await listPublicQuestions(startupId);

  // monta documents a partir dos campos já existentes 
  const documents: { title: string; type: string; url: string }[] = [];

  if (startup.executiveSummary) {
    documents.push({
      title: 'Sumário Executivo',
      type: 'pdf',
      url: startup.executiveSummary,
    });
  }

  if (startup.pitchDeckUrl) {
    documents.push({
      title: 'Plano de Negócios',
      type: 'pdf',
      url: startup.pitchDeckUrl,
    });
  }

  if (startup.demoVideos && startup.demoVideos.length > 0) {
    startup.demoVideos.forEach((url, index) => {
      documents.push({
        title: index === 0 ? 'Vídeo Demo' : `Vídeo Demo ${index + 1}`,
        type: 'video',
        url,
      });
    });
  }
  console.log('documents montados:', documents);


  // calcula variação do último dia
  const desde = new Date(Date.now() - 24 * 60 * 60 * 1000);
  const history = await getTokenPriceHistory(startupId, desde);

  let variacaoPercent = 0;
  if (history.length >= 2) {
    const precoInicial = history[0].priceCents;
    const precoFinal = history[history.length - 1].priceCents;
    variacaoPercent = parseFloat(((precoFinal - precoInicial) / precoInicial * 100).toFixed(2));
  }


  return {
    data: {
      id: startupId,

      ...startup,
      variacaoPercent,
      documents,

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