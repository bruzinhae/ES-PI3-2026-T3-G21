// Autor: Alinne Monteiro de Melo
// RA: 24801649

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mescla_mobile/utils/app_colors.dart';
import 'package:mescla_mobile/utils/formatters.dart';

class StartupsSection extends StatelessWidget {
  final List<QueryDocumentSnapshot> docs;

  const StartupsSection({super.key, required this.docs});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Meus Tokens',
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: kOnSurface,
              ),
            ),
            if (docs.isNotEmpty)
              TextButton(
                onPressed: () {},
                child: const Text('Ver tudo', style: TextStyle(color: kPrimary)),
              ),
          ],
        ),
        const SizedBox(height: 12),

        // Estado vazio
        if (docs.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.7),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.4)),
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.rocket_launch_outlined, size: 40, color: kOutline.withOpacity(0.5)),
                  const SizedBox(height: 12),
                  const Text(
                    'Você ainda não tem tokens',
                    style: TextStyle(fontWeight: FontWeight.w600, color: kOnSurface),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Explore o catálogo e faça seu primeiro investimento!',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: kOutline),
                  ),
                ],
              ),
            ),
          ),

        // Lista de tokens
        for (final doc in docs) ...[
          _AssetCard(doc: doc),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _AssetCard extends StatelessWidget {
  final QueryDocumentSnapshot doc;

  const _AssetCard({required this.doc});

  @override
  Widget build(BuildContext context) {
    final data          = doc.data() as Map<String, dynamic>;
    final startupName   = data['startupName']      as String? ?? '—';
    final quantity      = data['quantity']          as int?    ?? 0;
    final avgPrice      = data['averagePriceCents'] as int?    ?? 0;
    final coverUrl      = data['coverImageUrl']     as String?;
    final totalCents    = quantity * avgPrice;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.4)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 2)),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Logo da startup
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 6)],
              image: coverUrl != null
                  ? DecorationImage(image: NetworkImage(coverUrl), fit: BoxFit.cover)
                  : null,
            ),
            child: coverUrl == null
                ? const Icon(Icons.rocket_launch_rounded, color: kPrimary, size: 24)
                : null,
          ),
          const SizedBox(width: 12),

          // Nome e quantidade
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  startupName,
                  style: const TextStyle(fontFamily: 'Manrope', fontSize: 15, fontWeight: FontWeight.w600, color: kOnSurface),
                ),
                Text('$quantity tokens', style: const TextStyle(fontSize: 12, color: kOutline)),
              ],
            ),
          ),

          // Valor total investido
          Text(
            formatarMoeda(totalCents),
            style: const TextStyle(fontFamily: 'Manrope', fontSize: 15, fontWeight: FontWeight.w600, color: kOnSurface),
          ),
        ],
      ),
    );
  }
}