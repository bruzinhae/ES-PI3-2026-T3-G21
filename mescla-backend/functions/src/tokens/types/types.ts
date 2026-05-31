/*
Nome: Mateus Souza Marinho
RA: 24005497
*/

export interface TokenSnapshotDocument {
  priceCents: number;
  criadoEm: Date;
}

export interface TokenPriceHistoryResponse {
  startupId: string;
  variacaoPercent: number;
  history: {
    priceCents: number;
    criadoEm: string;
  }[];
}