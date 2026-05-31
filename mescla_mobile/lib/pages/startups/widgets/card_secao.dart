// Autor: Bruna Barbour Fernandes
// RA: 23007950
import 'package:flutter/material.dart';

class CardSecao extends StatelessWidget {
  final Widget filho;
  final EdgeInsetsGeometry? padding;

  const CardSecao({
    super.key,
    required this.filho,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
      ),
      child: filho,
    );
  }
}
