import {
    updateField
} from "../repositories/usersRepository";

import {
    HttpsError,
    onCall
}   from "firebase-functions/https";

import{
    requireAuthenticatedUser
}  from "../../shared/auth";

import { validateName } from "../shared/validation";


export const updateUserName = onCall(async (request) => {
    try{
        const user = requireAuthenticatedUser(request);
        const {newName} = request.data;
        
        if(!newName){
            throw new HttpsError("invalid-argument", "O nome é obrigatório.");
        }

        if(!validateName(newName)){
            throw new HttpsError("invalid-argument", "Nome inválido! Deve conter pelo menos 2 caracteres.");
        }
        
        await updateField(user.uid, "name", newName);

        return {
            message: "Nome atualizado com sucesso!",
            newName: newName
        };
    }
    catch(error){
        if (error instanceof HttpsError) {
            throw error;
        }
        throw new HttpsError("internal", "Erro ao atualizar nome.", error);
    }
})