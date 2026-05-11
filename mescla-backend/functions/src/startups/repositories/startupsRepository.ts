import {
  StartupDocument,
  StartupListItem,
  StartupQuestionDocument,

} from "../types/startupTypes";

import { db } from "../../shared/firebase";

export const startupsCollection = db.collection("startups");

function toListItem(id: string, startup: Partial<StartupDocument>): StartupListItem {
  return {
    id,
    name: startup.name ?? "",
    stage: startup.stage ?? "nova",
    shortDescription: startup.shortDescription ?? "",
    capitalRaisedCents: startup.capitalRaisedCents ?? 0,
    totalTokensIssued: startup.totalTokensIssued ?? 0,
    currentTokenPriceCents: startup.currentTokenPriceCents ?? 0,
    coverImageUrl: startup.coverImageUrl,
    tags: Array.isArray(startup.tags) ? startup.tags : [],
  };
}

export async function listStartupItems(): Promise<StartupListItem[]> {
  const snapshot = await startupsCollection.limit(100).get();

  return snapshot.docs.map((doc : any) =>
    toListItem(doc.id, doc.data() as StartupDocument)
  );
}

export async function getStartupById(
  startupId: string
): Promise<StartupDocument | undefined> {
  
  const startupSnapshot = await startupsCollection.doc(startupId).get();

  if (!startupSnapshot.exists) {
    return undefined;
  }

  return startupSnapshot.data() as StartupDocument;
}

export async function userIsInvestor(
  startupId: string,
  uid: string
): Promise<boolean> {
  
  if (!startupId || !uid) {
    console.log("INVALID DATA", { startupId, uid });
    return false;
  }

  const investorSnapshot = await startupsCollection.doc(startupId).collection("investors").doc(uid).get();

  return investorSnapshot.exists;
}

export async function listPublicQuestions(startupId: string) {
  const questionsSnapshot = await startupsCollection
    .doc(startupId)
    .collection("questions")
    .where("visibility", "==", "publica")
    .limit(50)
    .get();

  return questionsSnapshot.docs
    .map((doc : any) => ({
      id: doc.id,
      text: doc.get("text"),
      answer: doc.get("answer") ?? null,
      answeredAt: doc.get("answeredAt")?.toDate?.()?.toISOString?.() ?? null,
      createdAt: doc.get("createdAt")?.toDate?.()?.toISOString?.() ?? null,
    }))
    .sort((left, right) =>
      String(right.createdAt ?? "").localeCompare(String(left.createdAt ?? ""))
    );
}

export async function createQuestion(
  startupId: string,
  question: StartupQuestionDocument
): Promise<string> {
  const questionRef = await startupsCollection
    .doc(startupId)
    .collection("questions")
    .add(question);

  return questionRef.id;
}
