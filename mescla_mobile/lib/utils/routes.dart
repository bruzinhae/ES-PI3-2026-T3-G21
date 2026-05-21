import 'package:flutter/material.dart';
import 'package:mescla_mobile/pages/carteira/carteira.dart';
import 'package:mescla_mobile/pages/startups/catalogoStartUp.dart';
import 'package:mescla_mobile/pages/balcão/balcao.dart';
import 'package:mescla_mobile/pages/perfil/PerfilInicial.dart';
import 'package:mescla_mobile/pages/dashboard/dashboard.dart';


Widget getTelaByIndex(int index) {
  switch (index) {
    case 0:
      return const CatalogoStartUp();
    case 1:
      return TradingPage();
    case 2:
      return const CarteiraScreen();
    case 3:
      return const DashboardScreen();
    case 4:
      return const PerfilPage();
    default:
      return const CatalogoStartUp();
  }
}
