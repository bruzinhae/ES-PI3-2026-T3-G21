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



export interface UserListItem {
    uid: string;
    name: string;
    email: string;
    cpf: string;
    telefone: string;
    mfaEnabled: boolean;
    isAdmin: boolean;
}

export type AuthenticatedUser = {
    uid: string;
    email?: string;
};


export type UpdatableField = "name" | "telefone" | "CPF";