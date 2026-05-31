// Autor: Bruna Barbour Fernandes
// RA: 23007950
import 'package:flutter/material.dart';

class BotaoGradiente extends StatelessWidget {
  final String texto;
  final VoidCallback aoPressionar;
  final double altura;

  const BotaoGradiente({
    super.key,
    required this.texto,
    required this.aoPressionar,
    this.altura = 58,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: aoPressionar,
      child: Container(
        width: double.infinity,
        height: altura,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: const LinearGradient(
            colors: [
              Color(0xFF0D2CC8),
              Color(0xFF8D35E6),
            ],
          ),
        ),
        child: Center(
          child: Text(
            texto,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
