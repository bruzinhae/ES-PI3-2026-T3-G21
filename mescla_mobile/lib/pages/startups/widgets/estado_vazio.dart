// Autor: Bruna Barbour Fernandes
// RA: 23007950
import 'package:flutter/material.dart';

class EstadoVazio extends StatelessWidget {
  final String mensagem;

  const EstadoVazio({
    super.key,
    required this.mensagem,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Text(
          mensagem,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF4B5563),
          ),
        ),
      ),
    );
  }
}
