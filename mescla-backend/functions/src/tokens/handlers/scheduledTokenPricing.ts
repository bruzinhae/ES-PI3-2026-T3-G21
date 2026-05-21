// Nome: Mateus Souza Marinho
// RA: 24005497

import { onSchedule } from 'firebase-functions/v2/scheduler';
import { startupsCollection } from '../../startups/repositories/startupsRepository';
import { saveTokenSnapshot, updateTokenPriceTx } from '../repositories/tokensRepository';
import { db } from '../../shared/firebase';

export const scheduledTokenPricing = onSchedule('every 1 hours', async () => {
  const startups = await startupsCollection.get();

  for (const startup of startups.docs) {
    const startupId = startup.id;
    const currentPrice: number = startup.data().currentTokenPriceCents ?? 100;

    const desde = new Date(Date.now() - 24 * 60 * 60 * 1000);

    const transactions = await db.collection('transactions')
      .where('startupId', '==', startupId)
      .where('criadoEm', '>=', desde)
      .get();

    if (transactions.empty) {
      await saveTokenSnapshot(startupId, currentPrice);
      continue;
    }

    let somaPrecoVolume = 0;
    let somaVolume = 0;

    transactions.forEach((doc) => {
      const t = doc.data();
      somaPrecoVolume += t.precoCents * t.quantity;
      somaVolume += t.quantity;
    });

    const newPriceCents = Math.round(somaPrecoVolume / somaVolume);

    await db.runTransaction(async (t) => {
      updateTokenPriceTx(t, startupId, newPriceCents);
    });

    await saveTokenSnapshot(startupId, newPriceCents);
  }
});