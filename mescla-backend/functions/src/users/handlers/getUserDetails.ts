import { requireAuthenticatedUser } from "../../shared/auth";
import { getUserByUid } from "../repositories/usersRepository";
import {HttpsError, onCall} from "firebase-functions/https";

export const getUserDetails = onCall (async(request) => {
    try{
        
        const {uid} = requireAuthenticatedUser(request)
        
        if(!uid){
            throw new HttpsError("invalid-argument", "UID é obrigatório.");
        }

        const user = await getUserByUid(uid);

        return {
            uid: user.uid,
            name: user.name,
            email: user.email,
            cpf: user.cpf,
            telefone: user.telefone,
            mfaEnabled: user.mfaEnabled,
            isAdmin: user.isAdmin
        };
    
    }
    catch(error){
        console.error("Error fetching user details: ", error);
        throw new HttpsError("internal", "Erro ao buscar detalhes do usuário.");
    }
})