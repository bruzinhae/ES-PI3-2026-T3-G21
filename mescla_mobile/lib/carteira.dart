// Autor: Alinne Monteiro de Melo
// RA: 24801649

import 'package:flutter/material.dart';
import 'package:mescla_mobile/widgets/carregarSaldo_modal.dart';

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

class CarteiraScreen extends StatefulWidget {
  const CarteiraScreen({super.key});

  @override
  State<CarteiraScreen> createState() => _CarteiraScreenState();
}

class _CarteiraScreenState extends State<CarteiraScreen> {
  int _navIndex = 2;

  // estado financeiro do usuario
  double _saldo         = 0; // saldo disponível em reais
  double _totalInvestido = 0; // soma de todas as compras de tokens
  double _valorTokens    = 0; // valor atual dos tokens em carteira

  // modal de carregar saldo
  void _aoCarregarSaldo(double valorAdicionado) {
    setState(() {
      _saldo += valorAdicionado;
    });
  }

  // chama quando o usuário compra tokens
  void _aoComprarTokens(double valorGasto, double valorAtualTokens) {
    setState(() {
      _saldo         -= valorGasto;
      _totalInvestido += valorGasto;
      _valorTokens    += valorAtualTokens;
    });
  }

  // chama quando o usuário vende tokens
  // 
  void _aoVenderTokens(double valorRecebido, double valorTokensVendidos) {
    setState(() {
      _saldo       += valorRecebido;
      _valorTokens -= valorTokensVendidos;
    });
  }

  String _fmt(double valor) {
    final partes = valor.toStringAsFixed(2).split('.');
    final inteiro = partes[0].replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
    return 'R\$ $inteiro,${partes[1]}';
  }

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
          children: [
            SaldoCard(
              saldo:          _fmt(_saldo),
              totalInvestido: _fmt(_totalInvestido),
              valorTokens:    _fmt(_valorTokens),
            ),
            const SizedBox(height: 16),

            // Botão carregar saldo
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => showCarregarSaldoModal(
                  context,
                  onConfirmar: _aoCarregarSaldo,
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: kPrimary,
                  side: const BorderSide(color: kPrimary, width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('Carregar Saldo', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),

            const SizedBox(height: 28),
            const StartupsSection(),
            const SizedBox(height: 28),
            const TransacoesSection(),
          ],
        ),
      ),
      bottomNavigationBar: _buildNavBar(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(64),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.85),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              children: [
                const SizedBox(width: 12),
                const Text(
                  'Carteira',
                  style: TextStyle(fontFamily: 'Manrope', fontSize: 22, fontWeight: FontWeight.w700, color: Color(0xFF1E3A8A)),
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }

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
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -4))],
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
                      Icon(items[i]['icon'] as IconData, size: 24, color: selected ? kPrimary : Colors.blueGrey),
                      const SizedBox(height: 4),
                      Text(
                        items[i]['label'] as String,
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: selected ? kPrimary : Colors.blueGrey),
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
  final String saldo;
  final String totalInvestido;
  final String valorTokens;

  const SaldoCard({
    super.key,
    required this.saldo,
    required this.totalInvestido,
    required this.valorTokens,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: kGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: kPrimary.withOpacity(0.3), blurRadius: 24, offset: const Offset(0, 8))],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Saldo disponível', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14, fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Text(
            saldo,
            style: const TextStyle(fontFamily: 'Manrope', color: Colors.white, fontSize: 36, fontWeight: FontWeight.w700, letterSpacing: -0.5),
          ),
          const SizedBox(height: 20),
          Divider(color: Colors.white.withOpacity(0.2), height: 1),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _coluna('Total investido',    totalInvestido)),
              Expanded(child: _coluna('Valor atual tokens', valorTokens)),
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
        // se o usuário não tem tokens ainda
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.7),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.4)),
          ),
          child: Center(
            child: Column(
              children: [
                Icon(Icons.rocket_launch_outlined, size: 40, color: kOutline.withOpacity(0.5)),
                const SizedBox(height: 12),
                const Text(
                  'Você ainda não tem tokens',
                  style: TextStyle(fontWeight: FontWeight.w600, color: kOnSurface),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Explore o catálogo e faça seu primeiro investimento!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: kOutline),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// seção Histórico de Transações
class TransacoesSection extends StatelessWidget {
  const TransacoesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Histórico de transações', style: TextStyle(fontFamily: 'Manrope', fontSize: 20, fontWeight: FontWeight.w700, color: kOnSurface)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.7),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.4)),
          ),
          child: Center(
            child: Column(
              children: [
                Icon(Icons.receipt_long_outlined, size: 40, color: kOutline.withOpacity(0.5)),
                const SizedBox(height: 12),
                const Text(
                  'Nenhuma transação ainda',
                  style: TextStyle(fontWeight: FontWeight.w600, color: kOnSurface),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Suas compras e vendas de tokens aparecerão aqui.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: kOutline),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}