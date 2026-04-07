// AQUI FICARAM TODOS OS ENDPOINTS RELACIONADOS A USUÁRIO, COMO LOGIN, CADASTRO, ETC.

import { Router, Response, Request} from 'express';

import { authMiddleware } from '../middleware/user.middleware';  

import { getUserController } from '../controllers/user.controller';  


const userRouter = Router();

userRouter.get('/', (req: Request, res: Response) => {
  res.send('Rota de usuário funcionando');
});


userRouter.get('/', authMiddleware, getUserController);



export default userRouter;