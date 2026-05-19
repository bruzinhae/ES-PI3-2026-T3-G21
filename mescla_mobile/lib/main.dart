
// Autor: Alinne Monteiro de Melo
// RA: 24801649

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'pages/balcão/balcao.dart';
import 'pages/auth/welcome_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  runApp(const MesclaInvestApp());
}

class MesclaInvestApp extends StatelessWidget {
  const MesclaInvestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MesclaInvest',
      theme: ThemeData(
        fontFamily: 'WorkSans',
        scaffoldBackgroundColor: const Color(0xFFF8F9FF),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0035B9),
          primary: const Color(0xFF0035B9),
          secondary: const Color(0xFF7E41AD),
          surface: const Color(0xFFF8F9FF),
        ),
        useMaterial3: true,
      ),

      home: const WelcomeScreen(),
    );
  }
}