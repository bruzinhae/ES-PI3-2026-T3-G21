/*
Nome: Mateus Souza Marinho
RA: 24005497
*/

import {QuestionVisibility, StartupStage} from "../types/startupTypes";

export const allowedStages: StartupStage[] = [
"nova",
"em_operacao",
"em_expansao",
];
export const allowedVisibilities: QuestionVisibility[] = [
"publica",
"privada",
]