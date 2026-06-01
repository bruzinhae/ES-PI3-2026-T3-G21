/*
Nome: Mateus Souza Marinho
RA: 24005497
*/

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

import { 
    validatePhone,
    telefoneFormat
} from "../shared/validation";


export const updateUserPhone = onCall(async (request) => {
    try{
        
        const user = requireAuthenticatedUser(request);

        const {newPhone} = request.data;
        const newTelefone = telefoneFormat(newPhone);
        
        if(!newPhone){
            throw new HttpsError("invalid-argument", "O número de telefone é obrigatório.");
        }
        if(!validatePhone(newPhone)){
            throw new HttpsError("invalid-argument", "Telefone inválido! Deve conter apenas números e ter 10 ou 11 dígitos.");
        }

        await updateField(user.uid, "phone", newPhone);
        await updateField(user.uid, "telefone", newTelefone);
        
        return {
          message: "Número de telefone atualizado com sucesso!",
          newPhone: newPhone,
          newTelefone: newTelefone
        };
    }
    catch(error){
        if (error instanceof HttpsError) {
            throw error;
        }
        throw new HttpsError("internal", "Erro ao atualizar telefone.", error);
    }
})