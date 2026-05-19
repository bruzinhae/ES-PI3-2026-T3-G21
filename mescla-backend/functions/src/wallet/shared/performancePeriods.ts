// Autor: Gabriel Padreca Nicoletti
// RA: 20013009

import {Timestamp} from "firebase-admin/firestore";
import {HttpsError} from "firebase-functions/v2/https";

export type PerformancePeriod =
  "diario" |
  "semanal" |
  "mensal" |
  "seis_meses" |
  "ytd";

export const availablePerformancePeriods: PerformancePeriod[] = [
  "diario",
  "semanal",
  "mensal",
  "seis_meses",
  "ytd",
];

export const requirePerformancePeriod = (
  value: unknown,
): PerformancePeriod => {
  if (value === undefined || value === null || value === "") {
    return "mensal";
  }

  if (typeof value !== "string") {
    throw new HttpsError("invalid-argument", "Periodo invalido.");
  }

  const normalized = value.trim().toLocaleLowerCase("pt-BR");
  const aliases: Record<string, PerformancePeriod> = {
    "1d": "diario",
    "diario": "diario",
    "diário": "diario",
    "daily": "diario",
    "7d": "semanal",
    "semanal": "semanal",
    "weekly": "semanal",
    "1m": "mensal",
    "mensal": "mensal",
    "monthly": "mensal",
    "6m": "seis_meses",
    "seis_meses": "seis_meses",
    "ultimos_6_meses": "seis_meses",
    "últimos_6_meses": "seis_meses",
    "ytd": "ytd",
  };
  const period = aliases[normalized];

  if (!period) {
    throw new HttpsError(
      "invalid-argument",
      "Periodo invalido. Use diario, semanal, mensal, seis_meses ou ytd.",
    );
  }

  return period;
};

export const getPeriodStart = (
  period: PerformancePeriod,
  now = new Date(),
): Timestamp => {
  const start = new Date(now);

  if (period === "diario") {
    start.setUTCDate(start.getUTCDate() - 1);
  }

  if (period === "semanal") {
    start.setUTCDate(start.getUTCDate() - 7);
  }

  if (period === "mensal") {
    start.setUTCDate(start.getUTCDate() - 30);
  }

  if (period === "seis_meses") {
    start.setUTCDate(start.getUTCDate() - 183);
  }

  if (period === "ytd") {
    start.setUTCMonth(0, 1);
    start.setUTCHours(0, 0, 0, 0);
  }

  return Timestamp.fromDate(start);
};

export const calculatePercentChange = (
  initialCents: number,
  currentCents: number,
): number | null => {
  if (initialCents <= 0) {
    return null;
  }

  return Number((((currentCents - initialCents) / initialCents) * 100)
    .toFixed(2));
};
