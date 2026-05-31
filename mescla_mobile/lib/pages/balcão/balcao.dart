// Autor: Alinne Monteiro de Melo
// RA: 24801649

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mescla_mobile/pages/balc%C3%A3o/service/balcao_service.dart';
import 'package:mescla_mobile/pages/balcão/balcaoHelpers.dart';
import 'package:mescla_mobile/pages/balcão/widgets/cardSaldo.dart';
import 'package:mescla_mobile/pages/balcão/widgets/formularioOferta.dart';
import 'package:mescla_mobile/pages/balcão/widgets/livroOfertas.dart';
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

  List<StartupOffer> _ofertas             = [];
  bool               _carregandoOfertas   = false;
  bool               _livroTabComprar     = true;

  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _priceController    = TextEditingController();

  String get _uid => FirebaseAuth.instance.currentUser!.uid;
  DocumentReference get _userDoc =>
      FirebaseFirestore.instance.collection('users').doc(_uid);
  CollectionReference get _assetsCol => _userDoc.collection('assets');

  late AnimationController _fadeController;
  late Animation<double>   _fadeAnimation;

  int get _precoReferenciaCents =>
      _selectedStartup?.currentTokenPriceCents ?? 0;

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

  //carregamento 

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
      TradingPageHelpers.mostrarErro(context, 'Erro ao carregar startups.');
    }
  }

  Future<void> _carregarOfertas(String startupId) async {
    setState(() => _carregandoOfertas = true);
    try {
      final ofertas = await TradingService.listarOfertas(startupId);
      if (!mounted) return;
      setState(() => _ofertas = ofertas);
    } catch (_) {
      // livro vazio é estado válido
    } finally {
      if (mounted) setState(() => _carregandoOfertas = false);
    }
  }

  // ações

  Future<void> _criarOferta() async {
    final quantidade = int.tryParse(_quantityController.text) ?? 0;

    if (_selectedStartup == null) {
      TradingPageHelpers.mostrarErro(context, 'Selecione uma startup.');
      return;
    }
    if (quantidade <= 0) {
      TradingPageHelpers.mostrarErro(context, 'Informe uma quantidade válida de tokens.');
      return;
    }
    if (_precoOfertaCents <= 0) {
      TradingPageHelpers.mostrarErro(context, 'Informe um preço por token válido.');
      return;
    }

    HapticFeedback.mediumImpact();
    setState(() => _processando = true);

    try {
      await TradingService.criarOferta(
        type:       _offerTabComprar ? 'buy' : 'sell',
        startupId:  _selectedStartup!.id,
        quantity:   quantidade,
        priceCents: _precoOfertaCents,
      );

      TradingPageHelpers.mostrarSucesso(
        context,
        _offerTabComprar
            ? 'Oferta de compra criada! ${TradingPageHelpers.formatCurrency(_totalCents)}'
            : 'Oferta de venda criada! ${TradingPageHelpers.formatCurrency(_totalCents)}',
      );

      _quantityController.clear();
      _priceController.clear();
      await _carregarOfertas(_selectedStartup!.id);
    } catch (e) {
      final msg = e.toString();
      if (msg.contains('Saldo insuficiente')) {
        TradingPageHelpers.mostrarErro(context, 'Saldo insuficiente para criar esta oferta.');
      } else if (msg.contains('Tokens insuficientes')) {
        TradingPageHelpers.mostrarErro(context, 'Você não possui tokens suficientes para esta oferta.');
      } else {
        TradingPageHelpers.mostrarErro(context, 'Erro ao criar oferta. Tente novamente.');
      }
    } finally {
      if (mounted) setState(() => _processando = false);
    }
  }

  Future<void> _aceitarOferta(StartupOffer oferta) async {
    final confirmar = await TradingPageHelpers.mostrarConfirmacao(context, oferta);
    if (confirmar != true) return;

    HapticFeedback.mediumImpact();
    setState(() => _processando = true);

    try {
      await TradingService.aceitarOferta(oferta.offerId);
      TradingPageHelpers.mostrarSucesso(
        context,
        oferta.isSell
            ? 'Compra realizada! ${TradingPageHelpers.formatCurrency(oferta.totalCents)}'
            : 'Venda realizada! ${TradingPageHelpers.formatCurrency(oferta.totalCents)}',
      );
      await _carregarOfertas(_selectedStartup!.id);
    } catch (e) {
      final msg = e.toString();
      if (msg.contains('Saldo insuficiente')) {
        TradingPageHelpers.mostrarErro(context, 'Saldo insuficiente para aceitar esta oferta.');
      } else if (msg.contains('Tokens insuficientes')) {
        TradingPageHelpers.mostrarErro(context, 'Você não possui tokens suficientes para aceitar esta oferta.');
      } else if (msg.contains('não está mais disponível')) {
        TradingPageHelpers.mostrarErro(context, 'Esta oferta já foi aceita ou cancelada.');
        await _carregarOfertas(_selectedStartup!.id);
      } else {
        TradingPageHelpers.mostrarErro(context, 'Erro ao aceitar oferta. Tente novamente.');
      }
    } finally {
      if (mounted) setState(() => _processando = false);
    }
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
                    BalanceCard(userDoc: _userDoc, assetsCol: _assetsCol),
                    const SizedBox(height: 16),
                    TradeSection(
                      startups:            _startups,
                      selectedStartup:     _selectedStartup,
                      carregandoStartups:  _carregandoStartups,
                      offerTabComprar:     _offerTabComprar,
                      processando:         _processando,
                      quantityController:  _quantityController,
                      priceController:     _priceController,
                      precoReferenciaCents: _precoReferenciaCents,
                      totalCents:          _totalCents,
                      onStartupChanged: (val) {
                        setState(() {
                          _selectedStartup = val;
                          _quantityController.clear();
                          _priceController.clear();
                        });
                        _carregarOfertas(val.id);
                      },
                      onTabChanged: (isComprar) => setState(() {
                        _offerTabComprar = isComprar;
                        _livroTabComprar = isComprar;
                      }),
                      onCriarOferta: _criarOferta,
                    ),
                    const SizedBox(height: 16),
                    OrderBook(
                      ofertas:           _ofertas,
                      carregandoOfertas: _carregandoOfertas,
                      livroTabComprar:   _livroTabComprar,
                      processando:       _processando,
                      onTabChanged: (isComprar) =>
                          setState(() => _livroTabComprar = isComprar),
                      onAceitarOferta: _aceitarOferta,
                    ),
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
}