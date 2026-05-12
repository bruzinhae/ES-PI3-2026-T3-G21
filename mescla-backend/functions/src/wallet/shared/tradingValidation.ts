// Autor: Gabriel Padreca Nicoletti
// RA: 20013009

import {HttpsError} from "firebase-functions/v2/https";

export const TRADING_COUNTERPARTY_UID =
  process.env.TRADING_COUNTERPARTY_UID ?? "mescla-market-maker";

export const requireStartupId = (value: unknown): string => {
  if (typeof value !== "string" || !value.trim()) {
    throw new HttpsError("invalid-argument", "Campo startupId é obrigatório.");
  }

  return value.trim();
};

export const requireTokenQuantity = (value: unknown): number => {
  if (
    typeof value !== "number" ||
    !Number.isInteger(value) ||
    !Number.isSafeInteger(value) ||
    value <= 0
  ) {
    throw new HttpsError(
      "invalid-argument",
      "Campo quantity deve ser um inteiro positivo.",
    );
  }

  return value;
};

export const requireTokenPrice = (priceCents: unknown): number => {
  if (
    typeof priceCents !== "number" ||
    !Number.isInteger(priceCents) ||
    !Number.isSafeInteger(priceCents) ||
    priceCents <= 0
  ) {
    throw new HttpsError(
      "failed-precondition",
      "Startup sem preço válido para negociação.",
    );
  }

  return priceCents;
};

export const calculateTradeTotalCents = (
  quantity: number,
  priceCents: number,
): number => {
  const totalCents = quantity * priceCents;

  if (!Number.isSafeInteger(totalCents)) {
    throw new HttpsError(
      "invalid-argument",
      "Valor total da negociação é muito alto.",
    );
  }

  return totalCents;
};
