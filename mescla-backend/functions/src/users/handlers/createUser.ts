import {
  usersCollection,
} from "../repositories/usersRepository";

import {
  HttpsError,
  onCall,
} from "firebase-functions/v2/https";

import { auth } from "../../shared/firebase";

import { Timestamp } from "firebase-admin/firestore";

import { sendVerificationEmail } from "../shared/sendVerificationEmail";

import { 
    validateCPF,
    validateEmail,
    validateName,
    validatePhone 
} from "../shared/validation";

export const createUser = onCall(async (request) => {
  try {
    const { name, email, cpf, telefone, password } = request.data;

    if (!name || !email || !cpf || !telefone) {
      throw new HttpsError(
        "invalid-argument",
        "Campos obrigatórios: name, email, password, cpf, telefone."
      );
    }

    if (!password || password.length < 6) {
      throw new HttpsError("invalid-argument", "Senha deve ter pelo menos 6 caracteres.");
    }

    if(!validateName(name)){
      throw new HttpsError("invalid-argument", "Nome inválido! Deve conter pelo menos 2 caracteres.");
    }

    if(!validateEmail(email)) {
      throw new HttpsError("invalid-argument", "Email inválido!");
    }
    if(!validatePhone(telefone)) {
      throw new HttpsError("invalid-argument", "Telefone inválido! Deve conter apenas números e ter 10 ou 11 dígitos.");
    } 

    if(!validateCPF(cpf)) {
      throw new HttpsError("invalid-argument", "CPF inválido! Deve conter apenas números e ter 11 dígitos.");
    }

    let userRecord;
    
    try {
      userRecord = await auth.createUser({
        email,
        password,
        displayName: name,
      });

    } catch (emailAlreadyExists: any) {
      if (emailAlreadyExists?.code === "auth/email-already-exists") {
        throw new HttpsError("already-exists", "Email já cadastrado.");
      }
      throw emailAlreadyExists;
    }

    await usersCollection.doc(userRecord.uid).set({
      uid: userRecord.uid,
      name: name,
      email: email,
      emailLowerCase: email.toLowerCase(),
      cpf: cpf,
      telefone: telefone,
      createdAt: Timestamp.now(),
      updatedAt: Timestamp.now(),
      mfaEnabled: false,
      isAdmin: false,
      balanceCents: 0,
    });

    try {
      await sendVerificationEmail(email);
    } catch (emailError) {
      await auth.deleteUser(userRecord.uid);
      await usersCollection.doc(userRecord.uid).delete();

      throw new HttpsError(
        "internal",
        "Erro ao enviar e-mail de verificação. Tente novamente."
      );
    }

    return {
      message: "Usuario criado com sucesso",
      uid: userRecord.uid,
      name: userRecord.displayName,
      email: userRecord.email,
    };
  } catch (error) {
    console.error("Error creating user:", error);

    if (error instanceof HttpsError) {
      throw error;
    }

    throw new HttpsError("internal", "Erro ao criar usuario");
  }
});