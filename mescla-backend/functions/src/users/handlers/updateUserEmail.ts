/*
Nome: Mateus Souza Marinho
RA: 24005497
*/

import {requireAuthenticatedUser} from "../../shared/auth"

import { HttpsError, onCall } from "firebase-functions/https"

import {updateEmail} from "../repositories/usersRepository"

import {validateEmail} from "../shared/validation"


export const updateUserEmail = onCall(async(request) => {

    const user = requireAuthenticatedUser(request);
    const {newEmail} = request.data;
    
    if(!validateEmail(newEmail)){
        throw new HttpsError("invalid-argument", "Email invalido");
    }

    await updateEmail(user.uid, newEmail);

    return {
        message : "Email alterado com sucesso",
        newEmail : newEmail
    }
})