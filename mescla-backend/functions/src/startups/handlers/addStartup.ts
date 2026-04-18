//! SO VAI PODER USAR ESSE HANDLER QUEM FOR ADMIN, POIS OS USUARIOS NAO TEM PERMISSAO DE ADICIONAR STARTUPS
//! COLOCAR VERIFICAR DO USUÁRIO É ADMIN ANTES DE PERMITIR ADICIONAR STARTUP, MUDAR A FUNÇÃO PARA RECEBER AS INFORMAÇÕES VIA REQUEST 

import { 
    HttpsError, 
    onCall 
} from "firebase-functions/https";

import {
    demoStartups,
    startupsCollection
} from '../repositories/startupsRepository';


export const addStartup = onCall(async(request)=>{
    try{
        const newStartup = demoStartups[0];
        await startupsCollection.add(newStartup);
        return {message: "Startup adicionada com sucesso!"};
    }
    catch(error){
        console.error("Error adding startup: ", error);
        throw new HttpsError("internal", "Erro ao adicionar startup.");
    }
})