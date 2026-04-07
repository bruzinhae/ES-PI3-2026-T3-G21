import express from 'express';
import { onRequest } from 'firebase-functions/v2/https';


const app = express();

app.use(express.json());

app.get('/', (req, res) => {
  res.send('API MesclaInvest online');
});



export const api = onRequest(app);