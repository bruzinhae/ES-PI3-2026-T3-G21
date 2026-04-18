import {
  UserDocument
} from '../types/usersTypes';

import { 
  db
} from "../../shared/firebase";

import { Timestamp } from 'firebase-admin/firestore';

const usersCollection = db.collection("users");

const demoUsers: UserDocument[] = [
  {
    uid: "1",
    name: "Alice",
    email: "email@gmail.com",
    emailLowerCase: "email@gmail.com",
    cpf: "123.456.789-00",
    telefone: "(11) 99999-9999",
    balanceCents: 10000,
    mfaEnabled: false,
    isAdmin: false,
    createdAt: Timestamp.now(),
    updatedAt: Timestamp.now(),
  },
];

export async function getUserByUid(uid: string): Promise<UserDocument | undefined> {

  const userRef = await usersCollection.doc(uid).get();

  if (!userRef.exists) {
    return undefined;
  }

  return userRef.data() as UserDocument;
}
