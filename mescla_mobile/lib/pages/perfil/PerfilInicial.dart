// Autor: Bruna Barbour Fernandes
// RA: 23007950

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mescla_mobile/utils/app_colors.dart';
import 'package:mescla_mobile/pages/perfil/aut_2fa.dart';
import 'package:mescla_mobile/pages/perfil/alterar_senha.dart';
import 'package:mescla_mobile/pages/perfil/alterar_email.dart';
import 'package:mescla_mobile/pages/auth/welcome_screen.dart';
import '../../widgets/bottom_navBar.dart';
import 'package:mescla_mobile/services/perfil_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';

class PerfilPage extends StatefulWidget {
  const PerfilPage({super.key});

  @override
  State<PerfilPage> createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {
  bool editando = false;
  bool carregando = true;

  UserDetails? user;

  final UserService userService = UserService();
  final TextEditingController telefoneController = TextEditingController();

  File? imagemPerfil;
  final ImagePicker picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    carregarUsuario();
  }

  Future<void> carregarUsuario() async {
    try {
      final usuario = await userService.getUserDetails();

      setState(() {
        user = usuario;
        telefoneController.text = usuario.telefone;
        carregando = false;
      });
    } catch (e) {
      setState(() {
        carregando = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro ao carregar dados do usuário.'),
        ),
      );
    }
  }

