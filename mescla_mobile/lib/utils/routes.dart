import 'package:flutter/material.dart';
import 'package:mescla_mobile/pages/carteira/carteira.dart';
import 'package:mescla_mobile/pages/startups/catalogoStartUp.dart';
import 'package:mescla_mobile/pages/balcão/balcao.dart';

Widget getTelaByIndex(int index) {
  switch (index) {
    case 0: return const CatalogoStartUp();
    case 1: return TradingPage();
    case 2: return const CarteiraScreen();
    default: return const SizedBox();
  }
}