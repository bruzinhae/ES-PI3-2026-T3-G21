import {
    getUserByUid,
} from "../repositories/usersRepository";

import { 
    HttpsError, 
    onCall 
} from 'firebase-functions/v2/https';


export const getMe = onCall(async (request) => {
    try{
        if (!request.auth) {
        throw new HttpsError("unauthenticated", "Token inválido!");
    }

        const uid = request.auth.uid;
        const userDoc = await getUserByUid(uid);

        return {user: userDoc};
    }
    catch (error) {
        if (error instanceof HttpsError) {
        throw error;
    }
        console.error("Erro ao obter usuário:", error);
        throw new HttpsError("internal", "Erro ao obter usuário.");
    }   
});