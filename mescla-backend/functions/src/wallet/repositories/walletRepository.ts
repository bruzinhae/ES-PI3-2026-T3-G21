// Autor: Gabriel Padreca Nicoletti
// RA: 20013009

import { FieldValue, Timestamp } from "firebase-admin/firestore";

import {
  getUserByUid,
  usersCollection,
} from "../../users/repositories/usersRepository";

export async function getUserBalanceCents(uid: string): Promise<number> {
  const user = await getUserByUid(uid);
  return user.balanceCents ?? 0;
}

export async function incrementUserBalanceCents(
  uid: string,
  amountCents: number
): Promise<number> {
  await usersCollection.doc(uid).update({
    balanceCents: FieldValue.increment(amountCents),
    updatedAt: Timestamp.now(),
  });

  const updated = await getUserByUid(uid);
  return updated.balanceCents;
}
