// Autor: Alinne Monteiro de Melo
// RA: 24801649

import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';

// ─── Models ────────────────────────────────────────────────────────────────

class DashboardAsset {
  final String startupId;
  final String startupName;
  final String? coverImageUrl;
  final int quantity;
  final int averagePriceCents;
  final int currentTokenPriceCents;
  final int investedCents;
  final int currentValueCents;
  final int resultCents;
  final double resultPercent;

  DashboardAsset({
    required this.startupId,
    required this.startupName,
    this.coverImageUrl,
    required this.quantity,
    required this.averagePriceCents,
    required this.currentTokenPriceCents,
    required this.investedCents,
    required this.currentValueCents,
    required this.resultCents,
    required this.resultPercent,
  });

  factory DashboardAsset.fromMap(Map<String, dynamic> map) {
    return DashboardAsset(
      startupId: map['startupId'] ?? '',
      startupName: map['startupName'] ?? '',
      coverImageUrl: map['coverImageUrl'],
      quantity: (map['quantity'] as num?)?.toInt() ?? 0,
      averagePriceCents: (map['averagePriceCents'] as num?)?.toInt() ?? 0,
      currentTokenPriceCents: (map['currentTokenPriceCents'] as num?)?.toInt() ?? 0,
      investedCents: (map['investedCents'] as num?)?.toInt() ?? 0,
      currentValueCents: (map['currentValueCents'] as num?)?.toInt() ?? 0,
      resultCents: (map['resultCents'] as num?)?.toInt() ?? 0,
      resultPercent: (map['resultPercent'] as num?)?.toDouble() ?? 0,
    );
  }

  String get valorFormatado => _formatarReais(currentValueCents);

  String get variacaoFormatada {
    final sinal = resultPercent >= 0 ? '+' : '';
    return '$sinal${resultPercent.toStringAsFixed(1)}%';
  }

  bool get positivo => resultPercent >= 0;
}

class DashboardData {
  final int balanceCents;
  final int investedCents;
  final int currentPortfolioValueCents;
  final int totalPatrimonyCents;
  final int resultCents;
  final double resultPercent;
  final String period;
  final List<String> availablePeriods;
  final List<DashboardAsset> assets;

  DashboardData({
    required this.balanceCents,
    required this.investedCents,
    required this.currentPortfolioValueCents,
    required this.totalPatrimonyCents,
    required this.resultCents,
    required this.resultPercent,
    required this.period,
    required this.availablePeriods,
    required this.assets,
  });

  factory DashboardData.fromMap(Map<String, dynamic> map) {
    return DashboardData(
      balanceCents: (map['balanceCents'] as num?)?.toInt() ?? 0,
      investedCents: (map['investedCents'] as num?)?.toInt() ?? 0,
      currentPortfolioValueCents: (map['currentPortfolioValueCents'] as num?)?.toInt() ?? 0,
      totalPatrimonyCents: (map['totalPatrimonyCents'] as num?)?.toInt() ?? 0,
      resultCents: (map['resultCents'] as num?)?.toInt() ?? 0,
      resultPercent: (map['resultPercent'] as num?)?.toDouble() ?? 0,
      period: map['period'] ?? '6M',
      availablePeriods: List<String>.from(map['availablePeriods'] ?? []),
      assets: (map['assets'] as List? ?? [])
          .map((a) => DashboardAsset.fromMap(Map<String, dynamic>.from(a)))
          .toList(),
    );
  }

  String get totalFormatado => _formatarReais(totalPatrimonyCents);

  String get variacaoFormatada {
    final sinal = resultPercent >= 0 ? '+' : '';
    return '$sinal${resultPercent.toStringAsFixed(1)}%';
  }

  bool get positivo => resultPercent >= 0;
}

class TokenPricePoint {
  final int priceCents;
  final DateTime criadoEm;

  TokenPricePoint({required this.priceCents, required this.criadoEm});

  factory TokenPricePoint.fromMap(Map<String, dynamic> map) {
    return TokenPricePoint(
      priceCents: (map['priceCents'] as num?)?.toInt() ?? 0,
      criadoEm: DateTime.parse(map['criadoEm']),
    );
  }
}

class TokenPriceHistory {
  final String startupId;
  final List<TokenPricePoint> history;

  TokenPriceHistory({required this.startupId, required this.history});

  factory TokenPriceHistory.fromMap(Map<String, dynamic> map) {
    return TokenPriceHistory(
      startupId: map['startupId'] ?? '',
      history: (map['history'] as List? ?? [])
          .map((p) => TokenPricePoint.fromMap(Map<String, dynamic>.from(p)))
          .toList(),
    );
  }
}

// ─── Helpers ───────────────────────────────────────────────────────────────

String _formatarReais(int cents) {
  final reais = cents / 100;
  final partes = reais.toStringAsFixed(2).split('.');
  final inteiro = partes[0].replaceAllMapped(
    RegExp(r'(\d)(?=(\d{3})+$)'),
    (m) => '${m[1]}.',
  );
  return 'R\$ $inteiro,${partes[1]}';
}

// ─── Service ───────────────────────────────────────────────────────────────

class DashboardService {
  static final FirebaseFunctions _functions = FirebaseFunctions.instanceFor(
    region: 'us-central1',
  );

  static final _periodoMap = {
    '1D': 'diario',
    '7D': 'semanal',
    '1M': 'mensal',
    '6M': 'semestral',
    'YTD': 'ytd',
  };

  static Future<DashboardData> getUserDashboard({String period = '6M'}) async {
    debugPrint('[DashboardService] getUserDashboard: period=$period');

    final result = await _functions
        .httpsCallable('getUserDashboard')
        .call({'period': period});

    final data = Map<String, dynamic>.from(result.data['data']);
    return DashboardData.fromMap(data);
  }

  static Future<TokenPriceHistory> getTokenPriceHistory({
    required String startupId,
    required String period,
  }) async {
    debugPrint('[DashboardService] getTokenPriceHistory: $startupId | $period');

    final result = await _functions
        .httpsCallable('getTokenPriceHistoryHandler')
        .call({
          'startupId': startupId,
          'periodo': _periodoMap[period] ?? 'semestral',
        });

    return TokenPriceHistory.fromMap(Map<String, dynamic>.from(result.data));
  }
}