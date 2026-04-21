import {
  UserDocument,
  UserListItem
} from '../types/usersTypes';

import { 
  db,
} from "../../shared/firebase";

import { HttpsError } from 'firebase-functions/https';

export const usersCollection = db.collection("users");


export async function getUserByUid(uid: string): Promise<UserDocument> {
  try{
  const userRef = await usersCollection.doc(uid).get();

  if (!userRef.exists) {
    console.error("User não encontrado");
    throw new HttpsError("not-found", "Usuário não encontrado!");
  }

    return userRef.data() as UserDocument;
  }
  
  catch(error){
  console.error("Error fetching user by UID: ", error);
  throw new HttpsError("internal", "Erro ao buscar usuário por UID."); 
}

}

//verifica se o email já existe no banco de dados. 

export async function verifyEmailExists(email: string): Promise<boolean> {
  try{
      const emailLowerCase = email.toLowerCase();
      const emailExists = await usersCollection.where("emailLowerCase", "==", emailLowerCase).limit(1).get();

      return !emailExists.empty;
    }
    catch(error){
    console.error("Error verifying email existence: ", error);
    throw new Error("Erro ao verificar existência de email.");
  }
}

function tolistUsers(id: string, startup: Partial<UserDocument>): UserListItem {
  return {
    uid: id,
    name: startup.name ?? "",
    email: startup.email ?? "",
    cpf: startup.cpf ?? "",
    telefone: startup.telefone ?? "",
    mfaEnabled: startup.mfaEnabled ?? false,
    isAdmin: startup.isAdmin ?? false,
  };
}

export async function listUsersItens() : Promise<UserListItem[]> {

  const users = await usersCollection.limit(100).get();
  return users.docs.map((doc : any) => tolistUsers(doc.id, doc.data() as UserDocument));

} 