// Autor: Gabriel Padreca Nicoletti
// RA: 20013009

import {HttpsError, onCall} from "firebase-functions/https";
import {requireAuthenticatedUser} from "../../shared/auth";
import {usersCollection} from "../repositories/usersRepository";

function validateProfileImageUrl(profileImageUrl: unknown, uid: string): string {
  if (typeof profileImageUrl !== "string") {
    throw new HttpsError("invalid-argument", "URL da imagem de perfil é obrigatória.");
  }

  const trimmedUrl = profileImageUrl.trim();

  try {
    const url = new URL(trimmedUrl);
    if (url.protocol !== "https:") {
      throw new HttpsError("invalid-argument", "URL da imagem de perfil deve usar HTTPS.");
    }
    if (url.hostname !== "firebasestorage.googleapis.com") {
      throw new HttpsError("invalid-argument", "URL da imagem de perfil deve vir do Firebase Storage.");
    }

    const expectedPath = `/v0/b/mesclainvest123.firebasestorage.app/o/users/${uid}/profile/avatar.jpg`;
    if (decodeURIComponent(url.pathname) !== expectedPath) {
      throw new HttpsError("invalid-argument", "URL da imagem de perfil não pertence ao usuário autenticado.");
    }
  } catch (error) {
    if (error instanceof HttpsError) {
      throw error;
    }
    throw new HttpsError("invalid-argument", "URL da imagem de perfil inválida.");
  }

  return trimmedUrl;
}

export const updateUserProfileImage = onCall(async (request) => {
  const user = requireAuthenticatedUser(request);
  const profileImageUrl = validateProfileImageUrl(request.data?.profileImageUrl, user.uid);

  await usersCollection.doc(user.uid).update({
    profileImageUrl,
    updatedAt: new Date(),
  });

  return {
    message: "Foto de perfil atualizada com sucesso.",
    profileImageUrl,
  };
});
