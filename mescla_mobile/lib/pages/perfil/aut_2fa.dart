// Autor: Bruna Barbour Fernandes
// RA: 23007950

import 'package:flutter/material.dart';
import 'package:mescla_mobile/utils/app_colors.dart';
import '../../widgets/bottom_navBar.dart';

class Seguranca2FAPage extends StatefulWidget {
  const Seguranca2FAPage({super.key});

  @override
  State<Seguranca2FAPage> createState() => _Seguranca2FAPageState();
}

class _Seguranca2FAPageState extends State<Seguranca2FAPage> {
  bool twoFactorEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kSurface,
      bottomNavigationBar: const BottomNavBar(selectedIndex: 4),

      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // HEADER
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: kPrimary,
                        size: 22,
                      ),
                    ),

                    const SizedBox(width: 14),

                    const Expanded(
                      child: Text(
                        'Segurança',
                        style: TextStyle(
                          color: kPrimary,
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),

                    const Icon(
                      Icons.shield_outlined,
                      color: kPrimary,
                      size: 26,
                    ),
                  ],
                ),

                const SizedBox(height: 42),

                // TITULO
                const Text(
                  'Autenticação em\ndois fatores',
                  style: TextStyle(
                    color: kOnSurface,
                    fontSize: 32,
                    height: 1.15,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 18),

                // DESCRIÇÃO
                const Text(
                  'Ao ativar, enviaremos um código de segurança para seu e-mail sempre que houver uma tentativa de login.',
                  style: TextStyle(
                    color: kOutline,
                    fontSize: 16,
                    height: 1.6,
                  ),
                ),

                const SizedBox(height: 28),

                // CARD
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),

                  child: Row(
                    children: [

                      // ICONE
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE9EEFF),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Icon(
                          Icons.shield_outlined,
                          color: kPrimary,
                          size: 34,
                        ),
                      ),

                      const SizedBox(width: 18),

                      // TEXTO
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'STATUS ATUAL',
                              style: TextStyle(
                                color: kOutline,
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.5,
                              ),
                            ),

                            const SizedBox(height: 6),

                            Text(
                              twoFactorEnabled
                                  ? '2FA ativado'
                                  : '2FA desativado',
                              style: TextStyle(
                                color: twoFactorEnabled
                                    ? Colors.green
                                    : Colors.red,
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // SWITCH
                      Switch(
                        value: twoFactorEnabled,
                        activeColor: Colors.white,
                        activeTrackColor: kPrimary,
                        inactiveThumbColor: Colors.white,
                        inactiveTrackColor:
                        kOutline.withOpacity(0.35),
                        onChanged: (value) {
                          setState(() {
                            twoFactorEnabled = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}