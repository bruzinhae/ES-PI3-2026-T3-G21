/*
Nome: Mateus Souza Marinho
RA: 24005497
*/

export function validateEmail (email: string):boolean{
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return emailRegex.test(email);
}

export function validatePhone(phone: string): boolean {
    const phoneRegex = /^\d{10,11}$/; 
    return phoneRegex.test(phone);
}

export function validateCPF(cpf: string): boolean {
    const cpfRegex = /^\d{11}$/; 
    return cpfRegex.test(cpf);
}

export function validateName(name: string): boolean {
    return name.trim().length > 0;
}