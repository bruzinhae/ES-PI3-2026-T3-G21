// Autor: Gabriel Padreca Nicoletti
// RA: 20013009

import { usersCollection } from "../../users/repositories/usersRepository";
import { UserAssetDocument } from "../types/assetsTypes";

function userAssetsCollection(uid: string) {
  return usersCollection.doc(uid).collection("assets");
}

export async function fetchUserAssets(uid: string): Promise<UserAssetDocument[]> {
  const snapshot = await userAssetsCollection(uid).get();
  return snapshot.docs.map((doc) => doc.data() as UserAssetDocument);
}

export async function fetchUserAsset(
  uid: string,
  startupId: string
): Promise<UserAssetDocument | undefined> {
  const snapshot = await userAssetsCollection(uid).doc(startupId).get();

  if (!snapshot.exists) {
    return undefined;
  }

  return snapshot.data() as UserAssetDocument;
}
