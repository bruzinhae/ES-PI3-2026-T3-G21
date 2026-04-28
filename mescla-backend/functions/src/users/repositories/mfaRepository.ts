// Autor: Gabriel Padreca Nicoletti
// RA: 20013009

import { createHash, randomInt } from "crypto";
import { Timestamp } from "firebase-admin/firestore";

import { usersCollection } from "./usersRepository";

const MFA_CODE_LENGTH = 6;
const MFA_CODE_TTL_MINUTES = 10;
const ACTIVE_CHALLENGE_DOC_ID = "active";

type MfaChallengeDocument = {
  codeHash: string;
  expiresAt: Timestamp;
  createdAt: Timestamp;
};

function challengeRef(uid: string) {
  return usersCollection
    .doc(uid)
    .collection("mfaChallenges")
    .doc(ACTIVE_CHALLENGE_DOC_ID);
}

function hashMfaCode(code: string): string {
  return createHash("sha256").update(code).digest("hex");
}

export function generateMfaCode(): string {
  const max = 10 ** MFA_CODE_LENGTH;
  return randomInt(0, max).toString().padStart(MFA_CODE_LENGTH, "0");
}

export async function saveActiveMfaChallenge(
  uid: string,
  code: string
): Promise<void> {
  const now = Timestamp.now();
  const expiresAt = Timestamp.fromMillis(
    now.toMillis() + MFA_CODE_TTL_MINUTES * 60 * 1000
  );

  const challenge: MfaChallengeDocument = {
    codeHash: hashMfaCode(code),
    expiresAt,
    createdAt: now,
  };

  await challengeRef(uid).set(challenge);
}

export async function verifyAndConsumeMfaChallenge(
  uid: string,
  code: string
): Promise<boolean> {
  const ref = challengeRef(uid);
  const snapshot = await ref.get();

  if (!snapshot.exists) {
    return false;
  }

  const challenge = snapshot.data() as MfaChallengeDocument;
  const now = Timestamp.now();

  if (challenge.expiresAt.toMillis() < now.toMillis()) {
    await ref.delete();
    return false;
  }

  if (challenge.codeHash !== hashMfaCode(code)) {
    return false;
  }

  await ref.delete();
  return true;
}
