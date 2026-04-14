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