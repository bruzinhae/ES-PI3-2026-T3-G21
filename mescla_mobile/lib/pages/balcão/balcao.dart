// Autor: Bruna Barbour Fernandes
// RA: 23007950

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mescla_mobile/pages/balcão/trading_service.dart';
import 'package:mescla_mobile/widgets/bottom_navBar.dart';

class TradingPage extends StatefulWidget {
  const TradingPage({super.key});

  @override
  State<TradingPage> createState() => _TradingPageState();
}

class _TradingPageState extends State<TradingPage>
    with TickerProviderStateMixin {

  // estado 
  StartupItem? _selectedStartup;
  List<StartupItem> _startups = [];
  bool _carregandoStartups = true;

  bool _offerTabComprar = true;
  bool _showAllOffers   = false;
  bool _processando     = false;

  // Ofertas do livro
  List<StartupOffer> _ofertas       = [];
  bool              _carregandoOfertas = false;

  // Firestore refs pro card de saldo 
  String get _uid => FirebaseAuth.instance.currentUser!.uid;
  DocumentReference get _userDoc =>
      FirebaseFirestore.instance.collection('users').doc(_uid);
  CollectionReference get _assetsCol => _userDoc.collection('assets');

  final TextEditingController _quantityController = TextEditingController();

  late AnimationController _fadeController;
  late Animation<double>   _fadeAnimation;

  // Preço atual em centavos da startup selecionada
  int get _priceCents => _selectedStartup?.currentTokenPriceCents ?? 0;

  // total da operação em centavos
  int get _totalCents {
    final qty = int.tryParse(_quantityController.text) ?? 0;
    return TradingService.calcularTotalCents(qty, _priceCents);
  }

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

    _quantityController.addListener(() => setState(() {}));

    _carregarStartups();
  }

  Future<void> _carregarStartups() async {
    try {
      await FirebaseAuth.instance.authStateChanges().first;
      final lista = await TradingService.listarStartups();
      if (!mounted) return;
      setState(() {
        _startups           = lista;
        _selectedStartup    = lista.isNotEmpty ? lista.first : null;
        _carregandoStartups = false;
      });
      if (lista.isNotEmpty) await _carregarOfertas(lista.first.id);
    } catch (e) {
      print('ERRO startups: $e');
      if (!mounted) return;
      setState(() => _carregandoStartups = false);
      _mostrarErro('Erro ao carregar startups.');
    }
  }

  Future<void> _carregarOfertas(String startupId) async {
    setState(() => _carregandoOfertas = true);
    try {
      final ofertas = await TradingService.listarOfertas(startupId);
      print('ofertas recebidas: ${ofertas.length}');
      if (!mounted) return;
      setState(() => _ofertas = ofertas);
    } catch (e) {
      print('ERRO ofertas: $e');
    } finally {
      if (mounted) setState(() => _carregandoOfertas = false);
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  // helpers

  String _formatCurrency(int centavos) {
    final reais   = centavos / 100;
    final partes  = reais.toStringAsFixed(2).split('.');
    final inteiro = partes[0].replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
    return 'R\$ $inteiro,${partes[1]}';
  }

  void _mostrarErro(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      backgroundColor: const Color(0xFFDC2626),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ));
  }

  void _mostrarSucesso(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      backgroundColor: const Color(0xFF10B981),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ));
  }

  // Confirmar transação 
  Future<void> _confirmarTransacao() async {
    final quantidade = int.tryParse(_quantityController.text) ?? 0;

    if (_selectedStartup == null) {
      _mostrarErro('Selecione uma startup.');
      return;
    }
    if (quantidade <= 0) {
      _mostrarErro('Informe uma quantidade válida de tokens.');
      return;
    }

    HapticFeedback.mediumImpact();
    setState(() => _processando = true);

    try {
      if (_offerTabComprar) {
        await TradingService.comprarTokens(
          startupId: _selectedStartup!.id,
          quantity:  quantidade,
        );
        _mostrarSucesso('Compra realizada! ${_formatCurrency(_totalCents)}');
      } else {
        await TradingService.venderTokens(
          startupId: _selectedStartup!.id,
          quantity:  quantidade,
        );
        _mostrarSucesso('Venda realizada! ${_formatCurrency(_totalCents)}');
      }
      _quantityController.clear();
    } catch (e) {
      final msg = e.toString().contains('Saldo insuficiente')
          ? 'Saldo insuficiente para comprar tokens.'
          : e.toString().contains('Tokens insuficientes')
              ? 'Tokens insuficientes disponíveis no balcão.'
              : 'Erro ao processar transação. Tente novamente.';
      _mostrarErro(msg);
    } finally {
      setState(() => _processando = false);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      bottomNavigationBar: const BottomNavBar(selectedIndex: 1),
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
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Card de saldo/tokens ─────────────────────────
  Widget _buildBalanceCard() {
    return StreamBuilder<DocumentSnapshot>(
      stream: _userDoc.snapshots(),
      builder: (context, userSnap) {
        return StreamBuilder<QuerySnapshot>(
          stream: _assetsCol.snapshots(),
          builder: (context, assetsSnap) {
            final userData     = userSnap.data?.data() as Map<String, dynamic>?;
            final balanceCents = (userData?['balanceCents'] as int?) ?? 0;
            final totalTokens  = assetsSnap.hasData
                ? assetsSnap.data!.docs.fold<int>(0, (sum, doc) {
                    final d = doc.data() as Map<String, dynamic>;
                    return sum + ((d['quantity'] as int?) ?? 0);
                  })
                : 0;

            return Container(
              margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0D2CC8), Color(0xFF8D35E6)],
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
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Saldo
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Saldo disponível',
                          style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _formatCurrency(balanceCents),
                          style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800, letterSpacing: -0.5),
                        ),
                      ],
                    ),
                  ),
                  // Tokens
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '$totalTokens',
                        style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800),
                      ),
                      Text(
                        'tokens',
                        style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // app bar
  Widget _buildAppBar() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        left: 16, right: 16, bottom: 12,
      ),
      child: const Text(
        'Balcão de Negociação',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF111827), letterSpacing: -0.3),
      ),
    );
  }

  // seção negociar
  Widget _buildTradeSection() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título + abas Comprar/Vender
          Row(
            children: [
              Container(width: 4, height: 18, decoration: BoxDecoration(color: const Color(0xFF1A56DB), borderRadius: BorderRadius.circular(2))),
              const SizedBox(width: 8),
              const Text('Negociar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF111827))),
              const Spacer(),
              _buildTabChip('Comprar', true),
              const SizedBox(width: 6),
              _buildTabChip('Vender', false),
            ],
          ),
          const SizedBox(height: 16),

          // Dropdown de startups
          _buildLabel('Selecionar Startup'),
          const SizedBox(height: 6),
          _carregandoStartups
              ? const Center(child: CircularProgressIndicator())
              : _buildStartupDropdown(),

          const SizedBox(height: 14),

          // Quantidade
          _buildLabel('Quantidade de Tokens'),
          const SizedBox(height: 6),
          _buildQuantityField(),

          const SizedBox(height: 14),

          // Preço e total
          _buildPriceRow(),

          const SizedBox(height: 16),

          // Botão confirmar
          _buildConfirmButton(),

          const SizedBox(height: 10),

        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF6B7280), letterSpacing: 0.2));
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
        child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: isActive ? Colors.white : Colors.grey[600])),
      ),
    );
  }

  Widget _buildStartupDropdown() {
    if (_startups.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: const Color(0xFFF9FAFB), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE5E7EB))),
        child: const Text('Nenhuma startup disponível', style: TextStyle(color: Colors.grey)),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(color: const Color(0xFFF9FAFB), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE5E7EB))),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<StartupItem>(
          value: _selectedStartup,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF1A56DB)),
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF111827)),
          items: _startups.map((s) => DropdownMenuItem(value: s, child: Text(s.name))).toList(),
          onChanged: (val) {
            if (val == null) return;
            setState(() {
              _selectedStartup = val;
              _quantityController.clear();
            });
            _carregarOfertas(val.id);
          },
        ),
      ),
    );
  }

  Widget _buildQuantityField() {
    return Container(
      decoration: BoxDecoration(color: const Color(0xFFF9FAFB), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE5E7EB))),
      child: TextField(
        controller: _quantityController,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF111827)),
        decoration: InputDecoration(
          hintText: '0',
          hintStyle: TextStyle(color: Colors.grey[400]),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          border: InputBorder.none,
          suffixText: 'tokens',
          suffixStyle: TextStyle(fontSize: 12, color: Colors.grey[500], fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  Widget _buildPriceRow() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: const Color(0xFFF0F4FF), borderRadius: BorderRadius.circular(12)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Preço por token', style: TextStyle(fontSize: 10, color: Colors.grey[600])),
              const SizedBox(height: 2),
              Text(
                _selectedStartup != null ? _formatCurrency(_priceCents) : 'R\$ 0,00',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF1A56DB)),
              ),
            ],
          ),
          Container(width: 1, height: 36, color: Colors.blue[100]),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('Total', style: TextStyle(fontSize: 10, color: Colors.grey[600])),
              const SizedBox(height: 2),
              Text(
                _formatCurrency(_totalCents),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF111827)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmButton() {
    return GestureDetector(
      onTap: _processando ? null : _confirmarTransacao,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF0D2CC8), Color(0xFF1A56DB), Color(0xFF2563EB)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: const Color(0xFF1A56DB).withOpacity(0.35), blurRadius: 16, offset: const Offset(0, 8))],
        ),
        child: _processando
            ? const Center(child: SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5)))
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.verified_rounded, color: Colors.white, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    _offerTabComprar ? 'Confirmar Compra' : 'Confirmar Venda',
                    style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700, letterSpacing: 0.3),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildOrderBook() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cabeçalho
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(width: 4, height: 18, decoration: BoxDecoration(color: const Color(0xFF10B981), borderRadius: BorderRadius.circular(2))),
                  const SizedBox(width: 8),
                  const Text('Livro de Ofertas', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF111827))),
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

          // loading
          if (_carregandoOfertas)
            const Center(child: CircularProgressIndicator())

          // vazio
          else if (_ofertas.isEmpty)
            Center(
              child: Column(
                children: [
                  Icon(Icons.list_alt_rounded, size: 40, color: Colors.grey[300]),
                  const SizedBox(height: 12),
                  Text('Nenhuma oferta disponível', style: TextStyle(fontSize: 13, color: Colors.grey[500])),
                ],
              ),
            )

          // Lista de ofertas
          else ...[
            // header da tabela
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              decoration: BoxDecoration(color: const Color(0xFFF9FAFB), borderRadius: BorderRadius.circular(8)),
              child: const Row(
                children: [
                  Expanded(flex: 2, child: Text('Quantidade', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF6B7280)))),
                  Expanded(flex: 2, child: Text('Preço/Token', textAlign: TextAlign.center, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF6B7280)))),
                  Expanded(flex: 2, child: Text('Total', textAlign: TextAlign.center, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF6B7280)))),
                  SizedBox(width: 72),
                ],
              ),
            ),
            const SizedBox(height: 4),

            // linhas de oferta
            for (final oferta in _ofertas)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey[100]!, width: 1))),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text('${oferta.quantity} tokens', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF111827))),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(_formatCurrency(oferta.priceCents), textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF111827))),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(_formatCurrency(oferta.totalCents), textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF111827))),
                    ),
                    GestureDetector(
                      onTap: () {
                        _quantityController.text = oferta.quantity.toString();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(color: const Color(0xFF1A56DB), borderRadius: BorderRadius.circular(8)),
                        child: const Text('Usar', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ],
                ),
              ),
          ],
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}