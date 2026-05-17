// Autor: Alinne Monteiro de Melo
// RA: 24801649

import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';

// models

class Founder {
  final String name;
  final String role;
  final double equityPercent;
  final String? bio;

  Founder({
    required this.name,
    required this.role,
    required this.equityPercent,
    this.bio,
  });

  factory Founder.fromMap(Map<String, dynamic> map) {
    return Founder(
      name: map['name'] ?? '',
      role: map['role'] ?? '',
      equityPercent: (map['equityPercent'] as num?)?.toDouble() ?? 0,
      bio: map['bio'],
    );
  }
}

class ExternalMember {
  final String name;
  final String role;
  final String? organization;

  ExternalMember({
    required this.name,
    required this.role,
    this.organization,
  });

  factory ExternalMember.fromMap(Map<String, dynamic> map) {
    return ExternalMember(
      name: map['name'] ?? '',
      role: map['role'] ?? '',
      organization: map['organization'],
    );
  }
}

class StartupQuestion {
  final String authorName;
  final String message;
  final bool isAnswer;
  final String? answer;

  StartupQuestion({
    required this.authorName,
    required this.message,
    required this.isAnswer,
    this.answer,
  });

  factory StartupQuestion.fromMap(Map<String, dynamic> map) {
    return StartupQuestion(
      authorName: map['authorName'] ?? map['name'] ?? 'Usuário',
      message: map['message'] ?? map['text'] ?? '',
      isAnswer: map['isAnswer'] == true || map['isUser'] == false,
      answer: map['answer'],
    );
  }
}

class StartupAccess {
  final bool isInvestor;
  final bool canTradeTokens;
  final bool canSendPrivateQuestions;

  StartupAccess({
    required this.isInvestor,
    required this.canTradeTokens,
    required this.canSendPrivateQuestions,
  });

  factory StartupAccess.fromMap(Map<String, dynamic> map) {
    return StartupAccess(
      isInvestor: map['isInvestor'] == true,
      canTradeTokens: map['canTradeTokens'] == true,
      canSendPrivateQuestions: map['canSendPrivateQuestions'] == true,
    );
  }
}

class StartupDetails {
  final String id;
  final String name;
  final String stage;
  final String shortDescription;
  final String description;
  final String executiveSummary;

  /// centavos (ex: 150000000 = R$ 1.500.000,00)
  final int capitalRaisedCents;

  /// quantidade total de tokens emitidos
  final int totalTokensIssued;

  /// preço atual do token em centavos
  final int currentTokenPriceCents;

  final List<String> tags;
  final List<Founder> founders;
  final List<ExternalMember> externalMembers;
  final List<String> demoVideos;
  final String? pitchDeckUrl;
  final String? coverImageUrl;
  final String? emailContact;
  final List<Map<String, dynamic>> documents;
  final List<StartupQuestion> publicQuestions;
  final StartupAccess access;
  final String? createdAt;
  final String? updatedAt;

  StartupDetails({
    required this.id,
    required this.name,
    required this.stage,
    required this.shortDescription,
    required this.description,
    required this.executiveSummary,
    required this.capitalRaisedCents,
    required this.totalTokensIssued,
    required this.currentTokenPriceCents,
    required this.tags,
    required this.founders,
    required this.externalMembers,
    required this.demoVideos,
    this.pitchDeckUrl,
    this.coverImageUrl,
    this.emailContact,
    required this.documents,
    required this.publicQuestions,
    required this.access,
    this.createdAt,
    this.updatedAt,
  });

