// Autor: Alinne Monteiro de Melo 
// RA: 24801649

import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'register_screen.dart';


class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        // aplica um gradiente de fundo que vai do azul para o roxo
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF2148C6),
              Color(0xFF6F38C5),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              children: [
                const SizedBox(height: 50),

                // exibe o logo do app a partir da pasta assets
                Image.asset(
                  'assets/images/logoMescla.png',
                  height: 200,
                  fit: BoxFit.contain,
                ),

                const SizedBox(height: 50),

                // nome do app em destaque
                const Text(
                  'MesclaInvest',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 38,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 14),

                // slogan do app com opacidade reduzida para ficar mais suave
                Text(
                  'Startups, inovação e\noportunidades em um só lugar.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 18,
                  ),
                ),

                // empurra os botões para a parte de baixo da tela
                const Spacer(flex: 1),

                // botão de entrar que leva para a tela de login
                SizedBox(
                  width: double.infinity,
                  height: 65,
                  child: ElevatedButton(
                    onPressed: () {
                      // navega para a LoginScreen sem remover a tela atual da pilha
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const LoginScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40),
                      ),
                    ),
                    // Ink com gradiente branco para dar efeito de brilho no botão
                    child: Ink(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(40),
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFFFFFFFF),
                            Color(0xFFEDEBFF),
                          ],
                        ),
                      ),
                      child: Container(
                        alignment: Alignment.center,
                        child: const Text(
                          'Entrar',
                          style: TextStyle(
                            color: Color(0xFF1D44D5),
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                // botão de cadastrar que leva para a tela de cadastro
                SizedBox(
                  width: double.infinity,
                  height: 65,
                  child: ElevatedButton(
                    onPressed: () {
                      // navega para a CadastroScreen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CadastroScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40),
                      ),
                    ),
                    child: const Text(
                      'Cadastrar',
                      style: TextStyle(
                        fontSize: 22,
                        color: Color(0xFF1D44D5),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 45),
              ],
            ),
          ),
        ),
      ),
    );
  }
}