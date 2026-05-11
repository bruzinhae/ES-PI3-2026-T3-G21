// Autor: Bruna Barbour Fernandes
// RA: 23007950

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'confirmacao.dart';
import 'trading_service.dart';
import 'catalogoStartUp.dart';
import 'confirmacao.dart';

void main() {
  runApp(const TradingApp());
}

class TradingApp extends StatelessWidget {
  const TradingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1A56DB),
          brightness: Brightness.light,
        ),
        fontFamily: 'Roboto',
      ),
      home: const TradingPage(),
    );
  }
}

class OfferItem {
  final int quantity;
  final double pricePerToken;
  final double total;

  const OfferItem({
    required this.quantity,
    required this.pricePerToken,
    required this.total,
  });
}

class HistoryItem {
  final String company;
  final String companyInitial;
  final Color companyColor;
  final int quantity;
  final int tokens;
  final double value;
  final String status;
  final Color statusColor;

  const HistoryItem({
    required this.company,
    required this.companyInitial,
    required this.companyColor,
    required this.quantity,
    required this.tokens,
    required this.value,
    required this.status,
    required this.statusColor,
  });
}

class TradingPage extends StatefulWidget {
  const TradingPage({super.key});

  @override
  State<TradingPage> createState() => _TradingPageState();
}

