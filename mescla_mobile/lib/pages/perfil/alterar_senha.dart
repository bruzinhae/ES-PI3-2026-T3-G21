// Autor: Bruna Barbour Fernandes
// RA: 23007950

import 'package:flutter/material.dart';
import 'package:mescla_mobile/utils/app_colors.dart';
import '../../widgets/bottom_navBar.dart';

class AlterarSenhaPage extends StatefulWidget {
  const AlterarSenhaPage({super.key});

  @override
  State<AlterarSenhaPage> createState() => _AlterarSenhaPageState();
}

class _AlterarSenhaPageState extends State<AlterarSenhaPage> {
  final senhaAtualController = TextEditingController();
  final novaSenhaController = TextEditingController();
  final confirmarSenhaController = TextEditingController();

  bool mostrarSenhaAtual = false;
  bool mostrarNovaSenha = false;
  bool mostrarConfirmarSenha = false;

  @override
  void dispose() {
    senhaAtualController.dispose();
    novaSenhaController.dispose();
    confirmarSenhaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kSurface,
      bottomNavigationBar: const BottomNavBar(selectedIndex: 4),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 18, 22, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _topBar(context),

              const SizedBox(height: 46),

              const Text(
                'Alterar senha',
                style: TextStyle(
                  color: kOnSurface,
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 12),

              const Text(
                'Mantenha sua conta protegida atualizando sua senha regularmente.',
                style: TextStyle(
                  color: kOutline,
                  fontSize: 16,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 34),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(26, 28, 26, 28),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: kOutline.withOpacity(0.12),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _label('Senha atual'),
                    const SizedBox(height: 10),
                    _passwordField(
                      controller: senhaAtualController,
                      hint: 'Digite sua senha atual',
                      visible: mostrarSenhaAtual,
                      onToggle: () {
                        setState(() {
                          mostrarSenhaAtual = !mostrarSenhaAtual;
                        });
                      },
                    ),

                    const SizedBox(height: 24),

                    _label('Nova senha'),
                    const SizedBox(height: 10),
                    _passwordField(
                      controller: novaSenhaController,
                      hint: 'Mínimo 6 caracteres',
                      visible: mostrarNovaSenha,
                      onToggle: () {
                        setState(() {
                          mostrarNovaSenha = !mostrarNovaSenha;
                        });
                      },
                    ),

                    const SizedBox(height: 24),

                    _label('Confirmar nova senha'),
                    const SizedBox(height: 10),
                    _passwordField(
                      controller: confirmarSenhaController,
                      hint: 'Repita a nova senha',
                      visible: mostrarConfirmarSenha,
                      onToggle: () {
                        setState(() {
                          mostrarConfirmarSenha = !mostrarConfirmarSenha;
                        });
                      },
                    ),

                    const SizedBox(height: 34),

                    GestureDetector(
                      onTap: () {},
                      child: Container(
                        width: double.infinity,
                        height: 62,
                        decoration: BoxDecoration(
                          gradient: kGradient,
                          borderRadius: BorderRadius.circular(32),
                          boxShadow: [
                            BoxShadow(
                              color: kPrimary.withOpacity(0.18),
                              blurRadius: 18,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text(
                            'Salvar nova senha',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _topBar(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(
            Icons.arrow_back,
            color: kPrimary,
            size: 30,
          ),
        ),
        const Expanded(
          child: Center(
            child: Text(
              'Segurança',
              style: TextStyle(
                color: kPrimary,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
        const SizedBox(width: 30),
      ],
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: kOnSurface,
        fontSize: 16,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _passwordField({
    required TextEditingController controller,
    required String hint,
    required bool visible,
    required VoidCallback onToggle,
  }) {
    return TextField(
      controller: controller,
      obscureText: !visible,
      style: const TextStyle(
        color: kOnSurface,
        fontSize: 17,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: kOnSurface.withOpacity(0.85),
          fontSize: 17,
          fontWeight: FontWeight.w500,
        ),
        suffixIcon: IconButton(
          onPressed: onToggle,
          icon: Icon(
            visible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            color: kOutline,
            size: 26,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 26,
          vertical: 18,
        ),
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(
            color: kOutline.withOpacity(0.25),
          ),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(30)),
          borderSide: BorderSide(
            color: kPrimary,
            width: 1.5,
          ),
        ),
      ),
    );
  }
}