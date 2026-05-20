// Autor: Gabriel Padreca Nicoletti
// RA: 20013009

import {Timestamp, Transaction} from "firebase-admin/firestore";

import {usersCollection} from "../../users/repositories/usersRepository";
import {UserAssetDocument} from "../types/assetsTypes";

const userAssetsCollection = (uid: string) => {
  return usersCollection.doc(uid).collection("assets");
};

export const userAssetReference = (uid: string, startupId: string) => {
  return userAssetsCollection(uid).doc(startupId);
};

export const fetchUserAssets = async (
  uid: string,
): Promise<UserAssetDocument[]> => {
  const snapshot = await userAssetsCollection(uid).get();
  return snapshot.docs.map((doc) => doc.data() as UserAssetDocument);
};

export const fetchUserAsset = async (
  uid: string,
  startupId: string,
): Promise<UserAssetDocument | undefined> => {
  const snapshot = await userAssetsCollection(uid).doc(startupId).get();

  if (!snapshot.exists) {
    return undefined;
  }

  return snapshot.data() as UserAssetDocument;
};

export const fetchUserAssetInTransaction = async (
  transaction: Transaction,
  uid: string,
  startupId: string,
): Promise<UserAssetDocument | undefined> => {
  const snapshot = await transaction.get(userAssetReference(uid, startupId));

  if (!snapshot.exists) {
    return undefined;
  }

  return snapshot.data() as UserAssetDocument;
};

export const saveUserAssetInTransaction = (
  transaction: Transaction,
  uid: string,
  asset: UserAssetDocument,
): void => {
  transaction.set(
    userAssetReference(uid, asset.startupId),
    asset,
    {merge: true},
  );
};

export const deleteUserAssetInTransaction = (
  transaction: Transaction,
  uid: string,
  startupId: string,
): void => {
  transaction.delete(userAssetReference(uid, startupId));
};

export const buildUserAsset = (params: {
  startupId: string;
  startupName: string;
  coverImageUrl?: string;
  quantity: number;
  averagePriceCents: number;
  now: Timestamp;
}): UserAssetDocument => {
  return {
    startupId: params.startupId,
    startupName: params.startupName,
    coverImageUrl: params.coverImageUrl,
    quantity: params.quantity,
    averagePriceCents: params.averagePriceCents,
    lastUpdatedAt: params.now,
  };
};

export const calculateAveragePriceCents = (params: {
  currentQuantity: number;
  currentAveragePriceCents: number;
  addedQuantity: number;
  addedPriceCents: number;
}): number => {
  const nextQuantity = params.currentQuantity + params.addedQuantity;

  if (nextQuantity <= 0) {
    return 0;
  }

  const currentTotal =
    params.currentQuantity * params.currentAveragePriceCents;
  const addedTotal = params.addedQuantity * params.addedPriceCents;

  return Math.round((currentTotal + addedTotal) / nextQuantity);
};
