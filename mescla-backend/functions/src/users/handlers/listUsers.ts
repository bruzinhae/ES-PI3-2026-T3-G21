import { HttpsError, onCall } from "firebase-functions/https";
import { listUsersItens } from "../repositories/usersRepository";

export const listUsers = onCall (async(request) =>{
    try{
        const users = await listUsersItens();
        return {
            count: users.length,
            users: users
        }
    }
    catch(error){
        console.error("Error listing users: ", error);
        throw new HttpsError("internal", "Erro ao listar usuários.");
    }

})