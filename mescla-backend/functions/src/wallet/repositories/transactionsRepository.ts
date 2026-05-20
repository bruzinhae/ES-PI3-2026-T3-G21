// Autor: Gabriel Padreca Nicoletti
// RA: 20013009

import {Timestamp, Transaction} from "firebase-admin/firestore";

import {db} from "../../shared/firebase";
import {
  startupsCollection,
} from "../../startups/repositories/startupsRepository";
import {usersCollection} from "../../users/repositories/usersRepository";
import {
  TokenTransactionDocument,
  TokenTransactionView,
} from "../types/transactionTypes";

export const transactionsCollection = db.collection("transactions");

export const createTokenTransactionReferences = (
  uid: string,
  startupId: string,
) => {
  const transactionReference = transactionsCollection.doc();

  return {
    id: transactionReference.id,
    globalReference: transactionReference,
    userReference: usersCollection
      .doc(uid)
      .collection("transactions")
      .doc(transactionReference.id),
    startupReference: startupsCollection
      .doc(startupId)
      .collection("transactions")
      .doc(transactionReference.id),
  };
};

export const saveTokenTransactionInTransaction = (
  transaction: Transaction,
  uid: string,
  startupId: string,
  document: TokenTransactionDocument,
): string => {
  const references = createTokenTransactionReferences(uid, startupId);

  transaction.set(references.globalReference, document);
  transaction.set(references.userReference, document);
  transaction.set(references.startupReference, document);

  return references.id;
};

export const fetchUserTokenTransactions = async (
  uid: string,
  limit = 50,
): Promise<TokenTransactionView[]> => {
  const snapshot = await usersCollection
    .doc(uid)
    .collection("transactions")
    .orderBy("createdAt", "desc")
    .limit(limit)
    .get();

  return snapshot.docs.map((doc) =>
    toTokenTransactionView(doc.id, doc.data() as TokenTransactionDocument),
  );
};

export const fetchUserTokenTransactionsSince = async (
  uid: string,
  startAt: Timestamp,
  limit = 200,
): Promise<TokenTransactionView[]> => {
  const snapshot = await usersCollection
    .doc(uid)
    .collection("transactions")
    .where("createdAt", ">=", startAt)
    .orderBy("createdAt", "asc")
    .limit(limit)
    .get();

  return snapshot.docs.map((doc) =>
    toTokenTransactionView(doc.id, doc.data() as TokenTransactionDocument),
  );
};

export const toTokenTransactionView = (
  id: string,
  transaction: TokenTransactionDocument,
): TokenTransactionView => {
  return {
    id,
    type: transaction.type,
    startupId: transaction.startupId,
    startupName: transaction.startupName,
    buyerUid: transaction.buyerUid,
    sellerUid: transaction.sellerUid,
    actorUid: transaction.actorUid,
    quantity: transaction.quantity,
    priceCents: transaction.priceCents,
    totalCents: transaction.totalCents,
    createdAt: transaction.createdAt?.toDate?.()?.toISOString?.() ?? null,
  };
};
