// MIDDLEWARE PARA A AUTENTICAÇÃO DO USUARIO POR TOKEN

import { Request, Response, NextFunction } from 'express';
import { getAuth } from 'firebase-admin/auth';
import '../firebase/firebase'; 


export async function authMiddleware(
  req: Request,
  res: Response,
  next: NextFunction
) {
  try {
    const authHeader = req.headers.authorization;

    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({
        message: 'Token não informado',
      });
    }

    const token = authHeader.split('Bearer ')[1];

    const decodedToken = await getAuth().verifyIdToken(token);

    (req as any).user = decodedToken;

    return next();
  } catch (error) {
    return res.status(401).json({
      message: 'Token inválido ou expirado',
    });
  }
}

