// Autor: Gabriel Padreca Nicoletti
// RA: 20013009

import { HttpsError, onCall } from "firebase-functions/v2/https";

import { requireAuthenticatedUser } from "../../shared/auth";
import { transporter } from "../shared/mailer";
import { getUserByUid } from "../repositories/usersRepository";
import {
  generateMfaCode,
  saveActiveMfaChallenge,
} from "../repositories/mfaRepository";

// gera código de 6 dígitos novo, salva o hash com validade de 10 min e manda por e-mail.
// front chama esse em dois cenários:
// 1. Usuário pediu pra ativar MFA nas configurações (depois usa enableMfa com o código)
// 2. Usuário tem MFA ligado e acabou de logar (depois usa verifyMfaLoginCode com o código)
export const sendMfaCodeByEmail = onCall(async (request) => {
  try {
    const authUser = requireAuthenticatedUser(request);
    const userDoc = await getUserByUid(authUser.uid);

    const code = generateMfaCode();

    await saveActiveMfaChallenge(authUser.uid, code);

    await transporter.sendMail({
      from: `"MesclaInvest" <${process.env.SMTP_USER}>`,
      to: userDoc.email,
      subject: "Código de verificação - MesclaInvest",
      html: `
        <div style="font-family: Arial, sans-serif; padding: 20px;">
          <h2>Código de verificação</h2>
          <p>Use o código abaixo para concluir a verificação em duas etapas:</p>
          <p style="font-size: 32px; font-weight: bold; letter-spacing: 4px; padding: 16px 0;">
            ${code}
          </p>
          <p>O código expira em 10 minutos.</p>
          <p>Se você não solicitou esse código, ignore este e-mail.</p>
        </div>
      `,
    });

    return {
      message: "Código de verificação enviado por e-mail.",
    };
  } catch (error) {
    if (error instanceof HttpsError) {
      throw error;
    }

    console.error("Erro ao enviar código MFA:", error);
    throw new HttpsError("internal", "Erro ao enviar código de verificação.");
  }
});
