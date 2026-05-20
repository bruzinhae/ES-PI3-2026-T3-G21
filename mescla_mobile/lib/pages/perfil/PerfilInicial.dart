import 'package:flutter/material.dart';
import 'package:mescla_mobile/utils/app_colors.dart';
import 'package:mescla_mobile/pages/perfil/aut_2fa.dart';
import 'package:mescla_mobile/pages/perfil/alterar_email.dart';
import 'package:mescla_mobile/pages/perfil/alterar_senha.dart';
import '../../widgets/bottom_navBar.dart';

class PerfilPage extends StatelessWidget {
  const PerfilPage({super.key});

  @override
  Widget build(BuildContext context) {
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
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 108,
                          height: 108,
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.16),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: const CircleAvatar(
                            backgroundColor: Color(0xFFE5E7EB),
                            child: Icon(
                              Icons.person,
                              size: 54,
                              color: Colors.grey,
                            ),
                          ),
                        ),

                        Positioned(
                          right: -2,
                          bottom: 8,
                          child: Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: kSecondary,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 3,
                              ),
                            ),
                            child: const Icon(
                              Icons.edit,
                              color: Colors.white,
                              size: 21,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 22),

                    const Text(
                      'João Silva',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF111827),
                      ),
                    ),

                    const SizedBox(height: 4),

                    const Text(
                      'joao.silva@email.com',
                      style: TextStyle(
                        fontSize: 17,
                        color: kOutline,
                        letterSpacing: 0.3,
                      ),
                    ),

                    const SizedBox(height: 14),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE1E7FF),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Text(
                        'INVESTIDOR',
                        style: TextStyle(
                          color: kPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          letterSpacing: 2,
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      child: SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                              color: Color(0xFFB9C9F6),
                              width: 1.8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Editar perfil',
                            style: TextStyle(
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

              const _InfoCard(),

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
                  onPressed: () {},
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

              const Center(
                child: Text(
                  'Versão 2.4.0 • MesclaInvest LTDA',
                  style: TextStyle(
                    color: kOutline,
                    fontSize: 13,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
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
          Icon(
            Icons.notifications_none,
            color: Color(0xFF6B7280),
            size: 26,
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 18),
      padding: const EdgeInsets.fromLTRB(28, 28, 28, 24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.82),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Column(
        children: [
          Align(
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

          SizedBox(height: 24),

          _InfoRow(
            label: 'CPF',
            value: '***.456.***-00',
          ),

          _InfoRow(
            label: 'Telefone',
            value: '(11) 98765-4321',
          ),

          _InfoRow(
            label: 'Tipo de conta',
            value: 'Investidor',
          ),

          _InfoRow(
            label: 'Status',
            value: 'Verificada',
            icon: Icons.verified_outlined,
            valueColor: kPrimary,
            showDivider: false,
          ),
        ],
      ),
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
                letterSpacing: 0.5,
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

            Text(
              value,
              style: TextStyle(
                color: valueColor ?? Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.w500,
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
            icon: Icons.shield_outlined,
            title: 'Autenticação em dois fatores',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const Seguranca2FAPage(),
                ),
              );
            },
          ),

          _SecurityItem(
            icon: Icons.email_outlined,
            title: 'E-mail verificado',
            showDivider: false,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AlterarEmailPage(),
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
  final String? subtitle;
  final bool checked;
  final bool showDivider;
  final VoidCallback? onTap;

  const _SecurityItem({
    required this.icon,
    required this.title,
    this.subtitle,
    this.checked = false,
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
                  color: checked
                      ? kPrimary
                      : const Color(0xFF6B7280),
                  size: 24,
                ),
              ),

              const SizedBox(width: 18),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Color(0xFF111827),
                        fontSize: 17,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.3,
                      ),
                    ),

                    if (subtitle != null) ...[
                      const SizedBox(height: 4),

                      Text(
                        subtitle!,
                        style: const TextStyle(
                          color: kPrimary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              Icon(
                checked
                    ? Icons.check_circle_outline
                    : Icons.chevron_right,
                color: checked
                    ? kPrimary
                    : const Color(0xFF6B7280),
                size: checked ? 27 : 30,
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