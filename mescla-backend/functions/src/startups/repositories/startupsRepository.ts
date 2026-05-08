import { 
  FieldValue
} from "firebase-admin/firestore";

import {
  StartupDocument,
  StartupListItem,
  StartupQuestionDocument,

} from "../types/startupTypes";

import { db } from "../../shared/firebase";

export const startupsCollection = db.collection("startups");

export const demoStartups: Array<StartupDocument & { id: string }> = [
  
  {
    id: "biochip-campus",
    name: "BioChip Campus",
    stage: "nova",
    shortDescription:
      "Sensores portateis para analises laboratoriais didaticas.",
    description:
      "A BioChip Campus simula kits de diagnostico rapido para " +
      "laboratorios universitarios, conectando sensores de baixo custo a um " +
      "aplicativo de acompanhamento.",
    executiveSummary:
      "Startup em fase de ideacao com foco em prototipagem " +
      "de sensores educacionais e validacao com cursos da area de saude.",
    capitalRaisedCents: 1850000,
    totalTokensIssued: 100000,
    currentTokenPriceCents: 125,
    founders: [
      {
        name: "Ana Ribeiro",
        role: "CEO",
        equityPercent: 48,
        bio: "Responsavel por estrategia e parcerias academicas.",
      },
      {
        name: "Lucas Moreira",
        role: "CTO",
        equityPercent: 37,
        bio: "Responsavel por hardware e integracao mobile.",
      },
      {
        name: "Mescla Labs",
        role: "Reserva estrategica",
        equityPercent: 15,
      },
    ],
    externalMembers: [
      {
        name: "Dra. Helena Costa",
        role: "Mentora",
        organization: "PUC-Campinas",
      },
    ],
    demoVideos: ["https://example.com/videos/biochip-campus-demo"],
    pitchDeckUrl: "https://example.com/decks/biochip-campus.pdf",
    coverImageUrl:
      "https://images.unsplash.com/photo-1581093458791-9d15482442f6",
    tags: ["healthtech", "iot", "educacao"],
  },


  {
    id: "rota-verde",
    name: "Rota Verde",
    stage: "em_operacao",
    shortDescription: "Otimizacao de rotas sustentaveis para entregas urbanas.",
    description:
      "A Rota Verde usa dados de distancia, emissao estimada e " +
      "ocupacao de entregadores para sugerir rotas urbanas com menor impacto " +
      "ambiental.",
    executiveSummary:
      "Startup em operacao piloto com pequenos comercios " +
      "locais e validacao de indicadores de economia de combustivel.",
    capitalRaisedCents: 7400000,
    totalTokensIssued: 250000,
    currentTokenPriceCents: 310,
    founders: [
      { name: "Beatriz Santos", role: "CEO", equityPercent: 42 },
      { name: "Rafael Almeida", role: "COO", equityPercent: 28 },
      { name: "Carla Nogueira", role: "CTO", equityPercent: 20 },
      { name: "Reserva de incentivos", role: "Pool", equityPercent: 10 },
    ],
    externalMembers: [
      {
        name: "Marcos Lima",
        role: "Conselheiro",
        organization: "Mescla",
      },
      {
        name: "Patricia Gomes",
        role: "Mentora",
        organization: "Rede de Logistica",
      },
    ],
    demoVideos: ["https://example.com/videos/rota-verde-demo"],
    pitchDeckUrl: "https://example.com/decks/rota-verde.pdf",
    coverImageUrl:
      "https://images.unsplash.com/photo-1500530855697-b586d89ba3ee",
    tags: ["logtech", "sustentabilidade", "mobilidade"],
  },


  {
    id: "mentorai",
    name: "MentorAI",
    stage: "em_expansao",
    shortDescription:
      "Triagem inteligente para programas de mentoria universitarios.",
    description:
      "A MentorAI organiza perfis de estudantes e mentores para " +
      "recomendar encontros com base em objetivos, disponibilidade e " +
      "historico de acompanhamento.",
    executiveSummary:
      "Startup em expansao com uso simulado em programas de " +
      "pre-aceleracao e potencial de integracao a plataformas educacionais.",
    capitalRaisedCents: 12350000,
    totalTokensIssued: 500000,
    currentTokenPriceCents: 525,
    founders: [
      { name: "Diego Martins", role: "CEO", equityPercent: 36 },
      { name: "Juliana Vieira", role: "CPO", equityPercent: 24 },
      { name: "Felipe Andrade", role: "CTO", equityPercent: 25 },
      {
        name: "Investidores simulados",
        role: "Participacao externa",
        equityPercent: 15,
      },
    ],
    externalMembers: [
      {
        name: "Sofia Pereira",
        role: "Conselheira",
        organization: "Ecossistema Mescla",
      },
    ],
    demoVideos: ["https://example.com/videos/mentorai-demo"],
    pitchDeckUrl: "https://example.com/decks/mentorai.pdf",
    coverImageUrl:
      "https://images.unsplash.com/photo-1552664730-d307ca884978",
    tags: ["edtech", "ia", "mentoria"],
  },
];

