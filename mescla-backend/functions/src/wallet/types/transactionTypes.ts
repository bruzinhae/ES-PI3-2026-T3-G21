// Autor: Gabriel Padreca Nicoletti
// RA: 20013009

import {Timestamp} from "firebase-admin/firestore";

export type TokenTransactionType = "buy" | "sell";

export type TokenTransactionDocument = {
  type: TokenTransactionType;
  startupId: string;
  startupName: string;
  buyerUid: string;
  sellerUid: string;
  actorUid: string;
  quantity: number;
  priceCents: number;
  totalCents: number;
  createdAt: Timestamp;
};

export type TokenTransactionView = {
  id: string;
  type: TokenTransactionType;
  startupId: string;
  startupName: string;
  buyerUid: string;
  sellerUid: string;
  actorUid: string;
  quantity: number;
  priceCents: number;
  totalCents: number;
  createdAt: string | null;
};
