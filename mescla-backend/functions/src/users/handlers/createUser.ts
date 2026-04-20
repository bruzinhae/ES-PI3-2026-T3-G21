import {
  usersCollection,
  sendVerificationEmail,
  verifyEmailExists,
} from "../repositories/usersRepository";

import {
  HttpsError,
  onCall,
} from "firebase-functions/v2/https";

import { auth } from "../../shared/firebase";
import { Timestamp } from "firebase-admin/firestore";

export const createUser = onCall(async (request) => {
  try {
    const { name, email, password, cpf, telefone } = request.data;

    if (!name || !email || !password || !cpf || !telefone) {
      throw new HttpsError(
        "invalid-argument",
        "Campos obrigatórios: name, email, password, cpf, telefone."
      );
    }

    const emailExists = await verifyEmailExists(email);

    if (emailExists) {
      throw new HttpsError("already-exists", "Email já cadastrado!");
    }

    let userRecord;
    try {
      userRecord = await auth.createUser({
        email,
        password,
        displayName: name,
      });
    } catch (error: any) {
      if (error?.code === "auth/email-already-exists") {
        throw new HttpsError("already-exists", "Email já cadastrado no Auth.");
      }
      throw error;
    }

    await usersCollection.doc(userRecord.uid).set({
      ...request.data,
      uid: userRecord.uid,
      emailLowerCase: email.toLowerCase(),
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