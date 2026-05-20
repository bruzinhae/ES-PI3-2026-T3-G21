// Nome: Mateus Souza Marinho
// RA: 24005497

import { startupsCollection } from '../../startups/repositories/startupsRepository';
import { TokenSnapshotDocument } from '../types/types';

export function updateTokenPriceTx(
  t: FirebaseFirestore.Transaction,
  startupId: string,
  newPriceCents: number
): void {
  const ref = startupsCollection.doc(startupId);
  t.update(ref, {
    currentTokenPriceCents: newPriceCents,
    updatedAt: new Date(),
  });
}

export async function saveTokenSnapshot(
  startupId: string,
  priceCents: number
): Promise<void> {
  await startupsCollection
    .doc(startupId)
    .collection('token_prices')
    .add({
      priceCents,
      criadoEm: new Date(),
    } as TokenSnapshotDocument);
}

export async function getTokenPriceHistory(
  startupId: string,
  desde: Date
): Promise<TokenSnapshotDocument[]> {
  const snapshot = await startupsCollection
    .doc(startupId)
    .collection('token_prices')
    .where('criadoEm', '>=', desde)
    .orderBy('criadoEm', 'asc')
    .get();

  return snapshot.docs.map((doc) => doc.data() as TokenSnapshotDocument);
}