class _TradingPageState extends State<TradingPage>
    with TickerProviderStateMixin {
  int _selectedTab = 1;
  String _selectedStartup = 'Green Energy Co.';

  final TextEditingController _quantityController = TextEditingController();

  double _totalPrice = 0.0;
  final double _pricePerToken = 29.50;

  bool _showAllOffers = false;
  bool _offerTabComprar = true;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  final List<String> _startups = [
    'Green Energy Co.',
    'BioTech Solutions',
    'FinTech Hub',
    'AgriTech Brasil',
  ];

  final List<OfferItem> _offers = const [
    OfferItem(quantity: 128, pricePerToken: 28.30, total: 3622.40),
    OfferItem(quantity: 75, pricePerToken: 28.60, total: 2145.00),
    OfferItem(quantity: 302, pricePerToken: 28.90, total: 8727.80),
    OfferItem(quantity: 56, pricePerToken: 29.10, total: 1629.60),
    OfferItem(quantity: 1003, pricePerToken: 28.20, total: 28284.60),
  ];

  final List<HistoryItem> _history = const [
    HistoryItem(
      company: 'Green Energy Co.',
      companyInitial: 'G',
      companyColor: Color(0xFF10B981),
      quantity: 50,
      tokens: 15,
      value: 1180.00,
      status: 'Concluido',
      statusColor: Color(0xFF10B981),
    ),
    HistoryItem(
      company: 'BioTech Solutions',
      companyInitial: 'B',
      companyColor: Color(0xFFF59E0B),
      quantity: 312,
      tokens: 48,
      value: 900.00,
      status: 'Pendente',
      statusColor: Color(0xFFF59E0B),
    ),
    HistoryItem(
      company: 'FinTech Hub',
      companyInitial: 'F',
      companyColor: Color(0xFF6366F1),
      quantity: 51,
      tokens: 48,
      value: 28628.00,
      status: 'Concluido',
      statusColor: Color(0xFF10B981),
    ),
  ];

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );

    _fadeController.forward();

    _quantityController.addListener(() {
      final qty = double.tryParse(_quantityController.text) ?? 0;

      setState(() {
        _totalPrice = qty * _pricePerToken;
      });
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  String _formatCurrency(double value) {
    final formatted = value.toStringAsFixed(2).replaceAll('.', ',');
    final parts = formatted.split(',');
    final intPart = parts[0];
    final decPart = parts[1];
    final buffer = StringBuffer();
    int count = 0;

    for (int i = intPart.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) buffer.write('.');
      buffer.write(intPart[i]);
      count++;
    }

    return 'R\$ ${buffer
        .toString()
        .split('')
        .reversed
        .join()},$decPart';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            _buildAppBar(),

            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    _buildBalanceCard(),
                    const SizedBox(height: 16),

                    _buildTradeSection(),
                    const SizedBox(height: 16),

                    _buildOrderBook(),
                    const SizedBox(height: 16),

                    _buildRecentHistory(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            _buildBottomNav(),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(
        top: MediaQuery
            .of(context)
            .padding
            .top + 8,
        left: 16,
        right: 16,
        bottom: 12,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {},
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFF0F4FF),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                size: 16,
                color: Color(0xFF1A56DB),
              ),
            ),
          ),

          const Expanded(
            child: Text(
              'Balanço de Negociação',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF111827),
                letterSpacing: -0.3,
              ),
            ),
          ),

          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFF1A56DB),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.person_outline,
              size: 20,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF0D2CC8),
            Color(0xFF8D35E6),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A56DB).withOpacity(0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Patrimônio em Movimentos',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
            ),
          ),

          const SizedBox(height: 8),

          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Expanded(
                child: Text(
                  'R\$ 15.420,00',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1,
                  ),
                ),
              ),

              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    '850',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    'Tokens',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    'Total de tokens',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 9,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _buildBalanceButton(
                  label: 'Carregar Saldo',
                  icon: Icons.add_circle_outline,
                  filled: true,
                  onTap: () {},
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: _buildBalanceButton(
                  label: 'Negociar Lucros',
                  icon: Icons.trending_up,
                  filled: false,
                  onTap: () {
                    HapticFeedback.mediumImpact();

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ConfirmacaoPage(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceButton({
    required String label,
    required IconData icon,
    required bool filled,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: filled ? Colors.white : Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
          border: filled ? null : Border.all(color: Colors.white38),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: filled ? const Color(0xFF1A56DB) : Colors.white,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: filled ? const Color(0xFF1A56DB) : Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTradeSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 18,
                decoration: BoxDecoration(
                  color: const Color(0xFF1A56DB),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Negociar',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF111827),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          _buildLabel('Selecionar Startup'),
          const SizedBox(height: 6),
          _buildStartupDropdown(),

          const SizedBox(height: 14),

          _buildLabel('Quantidade de Tokens'),
          const SizedBox(height: 6),
          _buildQuantityField(),

          const SizedBox(height: 14),

          _buildPriceRow(),

          const SizedBox(height: 16),

          _buildConfirmButton(),

          const SizedBox(height: 10),

          Center(
            child: Text(
              'Taxa de corretagem de 2% será aplicada no valor total da operação',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[500],
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: Color(0xFF6B7280),
        letterSpacing: 0.2,
      ),
    );
  }

  Widget _buildStartupDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedStartup,
          isExpanded: true,
          icon: const Icon(
            Icons.keyboard_arrow_down,
            color: Color(0xFF1A56DB),
          ),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF111827),
          ),
          items: _startups
              .map((s) => DropdownMenuItem(value: s, child: Text(s)))
              .toList(),
          onChanged: (val) {
            if (val == null) return;
            setState(() => _selectedStartup = val);
          },
        ),
      ),
    );
  }

  Widget _buildQuantityField() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: TextField(
        controller: _quantityController,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Color(0xFF111827),
        ),
        decoration: InputDecoration(
          hintText: '0',
          hintStyle: TextStyle(color: Colors.grey[400]),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 12,
          ),
          border: InputBorder.none,
          suffixText: 'tokens',
          suffixStyle: TextStyle(
            fontSize: 12,
            color: Colors.grey[500],
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildPriceRow() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F4FF),
        borderRadius: BorderRadius.circular(12),
      ),

      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Preço por token',
                style: TextStyle(fontSize: 10, color: Colors.grey[600]),
              ),
              const SizedBox(height: 2),
              const Text(
                'R\$ 29,50',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A56DB),
                ),
              ),
            ],
          ),

          Container(
            width: 1,
            height: 36,
            color: Colors.blue[100],
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Total',
                style: TextStyle(fontSize: 10, color: Colors.grey[600]),
              ),
              const SizedBox(height: 2),
              Text(
                _formatCurrency(_totalPrice),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF111827),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmButton() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();

        final quantidade =
            int.tryParse(_quantityController.text) ?? 0;

        if (_selectedStartup.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                'Selecione uma startup.',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              backgroundColor: const Color(0xFFDC2626),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          );
          return;
        }

        if (quantidade <= 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                'Informe uma quantidade válida de tokens.',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              backgroundColor: const Color(0xFFDC2626),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          );
          return;
        }

        final total = quantidade * _pricePerToken;
        final taxaCorretagem = total * 0.02;
        final valorFinal = total + taxaCorretagem;

        final transacao = {
          'startup': _selectedStartup,
          'quantidadeTokens': quantidade,
          'precoPorToken': _pricePerToken,
          'valorTotal': total,
          'taxaCorretagem': taxaCorretagem,
          'valorFinal': valorFinal,
          'status': 'Pendente',
          'dataCriacao': DateTime.now().toIso8601String(),
        };

        print(transacao);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Transação registrada • ${_formatCurrency(valorFinal)}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        );
      },

      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFF0D2CC8),
              Color(0xFF1A56DB),
              Color(0xFF2563EB),
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1A56DB).withOpacity(0.35),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),

        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(
              Icons.verified_rounded,
              color: Colors.white,
              size: 18,
            ),

            SizedBox(width: 8),

            Text(
              'Confirmar Transação',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderBook() {
    final displayedOffers = _showAllOffers ? _offers : _offers.take(4).toList();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 4,
                    height: 18,
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Livro de Ofertas',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF111827),
                    ),
                  ),
                ],
              ),

              Row(
                children: [
                  _buildTabChip('Comprar', true),
                  const SizedBox(width: 6),
                  _buildTabChip('Vender', false),
                ],
              ),
            ],
          ),

          const SizedBox(height: 14),

          _buildOrderBookHeader(),

          const SizedBox(height: 4),

          ...displayedOffers.map((offer) => _buildOfferRow(offer)),

          const SizedBox(height: 8),

          GestureDetector(
            onTap: () => setState(() => _showAllOffers = !_showAllOffers),
            child: Center(
              child: Text(
                _showAllOffers ? 'Ver menos ofertas' : 'Ver todas as ofertas',
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF1A56DB),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabChip(String label, bool isComprar) {
    final isActive = _offerTabComprar == isComprar;

    return GestureDetector(
      onTap: () => setState(() => _offerTabComprar = isComprar),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF1A56DB) : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: isActive ? Colors.white : Colors.grey[600],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderBookHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              'Quantidade',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: Color(0xFF6B7280),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Preço/Token',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: Color(0xFF6B7280),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Total',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: Color(0xFF6B7280),
              ),
            ),
          ),
          SizedBox(width: 64),
        ],
      ),
    );
  }

  Widget _buildOfferRow(OfferItem offer) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[100]!, width: 1),
        ),
      ),

      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              '${offer.quantity} tokens',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF111827),
              ),
            ),
          ),

          Expanded(
            flex: 2,
            child: Text(
              _formatCurrency(offer.pricePerToken),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF111827),
              ),
            ),
          ),

          Expanded(
            flex: 2,
            child: Text(
              _formatCurrency(offer.total),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF111827),
              ),
            ),
          ),

          GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Comprando ${offer.quantity} tokens por ${_formatCurrency(
                        offer.pricePerToken)}',
                  ),
                  backgroundColor: const Color(0xFF1A56DB),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFF1A56DB),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Comprar',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentHistory() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 18,
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Histórico Recente',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF111827),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          _buildHistoryHeader(),

          ..._history.map((item) => _buildHistoryRow(item)),
        ],
      ),
    );
  }

  Widget _buildHistoryHeader() {
    const style = TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.w700,
      color: Color(0xFF6B7280),
    );

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(8),
      ),

      child: const Row(
        children: [
          Expanded(flex: 3, child: Text('Título', style: style)),
          Expanded(
            flex: 2,
            child: Text('Qtd', textAlign: TextAlign.center, style: style),
          ),
          Expanded(
            flex: 2,
            child: Text('Tokens', textAlign: TextAlign.center, style: style),
          ),
          Expanded(
            flex: 2,
            child: Text('Valor', textAlign: TextAlign.center, style: style),
          ),
          Expanded(
            flex: 2,
            child: Text('Status', textAlign: TextAlign.center, style: style),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryRow(HistoryItem item) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[100]!, width: 1),
        ),
      ),

      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: item.companyColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      item.companyInitial,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: item.companyColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    item.company,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF111827),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            flex: 2,
            child: Text(
              '${item.quantity}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Color(0xFF374151),
              ),
            ),
          ),

          Expanded(
            flex: 2,
            child: Text(
              '${item.tokens}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Color(0xFF374151),
              ),
            ),
          ),

          Expanded(
            flex: 2,
            child: Text(
              _formatCurrency(item.value),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Color(0xFF374151),
              ),
            ),
          ),

          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              decoration: BoxDecoration(
                color: item.statusColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                item.status,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: item.statusColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    final items = [
      {'icon': Icons.grid_view_rounded, 'label': 'Catálogo'},
      {'icon': Icons.swap_horiz_rounded, 'label': 'Negociar'},
      {
        'icon': Icons.account_balance_wallet_rounded,
        'label': 'Carteira',
      },
      {'icon': Icons.dashboard_rounded, 'label': 'Dashboard'},
      {'icon': Icons.person_rounded, 'label': 'Perfil'},
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(20),
        ),
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
              final selected = i == _selectedTab;

              return GestureDetector(
                onTap: () {
                  setState(() => _selectedTab = i);

                  // CATÁLOGO
                  if (i == 0) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CatalogoStartUp(),
                      ),
                    );
                  }

                  // NEGOCIAR
                  if (i == 1) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TradingPage(),
                      ),
                    );
                  }

                  // CARTEIRA
                  if (i == 0) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ConfirmacaoPage(),
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
                        color: selected
                            ? const Color(0xFF0035B9)
                            : Colors.blueGrey,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        items[i]['label'] as String,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: selected
                              ? const Color(0xFF0035B9)
                              : Colors.blueGrey,
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