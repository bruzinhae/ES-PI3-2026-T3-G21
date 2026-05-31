//! SO VAI PODER USAR ESSE HANDLER QUEM FOR ADMIN, POIS OS USUARIOS NAO TEM PERMISSAO DE ADICIONAR STARTUPS
//! COLOCAR VERIFICAR DO USUÁRIO É ADMIN ANTES DE PERMITIR ADICIONAR STARTUP, MUDAR A FUNÇÃO PARA RECEBER AS INFORMAÇÕES VIA REQUEST 

/*
Nome: Mateus Souza Marinho
RA: 24005497
*/

import { 
    HttpsError, 
    onCall 
} from "firebase-functions/https";

import {
    startupsCollection
} from '../repositories/startupsRepository';

import {
    StartupDocument
} from "../types/startupTypes";

import { 
    requireAuthenticatedUser //! descomentar quando acabar os testes
} from "../../shared/auth";

import { 
    getUserByUid
} from "../../users/repositories/usersRepository";

import { Timestamp } from "firebase-admin/firestore";
import { saveTokenSnapshot } from '../../tokens/repositories/tokensRepository';

export const addStartup  = onCall(async(request)=> {
    try{
        
        requireAuthenticatedUser(request);
        
        const uid = request.auth!.uid;
        const user = await getUserByUid(uid);

        if(!user || !user.isAdmin){
            throw new HttpsError("permission-denied", "Apenas administradores podem adicionar startups.");
        }

        const startupData = request.data as StartupDocument;

        const newStartup: StartupDocument = {
            ...startupData,
            createdAt: Timestamp.now(),
            updatedAt: Timestamp.now(),
        };

        const docRef = await startupsCollection.add(newStartup); 

        // salva o snapshot inicial para o histórico de preços não começar vazio
        const precoInicial = startupData.currentTokenPriceCents ?? 100;
        await saveTokenSnapshot(docRef.id, precoInicial);

        return {message: "Startup adicionada com sucesso!"};
    }
    catch(e){
        console.error("Error adding startup: ", e);
        throw new HttpsError("internal", "Erro ao adicionar startup.");
    }
})