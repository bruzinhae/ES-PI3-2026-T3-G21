import 'package:flutter/material.dart';
import 'balcao.dart';

void main() {
  runApp(const MesclaInvestApp());
}

class MesclaInvestApp extends StatelessWidget {
  const MesclaInvestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MesclaInvest',
      home: balcao(),
    );
  }
}