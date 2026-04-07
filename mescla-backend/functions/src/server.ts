import express from 'express';
import { onRequest } from 'firebase-functions/v2/https';
import userRouter from './routes/user.routes';


const app = express();

app.use(express.json());

app.get('/', (req, res) => {
  res.send('API MesclaInvest online');
});

app.use('/users', userRouter); //rota para a url do usuario onde fica tudo relacionado a ele. 


export const api = onRequest(app);