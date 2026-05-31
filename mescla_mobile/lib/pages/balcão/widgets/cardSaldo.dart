// Autor: Alinne Monteiro de Melo
// RA: 24801649

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mescla_mobile/pages/balcão/balcaoHelpers.dart';

/// card de saldo disponível e total de tokens do usuário
class BalanceCard extends StatelessWidget {
  final DocumentReference  userDoc;
  final CollectionReference assetsCol;

  const BalanceCard({
    super.key,
    required this.userDoc,
    required this.assetsCol,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: userDoc.snapshots(),
      builder: (context, userSnap) {
        return StreamBuilder<QuerySnapshot>(
          stream: assetsCol.snapshots(),
          builder: (context, assetsSnap) {
            final userData     = userSnap.data?.data() as Map<String, dynamic>?;
            final balanceCents = (userData?['balanceCents'] as int?) ?? 0;
            final totalTokens  = assetsSnap.hasData
                ? assetsSnap.data!.docs.fold<int>(0, (sum, doc) {
                    final d = doc.data() as Map<String, dynamic>;
                    return sum + ((d['quantity'] as int?) ?? 0);
                  })
                : 0;

            return Container(
              margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0D2CC8), Color(0xFF8D35E6)],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1A56DB).withOpacity(0.35),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Saldo disponível',
                            style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                                fontWeight: FontWeight.w500)),
                        const SizedBox(height: 6),
                        Text(
                          TradingPageHelpers.formatCurrency(balanceCents),
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('$totalTokens',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w800)),
                      Text('tokens',
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 11)),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}