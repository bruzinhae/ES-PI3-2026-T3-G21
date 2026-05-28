// Autor: Gabriel Padreca Nicoletti
// RA: 20013009

import { Timestamp } from "firebase-admin/firestore";

export type UserAssetDocument = {
  startupId: string;
  startupName: string;
  coverImageUrl?: string | null;
  quantity: number;
  averagePriceCents: number;
  lastUpdatedAt: Timestamp;
};

export type UserAssetView = {
  startupId: string;
  startupName: string;
  coverImageUrl?: string | null;
  quantity: number;
  averagePriceCents: number;
  lastUpdatedAt: string | null;
};