  factory StartupDetails.fromMap(Map<String, dynamic> map) {
    return StartupDetails(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      stage: map['stage'] ?? 'nova',
      shortDescription: map['shortDescription'] ?? '',
      description: map['description'] ?? map['shortDescription'] ?? '',
      executiveSummary: map['executiveSummary'] ?? '',
      capitalRaisedCents: (map['capitalRaisedCents'] as num?)?.toInt() ?? 0,
      totalTokensIssued: (map['totalTokensIssued'] as num?)?.toInt() ?? 0,
      currentTokenPriceCents: (map['currentTokenPriceCents'] as num?)?.toInt() ?? 0,
      tags: List<String>.from(map['tags'] ?? []),
      founders: (map['founders'] as List? ?? [])
          .map((f) => Founder.fromMap(Map<String, dynamic>.from(f)))
          .toList(),
      externalMembers: (map['externalMembers'] as List? ?? [])
          .map((m) => ExternalMember.fromMap(Map<String, dynamic>.from(m)))
          .toList(),
      demoVideos: List<String>.from(map['demoVideos'] ?? []),
      pitchDeckUrl: map['pitchDeckUrl'],
      coverImageUrl: map['coverImageUrl'],
      emailContact: map['emailContact'],
      documents: (map['documents'] as List? ?? [])
          .map((d) => Map<String, dynamic>.from(d))
          .toList(),
      publicQuestions: (map['publicQuestions'] as List? ?? [])
          .map((q) => StartupQuestion.fromMap(Map<String, dynamic>.from(q)))
          .toList(),
      access: map['access'] != null
          ? StartupAccess.fromMap(Map<String, dynamic>.from(map['access']))
          : StartupAccess(
              isInvestor: false,
              canTradeTokens: false,
              canSendPrivateQuestions: false,
            ),
      createdAt: map['createdAt'],
      updatedAt: map['updatedAt'],
    );
  }

  // helpers

  /// formata um valor em centavos para string em reais
  static String formatarReais(int cents) {
    final reais = cents / 100;
    final partes = reais.toStringAsFixed(2).split('.');
    final inteiro = partes[0].replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+$)'),
      (m) => '${m[1]}.',
    );
    return 'R\$ $inteiro,${partes[1]}';
  }

  /// formata numero inteiro grande com separador de milhar (ex: 1.500.000)
  static String formatarInteiro(int valor) {
    return valor.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+$)'),
      (m) => '${m[1]}.',
    );
  }

  String get capitalFormatado => formatarReais(capitalRaisedCents);
  String get tokensFormatados => formatarInteiro(totalTokensIssued);
  String get tokenPriceFormatado => formatarReais(currentTokenPriceCents);

  /// valorização = preço atual do token formatado como reais
  /// a fazer %
  String get valorizacaoFormatada {
    if (currentTokenPriceCents == 0) return '-';
    return formatarReais(currentTokenPriceCents);
  }

  String get stageFormatado {
    switch (stage) {
      case 'nova':
        return 'Nova';
      case 'em_operacao':
        return 'Em operação';
      case 'em_expansao':
        return 'Em expansão';
      default:
        return stage;
    }
  }

  String get tagsFormatadas {
    if (tags.isEmpty) return 'STARTUP';
    return tags.join(' • ').toUpperCase();
  }
}

// service

class StartupService {
  static final FirebaseFunctions _functions = FirebaseFunctions.instanceFor(
    region: 'us-central1',
  );

  /// busca os detalhes completos de uma startup pelo ID.
  static Future<StartupDetails> getStartupDetails(String startupId) async {
    debugPrint('[StartupService] getStartupDetails: $startupId');

    final result = await _functions
        .httpsCallable('getStartupDetails')
        .call({'startupId': startupId});

    debugPrint('[StartupService] resposta: ${result.data}');

    final data = Map<String, dynamic>.from(result.data['data']);
    return StartupDetails.fromMap(data);
  }

  /// envia uma pergunta pública para a startup.
  static Future<void> createStartupQuestion({
    required String startupId,
    required String message,
  }) async {
    debugPrint('[StartupService] createStartupQuestion: $startupId');

    await _functions.httpsCallable('createStartupQuestion').call({
      'startupId': startupId,
      'message': message,
    });
  }

  /// lista as perguntas públicas de uma startup.
  static Future<List<StartupQuestion>> listPublicQuestions(
      String startupId) async {
    debugPrint('[StartupService] listPublicQuestions: $startupId');

    final result = await _functions
        .httpsCallable('listStartupQuestions')
        .call({'startupId': startupId});

    final List data = result.data['data'] ?? [];
    return data
        .map((q) => StartupQuestion.fromMap(Map<String, dynamic>.from(q)))
        .toList();
  }
}