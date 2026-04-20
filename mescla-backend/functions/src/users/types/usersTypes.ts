import { 
    Timestamp
} from "firebase-admin/firestore";

export interface UserDocument {
    uid:            string;
    name:           string;
    email:          string;
    emailLowerCase: string;
    cpf:            string;
    telefone:       string;
    balanceCents:   number;    
    mfaEnabled:     boolean;   
    isAdmin:        boolean;   
    createdAt:      Timestamp;
    updatedAt:      Timestamp;
}

export type AuthenticatedUser = {
    uid: string;
    email?: string;
};