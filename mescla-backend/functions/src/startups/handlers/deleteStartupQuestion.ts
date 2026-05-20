// Autor: Alinne Monteiro de Melo
// RA: 24801649

import { HttpsError, onCall } from "firebase-functions/https";
import { requireAuthenticatedUser } from "../../shared/auth";
import { normalizeString } from "../shared/validation";
import { db } from "../../shared/firebase";

export const deleteStartupQuestion = onCall(async (request) => {
  const user = requireAuthenticatedUser(request);
  const startupId = normalizeString(request.data?.startupId);
  const questionId = normalizeString(request.data?.questionId);

  if (!startupId || !questionId) {
    throw new HttpsError("invalid-argument", "Informe startupId e questionId.");
  }

  const questionRef = db
    .collection("startups")
    .doc(startupId)
    .collection("questions")
    .doc(questionId);

  const questionSnap = await questionRef.get();

  if (!questionSnap.exists) {
    throw new HttpsError("not-found", "Pergunta não encontrada.");
  }

  const question = questionSnap.data()!;

  // verifica se é o autor ou admin
  const isAuthor = question.authorUid === user.uid;

  const userDoc = await db.collection("users").doc(user.uid).get();
  const isAdmin = userDoc.data()?.role === "admin";

  if (!isAuthor && !isAdmin) {
    throw new HttpsError("permission-denied", "Sem permissão para excluir esta pergunta.");
  }

  await questionRef.delete();

  return { data: { deleted: true, questionId } };
});