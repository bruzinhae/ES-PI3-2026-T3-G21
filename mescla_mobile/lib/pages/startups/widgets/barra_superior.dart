// Autor: Bruna Barbour Fernandes
// RA: 23007950

import 'package:flutter/material.dart';

class BarraSuperiorMescla extends StatelessWidget {
  final VoidCallback? aoVoltar;
  final bool mostrarFavorito;

  const BarraSuperiorMescla({
    super.key,
    this.aoVoltar,
    this.mostrarFavorito = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (aoVoltar != null) ...[
          GestureDetector(
            onTap: aoVoltar,
            child: const Icon(
              Icons.arrow_back,
              color: Color(0xFF0D2CC8),
              size: 22,
            ),
          ),
          const SizedBox(width: 18),
        ],
        const Expanded(
          child: Text(
            'MesclaInvest',
            style: TextStyle(
              color: Color(0xFF0D2CC8),
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        if (mostrarFavorito)
          const Icon(
            Icons.favorite_border,
            color: Color(0xFF0D2CC8),
            size: 24,
          ),
      ],
    );
  }
}
