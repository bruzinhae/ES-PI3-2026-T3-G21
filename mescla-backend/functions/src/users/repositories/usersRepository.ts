import {
  UserDocument
} from '../types/usersTypes';

import { 
  db
} from "../../shared/firebase";



const usersCollection = db.collection("users");

export async function getUserByUid(uid: string): Promise<UserDocument | undefined> {

  const userRef = await usersCollection.doc(uid).get();

  if (!userRef.exists) {
    return undefined;
  }

  return userRef.data() as UserDocument;
}
