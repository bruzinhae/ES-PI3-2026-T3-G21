import {
  UserDocument
} from '../types/usersTypes';

import { 
  db,
  auth,
} from "../../shared/firebase";

import { https } from 'firebase-functions';

import { transporter } from '../shared/mailer';

export const usersCollection = db.collection("users");


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

export async function sendVerificationEmail(email: string): Promise<void> {
  try {
    const verificationLink = await auth.generateEmailVerificationLink(email);

    await transporter.sendMail({
      from: `"MesclaInvest" <${process.env.EMAIL_USER}>`,
      to: email,
      subject: 'Verifique seu e-mail - MesclaInvest',
      html: `
        <div style="font-family: Arial, sans-serif; padding: 20px;">
          <h2>Bem-vindo ao MesclaInvest!</h2>
          <p>Clique no botão abaixo para verificar seu e-mail:</p>
          <a href="${verificationLink}" 
             style="background-color: #4CAF50;
                    color: white;
                    padding: 14px 20px;
                    text-decoration: none;
                    border-radius: 4px;">
            Verificar E-mail
          </a>
          <p>Se você não criou uma conta, ignore este e-mail.</p>
          <p>O link expira em 24 horas.</p>
        </div>
      `
    });

  } catch(error) {
    console.error("Erro ao enviar e-mail de verificação: ", error);
    throw new Error("Erro ao enviar e-mail de verificação.");
  }
}