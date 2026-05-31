// Autor: Bruna Barbour Fernandes
// RA: 23007950
import 'package:flutter/material.dart';

class CardInfo extends StatelessWidget {
  final String titulo;
  final String valor;
  final IconData? icone;
  final Color? cor;

  const CardInfo({
    super.key,
    required this.titulo,
    required this.valor,
    this.icone,
    this.cor,
  });

  @override
  Widget build(BuildContext context) {
    final corPrincipal = cor ?? const Color(0xFF0B1C30);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F6FF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE1E6F5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icone != null) ...[
            Icon(
              icone,
              size: 18,
              color: corPrincipal.withOpacity(0.8),
            ),
            const SizedBox(height: 6),
          ],

          Text(
            titulo.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: Color(0xFF747686),
            ),
          ),

          const Spacer(),

          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              valor,
              maxLines: 1,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: corPrincipal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}