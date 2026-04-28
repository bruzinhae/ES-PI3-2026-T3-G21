// Autor: Gabriel Padreca Nicoletti
// RA: 20013009

import { HttpsError, onCall } from "firebase-functions/v2/https";

import { auth } from "../../shared/firebase";
import { transporter } from "../shared/mailer";
import { verifyEmailExists } from "../repositories/usersRepository";

export const requestPasswordResetEmail = onCall(async (request) => {
  try {
    const { email } = request.data;

    if (!email || typeof email !== "string") {
      throw new HttpsError("invalid-argument", "Campo email é obrigatório.");
    }

    const normalizedEmail = email.trim().toLowerCase();

    if (!normalizedEmail.includes("@")) {
      throw new HttpsError("invalid-argument", "E-mail inválido.");
    }

    // Em sistema real isso aqui sempre retornaria ok (mesmo se o e-mail não existir)
    // pra evitar email enumeration attack (atacante fica testando e-mails na tela de
    // esqueci senha pra descobrir quais estão cadastrados). Como é trabalho acadêmico,
    // retornamos erro mesmo, pra UX ficar mais clara. Em produção real isso aqui mudaria.
    const emailExists = await verifyEmailExists(normalizedEmail);

    if (!emailExists) {
      throw new HttpsError("not-found", "E-mail não encontrado.");
    }

    const resetLink = await auth.generatePasswordResetLink(normalizedEmail);

    await transporter.sendMail({
      from: `"MesclaInvest" <${process.env.SMTP_USER}>`,
      to: normalizedEmail,
      subject: "Redefinição de senha - MesclaInvest",
      html: `
        <div style="font-family: Arial, sans-serif; padding: 20px;">
          <h2>Redefinição de senha</h2>
          <p>Recebemos uma solicitação para redefinir a senha da sua conta no MesclaInvest.</p>
          <p>Clique no botão abaixo para criar uma nova senha:</p>
          <a href="${resetLink}"
             style="background-color: #4CAF50;
                    color: white;
                    padding: 14px 20px;
                    text-decoration: none;
                    border-radius: 4px;
                    display: inline-block;">
            Redefinir senha
          </a>
          <p>Se você não solicitou essa redefinição, ignore este e-mail.</p>
          <p>O link expira em 1 hora.</p>
        </div>
      `,
    });

    return {
      message: "E-mail de redefinição enviado com sucesso.",
    };
  } catch (error) {
    if (error instanceof HttpsError) {
      throw error;
    }

    console.error("Erro ao enviar e-mail de redefinição:", error);
    throw new HttpsError("internal", "Erro ao enviar e-mail de redefinição.");
  }
});
