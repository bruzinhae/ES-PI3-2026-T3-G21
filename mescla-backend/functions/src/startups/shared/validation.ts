/*
Nome: Mateus Souza Marinho
RA: 24005497
*/

export function normalizeString(value: unknown): string | undefined {
    if (typeof value !== "string") {
        return undefined;
    }
    
    const trimmed = value.trim();
    return trimmed.length > 0 ? trimmed : undefined;
}