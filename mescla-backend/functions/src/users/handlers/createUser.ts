import {
    usersCollection,
    demoUsers,
} from '../repositories/usersRepository';

import { 
    UserDocument 
} from '../types/usersTypes';

import { 
    HttpsError, 
    onCall 
} from 'firebase-functions/v2/https';

import {
    auth,
}from "../../shared/firebase";

import { Timestamp } from 'firebase-admin/firestore';


export const createUserTest = onCall(async (request) => {
  try {
    const newUser: UserDocument = demoUsers[0];

    // creates in Firebase Auth first!
    const userRecord = await auth.createUser({
      email:       newUser.email,
      password:    "senha123",
      displayName: newUser.name,
    });

    // saves in Firestore with Auth uid
    await usersCollection.doc(userRecord.uid).set({
      ...newUser,
      uid:       userRecord.uid,
      createdAt: Timestamp.now(),
      updatedAt: Timestamp.now(),
    });

    // returns only safe data!
    return {
      message: "Usuario de teste criado com sucesso!",
      uid:     userRecord.uid,
      name:    newUser.name,
      email:   newUser.email,
    };

  } catch (error) {
    console.error("Error creating test user:", error);
    throw new HttpsError('internal', 'Erro ao criar usuario de teste.');
  }
});


export const createUser = onCall(async (request) => {
    try{

        const { name, email, password, cpf, telefone } = request.data;        

        if (!name || !email || !password || !cpf || !telefone) {
        throw new HttpsError(
        "invalid-argument",
        "Campos obrigatórios: name, email, password, cpf, telefone."
        );
    }   
        const userRecord = await auth.createUser({
        email,
        password,
        displayName: name,
    });

        await usersCollection.doc(userRecord.uid).set({
        ...request.data,
        uid: userRecord.uid,
        emailLowerCase: email.toLowerCase(),
        createdAt: Timestamp.now(),
        updatedAt: Timestamp.now(),
        mfaEnabled: false,
        isAdmin: false,
        balanceCents: 0,
        });


        return {
            message: "Usuario criado com sucesso",
            uid:     userRecord.uid,
            name: userRecord.displayName,
            email: userRecord.email,
        };
    }
    catch (error) {
        console.error("Error creating user:", error);
        throw new HttpsError('internal', 'Erro ao criar usuario');
    }
})