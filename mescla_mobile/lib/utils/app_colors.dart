// Autor: Alinne Monteiro de Melo
// RA: 24801649

// Cores e gradientes globais do app
// Importe esse arquivo em qualquer tela que precisar das cores

import 'package:flutter/material.dart';

const kPrimary   = Color(0xFF0035B9);
const kSecondary = Color(0xFF7E41AD);
const kSurface   = Color(0xFFF8F9FF);
const kOnSurface = Color(0xFF0B1C30);
const kOutline   = Color(0xFF747686);

const kGradient = LinearGradient(
  colors: [kPrimary, kSecondary],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);