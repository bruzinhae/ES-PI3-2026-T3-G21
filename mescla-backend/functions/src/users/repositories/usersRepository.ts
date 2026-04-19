import {
  UserDocument
} from '../types/usersTypes';

import { 
  db
} from "../../shared/firebase";

import { 
  Timestamp
} from 'firebase-admin/firestore';
import { https } from 'firebase-functions';

export const usersCollection = db.collection("users");

export const demoUsers: UserDocument[] = [
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
  {
    uid: "2",
    name: "Bob",
    email: "bob@gmail.com",
    emailLowerCase: "bob@gmail.com",
    cpf: "987.654.321-00",
    telefone: "(11) 88888-8888",
    balanceCents: 15000,
    mfaEnabled: true,
    isAdmin: false,
    createdAt: Timestamp.now(),
    updatedAt: Timestamp.now(),
  },
  {
    uid: "3",
    name: "Charlie",
    email: "charlie@gmail.com",
    emailLowerCase: "charlie@gmail.com",
    cpf: "456.789.123-00",
    telefone: "(11) 77777-7777",
    balanceCents: 20000,
    mfaEnabled: false,
    isAdmin: false,
    createdAt: Timestamp.now(),
    updatedAt: Timestamp.now(),

  },
];

export async function getUserByUid(uid: string): Promise<UserDocument> {
  try{
  const userRef = await usersCollection.doc(uid).get();

  if (!userRef.exists) {
    console.error("User não encontrado");
    throw new https.HttpsError("not-found", "Usuário não encontrado!");
  }

    return userRef.data() as UserDocument;
  }
  
  catch(error){
  console.error("Error fetching user by UID: ", error);
  throw new Error("Erro ao buscar usuário por UID."); 
}

}
