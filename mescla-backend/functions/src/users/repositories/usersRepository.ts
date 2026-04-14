
import { db } from "../../shared/firebase";

const usersCollection = db.collection("users");

type CreateUserDocumentInput = {
  uid: string;
  name: string;
  email: string;
  cpf: string;
  telefone: string;
};

export async function createUserDocument(data: CreateUserDocumentInput) {
  await usersCollection.doc(data.uid).set({
    uid: data.uid,
    name: data.name,
    email: data.email,
    emailLowerCase: data.email.toLowerCase(),
    cpf: data.cpf,
    telefone: data.telefone,
    dataCriacao: new Date().toISOString(),
    adfHablitada: false,
  });
}