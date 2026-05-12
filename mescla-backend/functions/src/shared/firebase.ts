// ARQUIVO PARA INICIALIZAR O FIREBASE 

import { getApps, initializeApp } from 'firebase-admin/app';
import { getFirestore } from 'firebase-admin/firestore';
import  {getAuth} from 'firebase-admin/auth';

if (!getApps().length) {
  initializeApp();
}

export const auth = getAuth();
export const db = getFirestore();