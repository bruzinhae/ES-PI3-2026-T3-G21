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

import { validateCPF } from "../shared/validation";


export const updateUserCPF = onCall(async (request) => {
    try{
        const user = requireAuthenticatedUser(request);
        const {newCPF} = request.data;
        
        if(!newCPF){
            throw new HttpsError("invalid-argument", "O número do CPF é obrigatório.");
        }

        if(!validateCPF(newCPF)){
            throw new HttpsError("invalid-argument", "CPF inválido! Deve conter apenas números e ter 11 dígitos.");
        }

        await updateField(user.uid, "cpf", newCPF);

        return {
            message: "Número do CPF atualizado com sucesso!",
            newCPF: newCPF
        };
    }
    catch(error){
        if (error instanceof HttpsError) {
            throw error;
        }
        throw new HttpsError("internal", "Erro ao atualizar CPF.", error);
    }
})