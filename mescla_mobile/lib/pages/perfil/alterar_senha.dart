// Autor: Bruna Barbour Fernandes
// RA: 23007950

import 'package:flutter/material.dart';
import 'package:mescla_mobile/utils/app_colors.dart';
import '../../widgets/bottom_navBar.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
  bool carregando = false;

  @override
  void dispose() {
    senhaAtualController.dispose();
    novaSenhaController.dispose();
    confirmarSenhaController.dispose();
    super.dispose();
  }

  Future<void> alterarSenha() async {
    final senhaAtual = senhaAtualController.text.trim();
    final novaSenha = novaSenhaController.text.trim();
    final confirmarSenha = confirmarSenhaController.text.trim();

    if (senhaAtual.isEmpty || novaSenha.isEmpty || confirmarSenha.isEmpty) {
      mostrarMensagem('Preencha todos os campos.');
      return;
    }

    if (novaSenha.length < 6) {
      mostrarMensagem('A nova senha precisa ter pelo menos 6 caracteres.');
      return;
    }

    if (novaSenha != confirmarSenha) {
      mostrarMensagem('As senhas não são iguais.');
      return;
    }

    if (senhaAtual == novaSenha) {
      mostrarMensagem('A nova senha precisa ser diferente da senha atual.');
      return;
    }

    setState(() {
      carregando = true;
    });

    try {
      final usuario = FirebaseAuth.instance.currentUser;

      if (usuario == null || usuario.email == null) {
        mostrarMensagem('Usuário não encontrado.');
        return;
      }

      final credencial = EmailAuthProvider.credential(
        email: usuario.email!,
        password: senhaAtual,
      );

      await usuario.reauthenticateWithCredential(credencial);

      await usuario.updatePassword(novaSenha);

      senhaAtualController.clear();
      novaSenhaController.clear();
      confirmarSenhaController.clear();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Senha alterada com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        mostrarMensagem('Senha atual incorreta.');
      } else if (e.code == 'weak-password') {
        mostrarMensagem('A nova senha é muito fraca.');
      } else if (e.code == 'requires-recent-login') {
        mostrarMensagem('Faça login novamente para alterar a senha.');
      } else {
        mostrarMensagem('Erro ao alterar senha: ${e.message}');
      }
    } catch (e) {
      mostrarMensagem('Erro inesperado ao alterar senha.');
    } finally {
      if (mounted) {
        setState(() {
          carregando = false;
        });
      }
    }
  }

  void mostrarMensagem(String mensagem) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: Colors.red,
      ),
    );
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
                      onTap: carregando ? null : alterarSenha,
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
                        child: Center(
                          child: carregando
                              ? const CircularProgressIndicator(
                            color: Colors.white,
                          )
                              : const Text(
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