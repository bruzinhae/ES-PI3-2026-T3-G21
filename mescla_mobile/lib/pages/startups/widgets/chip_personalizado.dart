// Autor: Bruna Barbour Fernandes
// RA: 23007950
import 'package:flutter/material.dart';

class ChipPersonalizado extends StatelessWidget {
  final String texto;
  final bool selecionado;
  final VoidCallback? aoTocar;

  const ChipPersonalizado({
    super.key,
    required this.texto,
    this.selecionado = false,
    this.aoTocar,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: aoTocar,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          gradient: selecionado
              ? const LinearGradient(
                  colors: [
                    Color(0xFF0D2CC8),
                    Color(0xFF8D35E6),
                  ],
                )
              : null,
          color: selecionado ? null : const Color(0xFFDDE8FF),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          texto,
          style: TextStyle(
            color: selecionado ? Colors.white : const Color(0xFF0D2CC8),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
