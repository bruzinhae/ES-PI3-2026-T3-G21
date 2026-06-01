/*
Nome: Mateus Souza Marinho
RA: 24005497
*/

import {
  UserDocument,
  UserListItem
} from '../types/usersTypes';

import { 
  db,
  auth
} from "../../shared/firebase";

import {validateEmail} from "../shared/validation";

import { HttpsError } from 'firebase-functions/https';
import { sendVerificationEmail } from '../shared/sendVerificationEmail';

import{
  UpdatableField
} from "../types/usersTypes";

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

//! FUNÇÃO QUE VAI ATUALIZAR QUALQUER CAMPO DO USUARIO(EXCETO O BALANCE), recebe o id do usuario e o nome do campo que quer mudar e a informação nova

export async function updateField(
  uid: string,
  field: UpdatableField,
  data: unknown
): Promise<void> {

  const ALLOWED_FIELDS: readonly UpdatableField[] = ["name", "phone", "cpf", "telefone"];

  if (!ALLOWED_FIELDS.includes(field)) {
    throw new HttpsError("invalid-argument", `Campo '${field}' não pode ser atualizado.`);
  }

  try {
    const user = usersCollection.doc(uid);
    const userSnap = await user.get();
    if (!userSnap.exists) {
      throw new HttpsError("invalid-argument", "Usuario não encontrado");
    }
    await user.update({
      [field]: data,
      updatedAt: new Date()
    });
  }
  catch (error) {
    if (error instanceof HttpsError) throw error;
    console.error("Error updating user field: ", error);
    throw new HttpsError("internal", "Erro ao atualizar campo do usuário.", error);
  }
}

export async function updateEmail(uid : string, newEmail: string){
  
  if(!validateEmail(newEmail)) {
    throw new HttpsError("invalid-argument", "Email inválido!");
  }

  const user = usersCollection.doc(uid);
  const userSnap = await user.get();
  
  if(!userSnap.exists){
    throw new HttpsError("invalid-argument", "Usuario não encontrado");
  }
  
  await auth.updateUser(uid, {
    email : newEmail,
  })

  await user.update({
    email : newEmail,
    emailLowerCase : newEmail.toLowerCase()

  })
  
  await sendVerificationEmail(newEmail); //fazer a mesma verificação da criação de usuário

  return {
    message : "Email alterado com sucesso"
  }
}
//criar autenticação de admin ou aqui ou n front 