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

export function telefoneFormat(telefone: string): string{
    try{
        const apenasNumeros = telefone.replace(/\D/g, '');
        if (apenasNumeros.length === 11) {
            return `(${apenasNumeros.slice(0, 2)}) ${apenasNumeros.slice(2, 3)} ${apenasNumeros.slice(3, 7)}-${apenasNumeros.slice(7)}`;
        }
        if (apenasNumeros.length === 10) {
            return `(${apenasNumeros.slice(0, 2)}) ${apenasNumeros.slice(2, 6)}-${apenasNumeros.slice(6)}`;
        }
    
        return telefone; // Retorna original se não for 10 ou 11 dígitos
    }
    
    catch(e){
        throw new Error("Erro ao formatar telefone, telefone não alterado: " + e);
        return telefone; // Retorna original em caso de erro
    }
}