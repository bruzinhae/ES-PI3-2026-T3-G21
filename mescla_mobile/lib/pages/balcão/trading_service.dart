// Autor: Bruna Barbour Fernandes
// RA: 23007950

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';

//modelo local da startup 
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

// modelo de oferta do livro de ofertas
class StartupOffer {
  final int quantity;
  final int priceCents;
  final int totalCents;

  StartupOffer({
    required this.quantity,
    required this.priceCents,
    required this.totalCents,
  });

  factory StartupOffer.fromMap(Map<String, dynamic> m) => StartupOffer(
        quantity:   (m['quantity']   as num).toInt(),
        priceCents: (m['priceCents'] as num).toInt(),
        totalCents: (m['totalCents'] as num).toInt(),
      );
}

class TradingService {
  static final _functions = FirebaseFunctions.instanceFor(region: 'us-central1');

  // busca lista de startups do Firestore
  static Future<List<StartupItem>> listarStartups() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('startups')
        .get();

    return snapshot.docs
        .map((doc) => StartupItem.fromMap(doc.id, doc.data()))
        .toList();
  }

  // compra tokens
  // retorna o novo saldo em centavos
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

  // vende tokens — chama sellTokens no back
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

  // lista ofertas da startup
  static Future<List<StartupOffer>> listarOfertas(String startupId) async {
    await FirebaseAuth.instance.currentUser?.getIdToken(true);
    final result = await _functions
        .httpsCallable('listStartupOffers')
        .call({'startupId': startupId});

    final data   = Map<String, dynamic>.from(result.data['data'] as Map);
    final offers = (data['offers'] as List<dynamic>);

    return offers
      .map((e) => StartupOffer.fromMap(Map<String, dynamic>.from(e as Map)))
      .toList();
  }

  // helpers de calculo

  // converte centavos para reais: 2950 → 29.50
  static double centavosParaReais(int centavos) => centavos / 100;

  // Calcula total da operação em centavos
  static int calcularTotalCents(int quantity, int priceCents) =>
      quantity * priceCents;
}