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

  StartupItem?       _selectedStartup;
  List<StartupItem>  _startups            = [];
  bool               _carregandoStartups  = true;

  bool               _offerTabComprar     = true;
  bool               _processando         = false;

  // livro de ofertas

  List<StartupOffer> _ofertas             = [];
  bool               _carregandoOfertas   = false;
  // filtra o livro pelo mesmo lado da aba ativa no formulário
  bool               _livroTabComprar     = true;

  // Controllers 
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _priceController    = TextEditingController();

  // firestore refs para o card de saldo
  String get _uid => FirebaseAuth.instance.currentUser!.uid;
  DocumentReference get _userDoc =>
      FirebaseFirestore.instance.collection('users').doc(_uid);
  CollectionReference get _assetsCol => _userDoc.collection('assets');

  // animação
  late AnimationController _fadeController;
  late Animation<double>   _fadeAnimation;

  // helpers de cálculo 

  /// preço de referência da startup (usado apenas como hint no campo)
  int get _precoReferenciaCents =>
      _selectedStartup?.currentTokenPriceCents ?? 0;

  /// preço digitado pelo usuário em centavos (converte de reais)
  int get _precoOfertaCents {
    final raw = _priceController.text.replaceAll(',', '.');
    final reais = double.tryParse(raw) ?? 0.0;
    return (reais * 100).round();
  }

  int get _totalCents {
    final qty = int.tryParse(_quantityController.text) ?? 0;
    return TradingService.calcularTotalCents(qty, _precoOfertaCents);
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
    _priceController.addListener(() => setState(() {}));

    _carregarStartups();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  // carregamento

  Future<void> _carregarStartups() async {
    try {
      await FirebaseAuth.instance.authStateChanges().first;
      final lista = await TradingService.listarStartups();
      if (!mounted) return;
      setState(() {
        _startups            = lista;
        _selectedStartup     = lista.isNotEmpty ? lista.first : null;
        _carregandoStartups  = false;
      });
      if (lista.isNotEmpty) await _carregarOfertas(lista.first.id);
    } catch (e) {
      if (!mounted) return;
      setState(() => _carregandoStartups = false);
      _mostrarErro('Erro ao carregar startups.');
    }
  }

  Future<void> _carregarOfertas(String startupId) async {
    setState(() => _carregandoOfertas = true);
    try {
      final ofertas = await TradingService.listarOfertas(startupId);
      if (!mounted) return;
      setState(() => _ofertas = ofertas);
    } catch (e) {
      // silencioso, livro vazio é estado válido
    } finally {
      if (mounted) setState(() => _carregandoOfertas = false);
    }
  }

  // ações

  Future<void> _criarOferta() async {
    final quantidade = int.tryParse(_quantityController.text) ?? 0;

    if (_selectedStartup == null) {
      _mostrarErro('Selecione uma startup.');
      return;
    }
    if (quantidade <= 0) {
      _mostrarErro('Informe uma quantidade válida de tokens.');
      return;
    }
    if (_precoOfertaCents <= 0) {
      _mostrarErro('Informe um preço por token válido.');
      return;
    }

    HapticFeedback.mediumImpact();
    setState(() => _processando = true);

    try {
      await TradingService.criarOferta(
        type:        _offerTabComprar ? 'buy' : 'sell',
        startupId:   _selectedStartup!.id,
        quantity:    quantidade,
        priceCents:  _precoOfertaCents,
      );

      _mostrarSucesso(
        _offerTabComprar
            ? 'Oferta de compra criada! ${_formatCurrency(_totalCents)}'
            : 'Oferta de venda criada! ${_formatCurrency(_totalCents)}',
      );

      _quantityController.clear();
      _priceController.clear();

      // atualiza o livro
      await _carregarOfertas(_selectedStartup!.id);
    } catch (e) {
      final msg = e.toString();
      if (msg.contains('Saldo insuficiente')) {
        _mostrarErro('Saldo insuficiente para criar esta oferta.');
      } else if (msg.contains('Tokens insuficientes')) {
        _mostrarErro('Você não possui tokens suficientes para esta oferta.');
      } else {
        _mostrarErro('Erro ao criar oferta. Tente novamente.');
      }
    } finally {
      if (mounted) setState(() => _processando = false);
    }
  }

  Future<void> _aceitarOferta(StartupOffer oferta) async {
    // confirmação rápida antes de executar
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          oferta.isSell ? 'Confirmar compra' : 'Confirmar venda',
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _dialogRow('Quantidade', '${oferta.quantity} tokens'),
            const SizedBox(height: 6),
            _dialogRow('Preço/token', _formatCurrency(oferta.priceCents)),
            const SizedBox(height: 6),
            _dialogRow('Total', _formatCurrency(oferta.totalCents), destaque: true),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar', style: TextStyle(color: Color(0xFF6B7280))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1A56DB),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Confirmar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    HapticFeedback.mediumImpact();
    setState(() => _processando = true);

    try {
      await TradingService.aceitarOferta(oferta.offerId);
      _mostrarSucesso(
        oferta.isSell
            ? 'Compra realizada! ${_formatCurrency(oferta.totalCents)}'
            : 'Venda realizada! ${_formatCurrency(oferta.totalCents)}',
      );
      await _carregarOfertas(_selectedStartup!.id);
    } catch (e) {
      final msg = e.toString();
      if (msg.contains('Saldo insuficiente')) {
        _mostrarErro('Saldo insuficiente para aceitar esta oferta.');
      } else if (msg.contains('Tokens insuficientes')) {
        _mostrarErro('Você não possui tokens suficientes para aceitar esta oferta.');
      } else if (msg.contains('não está mais disponível')) {
        _mostrarErro('Esta oferta já foi aceita ou cancelada.');
        await _carregarOfertas(_selectedStartup!.id);
      } else {
        _mostrarErro('Erro ao aceitar oferta. Tente novamente.');
      }
    } finally {
      if (mounted) setState(() => _processando = false);
    }
  }

  // helpers de UI

  String _formatCurrency(int centavos) {
    final reais  = centavos / 100;
    final partes = reais.toStringAsFixed(2).split('.');
    final inteiro = partes[0].replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
    return 'R\$ $inteiro,${partes[1]}';
  }

  Widget _dialogRow(String label, String value, {bool destaque = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
        Text(
          value,
          style: TextStyle(
            fontSize: destaque ? 15 : 13,
            fontWeight: destaque ? FontWeight.w800 : FontWeight.w600,
            color: destaque ? const Color(0xFF1A56DB) : const Color(0xFF111827),
          ),
        ),
      ],
    );
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

  // build

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

  // appbar

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
        style: TextStyle(
          fontSize: 16, fontWeight: FontWeight.w700,
          color: Color(0xFF111827), letterSpacing: -0.3,
        ),
      ),
    );
  }

  // card de saldo

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
                    blurRadius: 20, offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Saldo disponível',
                            style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500)),
                        const SizedBox(height: 6),
                        Text(_formatCurrency(balanceCents),
                            style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('$totalTokens',
                          style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
                      Text('tokens',
                          style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 11)),
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

  // seção de criação de oferta 

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
          // Título + abas
          Row(
            children: [
              Container(
                width: 4, height: 18,
                decoration: BoxDecoration(color: const Color(0xFF1A56DB), borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(width: 8),
              const Text('Criar oferta',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF111827))),
              const Spacer(),
              _buildTabChip('Comprar', true),
              const SizedBox(width: 6),
              _buildTabChip('Vender', false),
            ],
          ),
          const SizedBox(height: 16),

          // Dropdown de startups
          _buildLabel('Selecionar startup'),
          const SizedBox(height: 6),
          _carregandoStartups
              ? const Center(child: CircularProgressIndicator())
              : _buildStartupDropdown(),
          const SizedBox(height: 14),

          // Quantidade + Preço lado a lado
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('Quantidade'),
                    const SizedBox(height: 6),
                    _buildQuantityField(),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('Preço por token (R\$)'),
                    const SizedBox(height: 6),
                    _buildPriceField(),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Hint de preço de referência
          if (_precoReferenciaCents > 0)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded, size: 13, color: Colors.grey[400]),
                  const SizedBox(width: 4),
                  Text(
                    'Preço atual de referência: ${_formatCurrency(_precoReferenciaCents)}',
                    style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                  ),
                ],
              ),
            ),

          // Total calculado
          _buildTotalRow(),
          const SizedBox(height: 16),

          // Botão criar oferta
          _buildConfirmButton(),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(text,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF6B7280), letterSpacing: 0.2));
  }

  Widget _buildTabChip(String label, bool isComprar) {
    final isActive = _offerTabComprar == isComprar;
    return GestureDetector(
      onTap: () => setState(() {
        _offerTabComprar  = isComprar;
        _livroTabComprar  = isComprar; // sincroniza o livro com a aba
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF1A56DB) : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(label,
            style: TextStyle(
              fontSize: 11, fontWeight: FontWeight.w600,
              color: isActive ? Colors.white : Colors.grey[600],
            )),
      ),
    );
  }

  Widget _buildStartupDropdown() {
    if (_startups.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: const Text('Nenhuma startup disponível', style: TextStyle(color: Colors.grey)),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<StartupItem>(
          value: _selectedStartup,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF1A56DB)),
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF111827)),
          items: _startups
              .map((s) => DropdownMenuItem(value: s, child: Text(s.name)))
              .toList(),
          onChanged: (val) {
            if (val == null) return;
            setState(() {
              _selectedStartup = val;
              _quantityController.clear();
              _priceController.clear();
            });
            _carregarOfertas(val.id);
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
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF111827)),
        decoration: InputDecoration(
          hintText: '0',
          hintStyle: TextStyle(color: Colors.grey[400]),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          border: InputBorder.none,
          suffixText: 'tkn',
          suffixStyle: TextStyle(fontSize: 12, color: Colors.grey[500], fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  /// campo de preço 
  Widget _buildPriceField() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: TextField(
        controller: _priceController,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'^\d*[,.]?\d{0,2}')),
        ],
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF111827)),
        decoration: InputDecoration(
          hintText: '0,00',
          hintStyle: TextStyle(color: Colors.grey[400]),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          border: InputBorder.none,
          prefixText: 'R\$ ',
          prefixStyle: TextStyle(fontSize: 12, color: Colors.grey[500], fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  Widget _buildTotalRow() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F4FF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Total da oferta',
              style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w500)),
          Text(
            _formatCurrency(_totalCents),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF1A56DB)),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmButton() {
    final habilitado = !_processando &&
        (int.tryParse(_quantityController.text) ?? 0) > 0 &&
        _precoOfertaCents > 0;

    return GestureDetector(
      onTap: habilitado ? _criarOferta : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          gradient: habilitado
              ? const LinearGradient(
                  colors: [Color(0xFF0D2CC8), Color(0xFF1A56DB), Color(0xFF2563EB)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                )
              : null,
          color: habilitado ? null : const Color(0xFFE5E7EB),
          borderRadius: BorderRadius.circular(16),
          boxShadow: habilitado
              ? [BoxShadow(color: const Color(0xFF1A56DB).withOpacity(0.35), blurRadius: 16, offset: const Offset(0, 8))]
              : [],
        ),
        child: _processando
            ? const Center(
                child: SizedBox(
                  width: 22, height: 22,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _offerTabComprar ? Icons.add_shopping_cart_rounded : Icons.sell_rounded,
                    color: habilitado ? Colors.white : Colors.grey[400],
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _offerTabComprar ? 'Publicar oferta de compra' : 'Publicar oferta de venda',
                    style: TextStyle(
                      color: habilitado ? Colors.white : Colors.grey[400],
                      fontSize: 15, fontWeight: FontWeight.w700, letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  // livro de ofertas

  Widget _buildOrderBook() {
    // filtra pelo tipo oposto à aba: se você quer COMPRAR, vê ofertas de VENDA
    // (são as que o usuario pode aceitar para comprar), e vice-versa.
    // mas também mostra suas próprias ofertas criadas (isOwn = true) com badge.
    final ofertasFiltradas = _ofertas.where((o) {
      if (_livroTabComprar) return o.isSell; // você compra aceitando vendas
      return o.isBuy;                        // você vende aceitando compras
    }).toList();

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
                  Container(
                    width: 4, height: 18,
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text('Livro de ofertas',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF111827))),
                ],
              ),
              // abas do livro - independentes do formulário
              Row(
                children: [
                  _buildLivroTabChip('Para comprar', true),
                  const SizedBox(width: 6),
                  _buildLivroTabChip('Para vender', false),
                ],
              ),
            ],
          ),

          // subtítulo contextual
          Padding(
            padding: const EdgeInsets.only(top: 6, bottom: 14),
            child: Text(
              _livroTabComprar
                  ? 'Ofertas de venda — aceite para comprar tokens'
                  : 'Ofertas de compra — aceite para vender tokens',
              style: TextStyle(fontSize: 11, color: Colors.grey[500]),
            ),
          ),

          // Loading
          if (_carregandoOfertas)
            const Center(child: Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: CircularProgressIndicator(),
            ))

          // Vazio
          else if (ofertasFiltradas.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Column(
                  children: [
                    Icon(Icons.list_alt_rounded, size: 40, color: Colors.grey[300]),
                    const SizedBox(height: 12),
                    Text('Nenhuma oferta disponível',
                        style: TextStyle(fontSize: 13, color: Colors.grey[500])),
                    const SizedBox(height: 4),
                    Text('Seja o primeiro a criar uma!',
                        style: TextStyle(fontSize: 12, color: Colors.grey[400])),
                  ],
                ),
              ),
            )

          // Lista
          else ...[
            // Header da tabela
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Expanded(flex: 2, child: Text('Qtd.', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF6B7280)))),
                  Expanded(flex: 2, child: Text('Preço/token', textAlign: TextAlign.center, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF6B7280)))),
                  Expanded(flex: 2, child: Text('Total', textAlign: TextAlign.center, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF6B7280)))),
                  SizedBox(width: 76),
                ],
              ),
            ),
            const SizedBox(height: 4),

            // Linhas
            for (final oferta in ofertasFiltradas)
              _buildOfferRow(oferta),
          ],

          const SizedBox(height: 4),
        ],
      ),
    );
  }

  /// aba do livro (independente das abas do formulário)
  Widget _buildLivroTabChip(String label, bool isComprar) {
    final isActive = _livroTabComprar == isComprar;
    return GestureDetector(
      onTap: () => setState(() => _livroTabComprar = isComprar),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF10B981) : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(label,
            style: TextStyle(
              fontSize: 11, fontWeight: FontWeight.w600,
              color: isActive ? Colors.white : Colors.grey[600],
            )),
      ),
    );
  }

  Widget _buildOfferRow(StartupOffer oferta) {
    final isOwn = oferta.isOwn;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      decoration: BoxDecoration(
        color: isOwn ? const Color(0xFFFFFBEB) : null,
        border: Border(bottom: BorderSide(color: Colors.grey[100]!, width: 1)),
      ),
      child: Row(
        children: [
          // Quantidade + badge "minha" se for do próprio usuário
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Text('${oferta.quantity}',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF111827))),
                if (isOwn) ...[
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text('minha',
                        style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: Color(0xFF92400E))),
                  ),
                ],
              ],
            ),
          ),

          // Preço
          Expanded(
            flex: 2,
            child: Text(
              _formatCurrency(oferta.priceCents),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12, fontWeight: FontWeight.w600,
                color: oferta.isSell ? const Color(0xFF059669) : const Color(0xFFDC2626),
              ),
            ),
          ),

          // Total
          Expanded(
            flex: 2,
            child: Text(
              _formatCurrency(oferta.totalCents),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF111827)),
            ),
          ),

          // Botão: "Aceitar" para ofertas de outros, desabilitado para as próprias
          SizedBox(
            width: 76,
            child: isOwn
                ? Center(
                    child: Text('sua oferta',
                        style: TextStyle(fontSize: 9, color: Colors.grey[400], fontWeight: FontWeight.w500)),
                  )
                : GestureDetector(
                    onTap: _processando ? null : () => _aceitarOferta(oferta),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: oferta.isSell
                            ? const Color(0xFF059669)
                            : const Color(0xFFDC2626),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        oferta.isSell ? 'Comprar' : 'Vender',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}