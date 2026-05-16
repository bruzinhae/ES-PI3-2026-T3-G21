// Autor: Bruna Barbour Fernandes
// RA: 23007950

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

// Modelo local da startup (espelha StartupListItem do back)
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
      currentTokenPriceCents: (data['currentTokenPriceCents'] as num?)?.toInt() ?? 0,
      coverImageUrl: data['coverImageUrl'] as String?,
    );
  }
}

class TradingService {
  static final _functions = FirebaseFunctions.instanceFor(region: 'us-central1');

  // ── Busca lista de startups do Firestore ────────
  static Future<List<StartupItem>> listarStartups() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('startups')
        .get();

    return snapshot.docs
        .map((doc) => StartupItem.fromMap(doc.id, doc.data()))
        .toList();
  }

  // ── Compra tokens — chama buyTokens no back ─────
  // Retorna o novo saldo em centavos
  static Future<int> comprarTokens({
    required String startupId,
    required int quantity,
  }) async {
    final result = await _functions
        .httpsCallable('buyTokens')
        .call({
          'startupId': startupId,
          'quantity': quantity,
        });

    return (result.data['data']['balanceCents'] as num).toInt();
  }

  // ── Vende tokens — chama sellTokens no back ─────
  static Future<int> venderTokens({
    required String startupId,
    required int quantity,
  }) async {
    final result = await _functions
        .httpsCallable('sellTokens')
        .call({
          'startupId': startupId,
          'quantity': quantity,
        });

    return (result.data['data']['balanceCents'] as num).toInt();
  }

  // ── Helpers de cálculo ──────────────────────────

  // Converte centavos para reais: 2950 → 29.50
  static double centavosParaReais(int centavos) => centavos / 100;

  // Calcula total da operação em centavos
  static int calcularTotalCents(int quantity, int priceCents) =>
      quantity * priceCents;
}