  Future<void> selecionarImagem() async {
    try {
      final XFile? imagem = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (imagem == null) return;

      setState(() {
        imagemPerfil = File(imagem.path);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Foto alterada com sucesso!'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro ao selecionar imagem.'),
        ),
      );
    }
  }

  @override
  void dispose() {
    telefoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (carregando) {
      return const Scaffold(
        backgroundColor: kSurface,
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: kSurface,
      bottomNavigationBar: const BottomNavBar(selectedIndex: 4),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _Header(),

              const SizedBox(height: 36),

              Center(
                child: Column(
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 54,
                          backgroundColor: const Color(0xFFE5E7EB),
                          backgroundImage: imagemPerfil != null
                              ? FileImage(imagemPerfil!)
                              : null,
                          child: imagemPerfil == null
                              ? const Icon(
                            Icons.person,
                            size: 54,
                            color: Colors.grey,
                          )
                              : null,
                        ),

                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: selecionarImagem,
                            child: Container(
                              padding: const EdgeInsets.all(7),
                              decoration: const BoxDecoration(
                                color: kPrimary,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.edit,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 22),

                    Text(
                      user?.name ?? 'Usuário',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF111827),
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      user?.email ?? 'email não informado',
                      style: const TextStyle(
                        fontSize: 17,
                        color: kOutline,
                        letterSpacing: 0.3,
                      ),
                    ),

                    const SizedBox(height: 18),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      child: SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() {
                              editando = !editando;
                            });
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                              color: Color(0xFFB9C9F6),
                              width: 1.8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            editando ? 'Cancelar edição' : 'Editar perfil',
                            style: const TextStyle(
                              color: kPrimary,
                              fontSize: 17,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 36),

              _InfoCard(
                editando: editando,
                telefoneController: telefoneController,
                cpf: user?.cpf ?? 'CPF não informado',
                tipoConta: user?.isAdmin == true ? 'Administrador' : 'Investidor',
                onSalvar: () {
                  setState(() {
                    editando = false;
                  });
                },
              ),

              const SizedBox(height: 36),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 22),
                child: Text(
                  'Segurança',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF111827),
                  ),
                ),
              ),

              const SizedBox(height: 18),

              _SecurityCard(),

              const SizedBox(height: 42),

              Center(
                child: TextButton.icon(
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();

                    if (!context.mounted) return;

                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (_) => const WelcomeScreen(),
                      ),
                          (route) => false,
                    );
                  },
                  icon: const Icon(
                    Icons.logout,
                    color: Colors.red,
                    size: 22,
                  ),
                  label: const Text(
                    'Sair da conta',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 16,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 42),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final bool editando;
  final TextEditingController telefoneController;
  final String cpf;
  final String tipoConta;
  final VoidCallback onSalvar;

  const _InfoCard({
    required this.editando,
    required this.telefoneController,
    required this.cpf,
    required this.tipoConta,
    required this.onSalvar,
  });

  String formatarCpf(String cpf) {
    final numeros = cpf.replaceAll(RegExp(r'[^0-9]'), '');

    if (numeros.length != 11) {
      return cpf;
    }

    return '${numeros.substring(0, 3)}.'
        '${numeros.substring(3, 6)}.'
        '${numeros.substring(6, 9)}-'
        '${numeros.substring(9, 11)}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 18),
      padding: const EdgeInsets.fromLTRB(28, 28, 28, 24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.82),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'INFORMAÇÕES DA CONTA',
              style: TextStyle(
                color: kOutline,
                fontSize: 15,
                letterSpacing: 4,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          const SizedBox(height: 24),

          _InfoRow(
            label: 'CPF',
            value: formatarCpf(cpf),
          ),

          editando
              ? _EditableInfoRow(
            label: 'Telefone',
            controller: telefoneController,
          )
              : _InfoRow(
            label: 'Telefone',
            value: telefoneController.text.isEmpty
                ? 'Telefone não informado'
                : telefoneController.text,
          ),

          _InfoRow(
            label: 'Tipo de conta',
            value: tipoConta,
          ),

          if (editando) ...[
            const SizedBox(height: 22),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: onSalvar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Salvar alterações',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _EditableInfoRow extends StatelessWidget {
  final String label;
  final TextEditingController controller;

  const _EditableInfoRow({
    required this.label,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: label,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),

        const Padding(
          padding: EdgeInsets.symmetric(vertical: 15),
          child: Divider(
            height: 1,
            color: Color(0xFFE5E7EB),
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;
  final Color? valueColor;
  final bool showDivider;

  const _InfoRow({
    required this.label,
    required this.value,
    this.icon,
    this.valueColor,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                color: kOutline,
                fontSize: 16,
              ),
            ),

            const Spacer(),

            if (icon != null) ...[
              Icon(
                icon,
                color: kPrimary,
                size: 19,
              ),

              const SizedBox(width: 5),
            ],

            Flexible(
              child: Text(
                value,
                textAlign: TextAlign.right,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: valueColor ?? Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),

        if (showDivider)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 15),
            child: Divider(
              height: 1,
              color: Color(0xFFE5E7EB),
            ),
          ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFE5E7EB),
            width: 1,
          ),
        ),
      ),
      child: const Row(
        children: [
          SizedBox(width: 8),

          Text(
            'MesclaInvest',
            style: TextStyle(
              color: kPrimary,
              fontSize: 27,
              fontWeight: FontWeight.w700,
            ),
          ),

          Spacer(),
        ],
      ),
    );
  }
}

class _SecurityCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 18),
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 16,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.82),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _SecurityItem(
            icon: Icons.lock_outline,
            title: 'Alterar senha',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AlterarSenhaPage(),
                ),
              );
            },
          ),

          _SecurityItem(
            icon: Icons.email_outlined,
            title: 'Alterar email',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AlterarEmailPage(),
                ),
              );
            },
          ),

          _SecurityItem(
            icon: Icons.shield_outlined,
            title: 'Autenticação em dois fatores',
            showDivider: false,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const Seguranca2FAPage(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SecurityItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool showDivider;
  final VoidCallback? onTap;

  const _SecurityItem({
    required this.icon,
    required this.title,
    this.showDivider = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFE7EEFF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFF6B7280),
                  size: 24,
                ),
              ),

              const SizedBox(width: 18),

              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF111827),
                    fontSize: 17,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0.3,
                  ),
                ),
              ),

              const Icon(
                Icons.chevron_right,
                color: Color(0xFF6B7280),
                size: 30,
              ),
            ],
          ),

          if (showDivider)
            const Padding(
              padding: EdgeInsets.only(
                left: 62,
                top: 16,
                bottom: 16,
              ),
              child: Divider(
                height: 1,
                color: Color(0xFFE5E7EB),
              ),
            ),
        ],
      ),
    );
  }
}