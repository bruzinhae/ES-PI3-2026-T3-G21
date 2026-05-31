// Autor: Bruna Barbour Fernandes
// RA: 23007950
import 'package:flutter/material.dart';

class CabecalhoStartup extends StatelessWidget {
  final String nome;
  final String subtitulo;
  final IconData icone;
  final Widget? status;

  const CabecalhoStartup({
    super.key,
    required this.nome,
    required this.subtitulo,
    required this.icone,
    this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFF0D2CC8),
                Color(0xFF8D35E6),
              ],
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            icone,
            color: Colors.white,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                nome,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                subtitulo,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF0D2CC8),
                ),
              ),
            ],
          ),
        ),
        if (status != null) status!,
      ],
    );
  }
}
