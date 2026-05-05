// Autor: Alinne Monteiro de Melo
// RA: 24801649
import 'package:flutter/material.dart';

// cores
const kPrimary   = Color(0xFF0035B9);
const kSecondary = Color(0xFF7E41AD);
const kSurface   = Color(0xFFF8F9FF);
const kOnSurface = Color(0xFF0B1C30);
const kOutline   = Color(0xFF747686);

const kGradient = LinearGradient(
  colors: [kPrimary, kSecondary],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

// tela carteira
class CarteiraScreen extends StatefulWidget {
  const CarteiraScreen({super.key});

  @override
  State<CarteiraScreen> createState() => _CarteiraScreenState();
}

class _CarteiraScreenState extends State<CarteiraScreen> {
  int _navIndex = 2;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kSurface,
      extendBody: true,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            SaldoCard(),
            SizedBox(height: 28),
            StartupsSection(),
            SizedBox(height: 28),
            TransacoesSection(),
          ],
        ),
      ),
      bottomNavigationBar: _buildNavBar(),
    );
  }

  // appbar
  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(64),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.85),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              children: [
                
                const SizedBox(width: 12),
                const Text(
                  'Carteira',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E3A8A),
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Bottom Nav Bar
  Widget _buildNavBar() {
    final items = [
      {'icon': Icons.grid_view_rounded,              'label': 'Catálogo'},
      {'icon': Icons.swap_horiz_rounded,             'label': 'Negociar'},
      {'icon': Icons.account_balance_wallet_rounded, 'label': 'Carteira'},
      {'icon': Icons.dashboard_rounded,              'label': 'Dashboard'},
      {'icon': Icons.person_rounded,                 'label': 'Perfil'},
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (i) {
              final selected = i == _navIndex;
              return GestureDetector(
                onTap: () => setState(() => _navIndex = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: selected ? const Color(0xFFEFF6FF) : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        items[i]['icon'] as IconData,
                        size: 24,
                        color: selected ? kPrimary : Colors.blueGrey,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        items[i]['label'] as String,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: selected ? kPrimary : Colors.blueGrey,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

// card de saldo
class SaldoCard extends StatelessWidget {
  const SaldoCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: kGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: kPrimary.withOpacity(0.3),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Saldo disponível',
            style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 4),
          const Text(
            'R\$ 10.000,00',
            style: TextStyle(
              fontFamily: 'Manrope',
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 20),
          Divider(color: Colors.white.withOpacity(0.2), height: 1),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _coluna('Total investido',    'R\$ 45.250,00')),
              Expanded(child: _coluna('Valor atual tokens', 'R\$ 48.120,45')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _coluna(String label, String value) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 11, fontWeight: FontWeight.w600)),
      const SizedBox(height: 4),
      Text(value, style: const TextStyle(fontFamily: 'Manrope', color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600)),
    ],
  );
}

// seção Minhas Startups
class StartupsSection extends StatelessWidget {
  const StartupsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Minhas Startups', style: TextStyle(fontFamily: 'Manrope', fontSize: 20, fontWeight: FontWeight.w700, color: kOnSurface)),
            TextButton(onPressed: () {}, child: const Text('Ver tudo', style: TextStyle(color: kPrimary))),
          ],
        ),
        const SizedBox(height: 12),
        StartupCard(
          icon: Icons.rocket_launch_rounded,
          iconColor: kPrimary,
          name: 'EcoStream Tech',
          tokens: '50 tokens',
          value: 'R\$ 2.500,00',
          change: '+5.2%',
        ),
        const SizedBox(height: 12),
        StartupCard(
          icon: Icons.health_and_safety_rounded,
          iconColor: kSecondary,
          name: 'MediCore AI',
          tokens: '120 tokens',
          value: 'R\$ 6.120,00',
          change: '+12.8%',
        ),
      ],
    );
  }
}

// card de startup
class StartupCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String name;
  final String tokens;
  final String value;
  final String change;

  const StartupCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.name,
    required this.tokens,
    required this.value,
    required this.change,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.4)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 2))],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              // Ícone
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 6)],
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 12),
              // Nome e tokens
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: const TextStyle(fontFamily: 'Manrope', fontSize: 15, fontWeight: FontWeight.w600, color: kOnSurface)),
                    Text(tokens, style: const TextStyle(fontSize: 12, color: kOutline)),
                  ],
                ),
              ),
              // Valor e variação
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(value, style: const TextStyle(fontFamily: 'Manrope', fontSize: 15, fontWeight: FontWeight.w600, color: kOnSurface)),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(color: const Color(0xFFECFDF5), borderRadius: BorderRadius.circular(99)),
                    child: Text(change, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF059669))),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Botões
          Row(
            children: [
              Expanded(child: _GradientButton(label: 'Comprar', onTap: () {})),
              const SizedBox(width: 8),
              Expanded(child: _OutlineButton(label: 'Vender', onTap: () {})),
            ],
          ),
        ],
      ),
    );
  }
}

// botões reutilizáveis
class _GradientButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _GradientButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          decoration: BoxDecoration(gradient: kGradient, borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Center(child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600))),
        ),
      ),
    );
  }
}

class _OutlineButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _OutlineButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: kPrimary.withOpacity(0.25), width: 1.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(child: Text(label, style: const TextStyle(color: kPrimary, fontSize: 14, fontWeight: FontWeight.w600))),
      ),
    );
  }
}

// seção Histórico de Transações
class TransacoesSection extends StatelessWidget {
  const TransacoesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final transacoes = [
      _Transacao(icon: Icons.shopping_cart_rounded, isBuy: true,  title: 'Compra - EcoStream',   date: '12 OUT 2023', amount: '- R\$ 500,00',   tokens: '10 tokens'),
      _Transacao(icon: Icons.sell_rounded,          isBuy: false, title: 'Venda - SolarFlow',    date: '08 OUT 2023', amount: '+ R\$ 1.250,00', tokens: '25 tokens'),
      _Transacao(icon: Icons.shopping_cart_rounded, isBuy: true,  title: 'Compra - MediCore AI', date: '02 OUT 2023', amount: '- R\$ 2.100,00', tokens: '40 tokens'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Histórico de transações', style: TextStyle(fontFamily: 'Manrope', fontSize: 20, fontWeight: FontWeight.w700, color: kOnSurface)),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.7),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.4)),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 2))],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Column(
              children: [
                for (int i = 0; i < transacoes.length; i++) ...[
                  _TransacaoItem(data: transacoes[i]),
                  if (i < transacoes.length - 1)
                    Divider(height: 1, color: Colors.white.withOpacity(0.5)),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Transacao {
  final IconData icon;
  final bool isBuy;
  final String title;
  final String date;
  final String amount;
  final String tokens;

  const _Transacao({
    required this.icon,
    required this.isBuy,
    required this.title,
    required this.date,
    required this.amount,
    required this.tokens,
  });
}

class _TransacaoItem extends StatelessWidget {
  final _Transacao data;

  const _TransacaoItem({required this.data});

  @override
  Widget build(BuildContext context) {
    final color = data.isBuy ? const Color(0xFF059669) : const Color(0xFF2563EB);
    final bg    = data.isBuy ? const Color(0xFFECFDF5) : const Color(0xFFEFF6FF);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
            child: Icon(data.icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(data.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: kOnSurface)),
                Text(data.date,  style: const TextStyle(fontSize: 10, color: kOutline, fontWeight: FontWeight.w600, letterSpacing: 0.8)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(data.amount, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: color)),
              Text(data.tokens, style: const TextStyle(fontSize: 10, color: kOutline)),
            ],
          ),
        ],
      ),
    );
  }
}