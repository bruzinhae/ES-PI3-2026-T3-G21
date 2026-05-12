// Autor: Bruna Barbour Fernandes
// RA: 23007950

import 'package:flutter/material.dart';
import 'services/resgate_service.dart';
import 'balcao.dart';
import 'catalogoStartUp.dart';

const kPrimary = Color(0xFF0035B9);

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
      home: const ConfirmacaoPage(),
    );
  }
}

class ConfirmacaoPage extends StatefulWidget {
  const ConfirmacaoPage({super.key});

  @override
  State<ConfirmacaoPage> createState() => _ConfirmacaoPageState();
}

class _ConfirmacaoPageState extends State<ConfirmacaoPage> {
  final ResgateService _resgateService = ResgateService();
  final TextEditingController _valorController = TextEditingController();

  double saldoTotal = 15420.00;
  double saldoDisponivel = 1240.00;
  int totalTokens = 850;
  int _navIndex = 1;

  @override
  void dispose() {
    _valorController.dispose();
    super.dispose();
  }

  String formatCurrency(double value) {
    return 'R\$ ${value.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  void _resgatarTudo() {
    _valorController.text = saldoDisponivel.toStringAsFixed(2);
  }

  void _confirmarResgate() {
    final valor = double.tryParse(
      _valorController.text.replaceAll(',', '.'),
    ) ??
        0;

    final erro = _resgateService.validarResgate(
      valor: valor,
      saldoDisponivel: saldoDisponivel,
    );

    if (erro != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(erro), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() {
      saldoDisponivel = _resgateService.calcularNovoSaldo(
        saldoAtual: saldoDisponivel,
        valorResgate: valor,
      );
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Resgate de ${formatCurrency(valor)} solicitado com sucesso!',
        ),
        backgroundColor: Colors.green,
      ),
    );

    _valorController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEDEFF5),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _topBar(),
              const SizedBox(height: 16),
              const Text(
                "Resgatar Lucros",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Gerencie seus rendimentos e solicite resgates.",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 20),
              _saldoCard(),
              const SizedBox(height: 18),
              _disponivelCard(),
              const SizedBox(height: 18),
              _contaCard(),
              const SizedBox(height: 18),
              _resgateCard(),
              const SizedBox(height: 18),
              _historicoCard(),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildNavBar(),
    );
  }

  Widget _topBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: const [
        Text(
          "MesclaInvest",
          style: TextStyle(
            color: Color(0xFF3D5AFE),
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _saldoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF3D5AFE),
            Color(0xFF7B1FA2),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "SALDO TOTAL",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            formatCurrency(saldoTotal),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "$totalTokens tokens disponíveis na carteira",
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _disponivelCard() {
    return _card(
      child: Row(
        children: [
          _iconBox(Icons.account_balance_wallet_outlined),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Disponível para resgate",
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                formatCurrency(saldoDisponivel),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111827),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _contaCard() {
    return _card(
      child: Row(
        children: [
          _iconBox(Icons.account_balance),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Conta de Destino",
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 13,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  "Itaú Unibanco",
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "Ag 0432 • CC 29384-1",
                  style: TextStyle(
                    color: Colors.black45,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.blueGrey),
        ],
      ),
    );
  }

  Widget _resgateCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Valor do resgate",
            style: TextStyle(
              fontSize: 15,
              color: Color(0xFF1F2937),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F4FB),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _valorController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: "R\$ 0,00",
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: _resgatarTudo,
                  child: const Text(
                    "Tudo",
                    style: TextStyle(
                      color: Color(0xFF3D5AFE),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: _confirmarResgate,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 15),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF3D5AFE),
                    Color(0xFF7B1FA2),
                  ],
                ),
                borderRadius: BorderRadius.circular(25),
              ),
              child: const Center(
                child: Text(
                  "Confirmar Resgate",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _historicoCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Histórico de Rendimentos",
            style: TextStyle(
              fontSize: 15,
              color: Color(0xFF1F2937),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          _historyTile("EcoCharge", "Dividendo mensal", "+ R\$ 420,00"),
          _historyTile("UrbanLog", "Rendimento semestral", "+ R\$ 680,00"),
          _historyTile("FinFlow", "Bonificação token", "+ R\$ 140,00"),
        ],
      ),
    );
  }

  Widget _historyTile(String title, String subtitle, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          _iconBox(Icons.trending_up),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.black45,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.green,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: child,
    );
  }

  Widget _iconBox(IconData icon) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF3D5AFE),
            Color(0xFF7B1FA2),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(icon, color: Colors.white),
    );
  }

  Widget _buildNavBar() {
    final items = [
      {'icon': Icons.grid_view_rounded, 'label': 'Catálogo'},
      {'icon': Icons.swap_horiz_rounded, 'label': 'Negociar'},
      {
        'icon': Icons.account_balance_wallet_rounded,
        'label': 'Carteira'
      },
      {'icon': Icons.dashboard_rounded, 'label': 'Dashboard'},
      {'icon': Icons.person_rounded, 'label': 'Perfil'},
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
                onTap: () {
                  setState(() => _navIndex = i);

                  if (i == 0) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CatalogoStartUp(),
                      ),
                    );
                  }

                  if (i == 1) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TradingPage(),
                      ),
                    );
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: selected
                        ? const Color(0xFFEFF6FF)
                        : Colors.transparent,
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