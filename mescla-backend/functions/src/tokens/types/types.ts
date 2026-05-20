export interface TokenSnapshotDocument {
  priceCents: number;
  criadoEm: Date;
}

export interface TokenPriceHistoryResponse {
  startupId: string;
  history: {
    priceCents: number;
    criadoEm: string;
  }[];
}