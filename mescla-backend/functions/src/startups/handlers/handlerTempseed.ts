// temporario

import { onCall, HttpsError } from 'firebase-functions/v2/https';
import { startupsCollection } from '../repositories/startupsRepository';
import { saveTokenSnapshot } from '../../tokens/repositories/tokensRepository';
import { requireAuthenticatedUser } from '../../shared/auth';
import { getUserByUid } from '../../users/repositories/usersRepository';

export const seedTokenSnapshots = onCall(async (request) => {
  requireAuthenticatedUser(request);

  const uid = request.auth!.uid;
  const user = await getUserByUid(uid);

  if (!user || !user.isAdmin) {
    throw new HttpsError('permission-denied', 'Apenas admins.');
  }

  const startups = await startupsCollection.get();

  for (const doc of startups.docs) {
    const preco = doc.data().currentTokenPriceCents ?? 100;
    await saveTokenSnapshot(doc.id, preco);
  }

  return { message: `${startups.size} snapshots criados.` };
});