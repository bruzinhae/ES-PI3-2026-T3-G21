// Autor: Alinne Monteiro de Melo
// RA: 24801649

import {HttpsError, onCall} from "firebase-functions/v2/https";
import {requireAuthenticatedUser} from "../../shared/auth";
import {db} from "../../shared/firebase";


export const listStartupOffers = onCall(async (request) => {
  try {
    const user = requireAuthenticatedUser(request);
    const {startupId, type} = request.data ?? {};

    if (!startupId || typeof startupId !== "string") {
      throw new HttpsError("invalid-argument", "Campo startupId é obrigatório.");
    }

    // busca todas as ofertas abertas da startup
    let query = db
      .collection("offers")
      .where("startupId", "==", startupId)
      .where("status", "==", "open");

    // filtro opcional por tipo
    if (type === "buy" || type === "sell") {
      query = query.where("type", "==", type);
    }

    const snapshot = await query.get();

    const allOffers = snapshot.docs.map((doc) => {
      const d = doc.data();
      return {
        offerId: doc.id,
        type: d.type as "buy" | "sell",
        creatorUid: d.creatorUid as string,
        isOwn: d.creatorUid === user.uid,
        quantity: d.quantity as number,
        priceCents: d.priceCents as number,
        totalCents: d.totalCents as number,
        createdAt: (d.createdAt?.toDate?.() ?? new Date()).toISOString(),
      };
    });

    // separa e ordena: vendas pelo menor preço primeiro (melhor pra quem quer comprar)
    //                  compras pelo maior preço primeiro (melhor pra quem quer vender)
    const sellOffers = allOffers
      .filter((o) => o.type === "sell")
      .sort((a, b) => a.priceCents - b.priceCents);

    const buyOffers = allOffers
      .filter((o) => o.type === "buy")
      .sort((a, b) => b.priceCents - a.priceCents);

    return {
      data: {
        startupId,
        sellOffers,
        buyOffers,
        offers: [...sellOffers, ...buyOffers],
      },
    };
  } catch (error) {
    if (error instanceof HttpsError) throw error;
    console.error("Erro ao listar ofertas:", error);
    throw new HttpsError("internal", "Erro ao listar ofertas.");
  }
});