function toListItem(id: string, startup: Partial<StartupDocument>): StartupListItem {
  return {
    id,
    name: startup.name ?? "",
    stage: startup.stage ?? "nova",
    shortDescription: startup.shortDescription ?? "",
    capitalRaisedCents: startup.capitalRaisedCents ?? 0,
    totalTokensIssued: startup.totalTokensIssued ?? 0,
    currentTokenPriceCents: startup.currentTokenPriceCents ?? 0,
    coverImageUrl: startup.coverImageUrl,
    tags: Array.isArray(startup.tags) ? startup.tags : [],
  };
}

export async function listStartupItems(): Promise<StartupListItem[]> {
  const snapshot = await startupsCollection.limit(100).get();

  return snapshot.docs.map((doc : any) =>
    toListItem(doc.id, doc.data() as StartupDocument)
  );
}

export async function getStartupById(
  startupId: string
): Promise<StartupDocument | undefined> {
  
  const startupSnapshot = await startupsCollection.doc(startupId).get();

  if (!startupSnapshot.exists) {
    return undefined;
  }

  return startupSnapshot.data() as StartupDocument;
}

export async function userIsInvestor(
  startupId: string,
  uid: string
): Promise<boolean> {
  const investorSnapshot = await startupsCollection.doc(startupId).collection("investors").doc(uid).get();

  return investorSnapshot.exists;
}

export async function listPublicQuestions(startupId: string) {
  const questionsSnapshot = await startupsCollection
    .doc(startupId)
    .collection("questions")
    .where("visibility", "==", "publica")
    .limit(50)
    .get();

  return questionsSnapshot.docs
    .map((doc : any) => ({
      id: doc.id,
      text: doc.get("text"),
      answer: doc.get("answer") ?? null,
      answeredAt: doc.get("answeredAt")?.toDate?.()?.toISOString?.() ?? null,
      createdAt: doc.get("createdAt")?.toDate?.()?.toISOString?.() ?? null,
    }))
    .sort((left, right) =>
      String(right.createdAt ?? "").localeCompare(String(left.createdAt ?? ""))
    );
}

export async function createQuestion(
  startupId: string,
  question: StartupQuestionDocument
): Promise<string> {
  const questionRef = await startupsCollection
    .doc(startupId)
    .collection("questions")
    .add(question);

  return questionRef.id;
}

export async function seedDemoStartups(): Promise<string[]> {
  const batch = db.batch();

  for (const startup of demoStartups) {
    const { id, ...data } = startup;
    const startupRef = startupsCollection.doc(id);

    batch.set(
      startupRef,
      {
        ...data,
        createdAt: FieldValue.serverTimestamp(),
        updatedAt: FieldValue.serverTimestamp(),
      },
      { merge: true }
    );
  }

  await batch.commit();

  return demoStartups.map((startup) => startup.id);
}