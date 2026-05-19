// Autor: Alinne Monteiro de Melo
// RA: 24801649

import 'package:flutter/material.dart';
import 'package:mescla_mobile/utils/app_colors.dart';

class TransacoesSection extends StatelessWidget {
  const TransacoesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Histórico de transações',
          style: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: kOnSurface,
          ),
        ),
        const SizedBox(height: 12),
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
                Icon(Icons.receipt_long_outlined, size: 40, color: kOutline.withOpacity(0.5)),
                const SizedBox(height: 12),
                const Text(
                  'Nenhuma transação ainda',
                  style: TextStyle(fontWeight: FontWeight.w600, color: kOnSurface),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Suas compras e vendas de tokens aparecerão aqui.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: kOutline),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}