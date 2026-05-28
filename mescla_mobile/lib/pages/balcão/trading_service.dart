// Autor: Bruna Barbour Fernandes
// RA: 23007950

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';

// ── Modelos ───────────────────────────────────────────────────────────────────

class StartupItem {
  final String id;
  final String name;
  final int currentTokenPriceCents;
  final String? coverImageUrl;

  StartupItem({
    required this.id,
    required this.name,
    required this.currentTokenPriceCents,
    this.coverImageUrl,
  });

  factory StartupItem.fromMap(String id, Map<String, dynamic> data) {
    return StartupItem(
      id: id,
      name: data['name'] as String? ?? '—',
      currentTokenPriceCents:
          (data['currentTokenPriceCents'] as num?)?.toInt() ?? 0,
      coverImageUrl: data['coverImageUrl'] as String?,
    );
  }
}

/// Representa uma oferta aberta no livro P2P.
class StartupOffer {
  final String offerId;
  final String type;       // "buy" | "sell"
  final bool isOwn;        // true se foi criada pelo usuário logado
  final int quantity;
  final int priceCents;
  final int totalCents;
  final String createdAt;

  StartupOffer({
    required this.offerId,
    required this.type,
    required this.isOwn,
    required this.quantity,
    required this.priceCents,
    required this.totalCents,
    required this.createdAt,
  });

  factory StartupOffer.fromMap(Map<String, dynamic> m) => StartupOffer(
        offerId:    m['offerId']    as String,
        type:       m['type']       as String,
        isOwn:      m['isOwn']      as bool? ?? false,
        quantity:   (m['quantity']  as num).toInt(),
        priceCents: (m['priceCents'] as num).toInt(),
        totalCents: (m['totalCents'] as num).toInt(),
        createdAt:  m['createdAt']  as String? ?? '',
      );

  bool get isSell => type == 'sell';
  bool get isBuy  => type == 'buy';
}

// ── TradingService ────────────────────────────────────────────────────────────

class TradingService {
  static final _functions =
      FirebaseFunctions.instanceFor(region: 'us-central1');

  // ── Startups ────────────────────────────────────────────────────────────────

  static Future<List<StartupItem>> listarStartups() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('startups').get();
    return snapshot.docs
        .map((doc) => StartupItem.fromMap(doc.id, doc.data()))
        .toList();
  }

  // ── Criação de oferta (substitui comprarTokens / venderTokens) ─────────────

  /// Cria uma oferta de compra ou venda no balcão P2P.
  ///
  /// [type]       — 'buy' ou 'sell'
  /// [startupId]  — ID da startup
  /// [quantity]   — quantidade de tokens
  /// [priceCents] — preço por token em centavos (definido livremente pelo usuário)
  ///
  /// Retorna o [offerId] da oferta criada.
  static Future<String> criarOferta({
    required String type,
    required String startupId,
    required int quantity,
    required int priceCents,
  }) async {
    final result = await _functions.httpsCallable('createOffer').call({
      'type':       type,
      'startupId':  startupId,
      'quantity':   quantity,
      'priceCents': priceCents,
    });

    return result.data['data']['offerId'] as String;
  }

  // ── Aceite de oferta ────────────────────────────────────────────────────────

  /// Aceita uma oferta aberta (all-or-nothing).
  /// Retorna o saldo atualizado do aceitador em centavos.
  static Future<int> aceitarOferta(String offerId) async {
    final result =
        await _functions.httpsCallable('acceptOffer').call({'offerId': offerId});

    return (result.data['data']['acceptorBalanceCents'] as num).toInt();
  }

  // ── Livro de ofertas ────────────────────────────────────────────────────────

  /// Lista ofertas abertas de uma startup.
  /// Retorna todas as ofertas unificadas (o Flutter separa por [StartupOffer.type]).
  static Future<List<StartupOffer>> listarOfertas(String startupId) async {
    await FirebaseAuth.instance.currentUser?.getIdToken(true);
    final result = await _functions
        .httpsCallable('listStartupOffers')
        .call({'startupId': startupId});

    final data = Map<String, dynamic>.from(result.data['data'] as Map);
    final offers = data['offers'] as List<dynamic>;

    return offers
        .map((e) => StartupOffer.fromMap(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  // ── Helpers de cálculo ──────────────────────────────────────────────────────

  static double centavosParaReais(int centavos) => centavos / 100;

  static int calcularTotalCents(int quantity, int priceCents) =>
      quantity * priceCents;
}