export function validateEmail (email: string):boolean{
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return emailRegex.test(email);
}

export function validatePhone(phone: string): boolean {
    const phoneRegex = /^\d{10,11}$/; 
    return phoneRegex.test(phone);
}