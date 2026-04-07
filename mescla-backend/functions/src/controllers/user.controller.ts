// AQUI FICARAM TODOS AS FUNÇÕES RELACIONADAS A USUÁRIO, COMO LOGIN, CADASTRO, ETC.

import { Request, Response } from 'express';
import { getFirestore } from 'firebase-admin/firestore';
import '../firebase/firebase'; 

const db = getFirestore();

export async function createUserController(req: Request, res: Response) {
  try {
    const user = (req as any).user;

    const { name, role } = req.body;

    await db.collection('users').doc(user.uid).set({
      uid: user.uid,
      email: user.email ?? null,
      name,
      role,
      createdAt: new Date().toISOString(),
    });

    return res.status(201).json({
      message: 'Usuário salvo com sucesso',
      uid: user.uid,
    });
  } catch (error) {
    return res.status(500).json({
      message: 'Erro ao salvar usuário',
    });
  }
}


export async function getUserController(req: Request, res: Response) {
  try {
    const user = (req as any).user;

    const docRef = db.collection('users').doc(user.uid);
    const docSnap = await docRef.get();

    if (!docSnap.exists) {
      return res.status(404).json({
        message: 'Usuário não encontrado',
      });
    }

    return res.status(200).json({
      message: 'Usuário encontrado',
      user: docSnap.data(),
    });
  } catch (error) {
    return res.status(500).json({
      message: 'Erro ao buscar usuário',
    });
  }
}