// Nome: Mateus Souza Marinho
// RA: 24005497

import { onCall, HttpsError } from 'firebase-functions/v2/https';
import { requireAuthenticatedUser } from '../../shared/auth';
import { getTokenPriceHistory } from '../repositories/tokensRepository';
import { TokenPriceHistoryResponse } from '../types/types';

const periodosEmMs: Record<string, number> = {
  diario:   1  * 24 * 60 * 60 * 1000,
  semanal:  7  * 24 * 60 * 60 * 1000,
  mensal:   30 * 24 * 60 * 60 * 1000,
  semestral:180 * 24 * 60 * 60 * 1000,
  ytd:      0,
};

export const getTokenPriceHistoryHandler = onCall(async (request) => {
  try {
    requireAuthenticatedUser(request);

    const { startupId, periodo } = request.data;

    if (!startupId || !periodo) {
      throw new HttpsError('invalid-argument', 'startupId e periodo são obrigatórios.');
    }

    if (!(periodo in periodosEmMs)) {
      throw new HttpsError('invalid-argument', 'Periodo inválido. Use: diario, semanal, mensal, semestral ou ytd.');
    }

    let desde: Date;

    if (periodo === 'ytd') {
      const agora = new Date();
      desde = new Date(agora.getFullYear(), 0, 1);
    } else {
      desde = new Date(Date.now() - periodosEmMs[periodo]);
    }

    const history = await getTokenPriceHistory(startupId, desde);

    // calculo da variação
    let variacaoPercent = 0;
    if (history.length >= 2) {
      const precoInicial = history[0].priceCents;
      const precoFinal = history[history.length - 1].priceCents;
      variacaoPercent = ((precoFinal - precoInicial) / precoInicial) * 100;
}

    const response: TokenPriceHistoryResponse = {
      startupId,
      variacaoPercent: parseFloat(variacaoPercent.toFixed(2)), // ex: +3.47 ou -1.20
      history: history.map((snapshot) => ({
        priceCents: snapshot.priceCents,
        criadoEm: snapshot.criadoEm instanceof Date
          ? snapshot.criadoEm.toISOString()
          : new Date((snapshot.criadoEm as any)._seconds * 1000).toISOString(),
      })),
    };

    return response;

  } catch (e) {
    if (e instanceof HttpsError) throw e;
    throw new HttpsError('internal', 'Erro ao buscar histórico de preços.');
  }
});