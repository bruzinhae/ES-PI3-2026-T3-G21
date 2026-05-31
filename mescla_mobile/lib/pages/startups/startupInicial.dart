// Autor: Bruna Barbour Fernandes
// RA: 23007950

import 'package:flutter/material.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'catalogoStartUp.dart';
import 'services/startup_service.dart';
import '../../widgets/bottom_navBar.dart';
import 'modal_investimento.dart';
import 'modal_perguntaPrivada.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../widgets/bottom_navBar.dart';

import 'widgets/barra_superior.dart';
import 'widgets/tela_carregamento.dart';
import 'widgets/estado_vazio.dart';
import 'widgets/chip_personalizado.dart';
import 'widgets/card_info.dart';
import 'widgets/card_secao.dart';
import 'widgets/botao_gradiente.dart';

class StartupInicial extends StatelessWidget {
  final String startupId;

  const StartupInicial({
    super.key,
    required this.startupId,
  });

  @override
  Widget build(BuildContext context) {
    return InvestPage(startupId: startupId);
  }
}

class InvestPage extends StatefulWidget {
  final String startupId;

  const InvestPage({
    super.key,
    required this.startupId,
  });

  @override
  State<InvestPage> createState() => _InvestPageState();
}

class _InvestPageState extends State<InvestPage> {
  final TextEditingController _controller = TextEditingController();

  bool carregando = true;
  bool enviandoPergunta = false;
  String? erro;

  final List<Map<String, dynamic>> mensagensLocais = [];

  StartupDetails? startup;

  String periodoSelecionado = '6M';
  bool carregandoGrafico = false;

  final Map<String, String> periodoBackend = {
    '1D': 'diario',
    '7D': 'semanal',
    '1M': 'mensal',
    '6M': 'semestral',
    'YTD': 'ytd',
  };

  Map<String, List<double>> valoresGrafico = {
    '1D': [],
    '7D': [],
    '1M': [],
    '6M': [],
    'YTD': [],
  };

  Map<String, List<String>> labelsGrafico = {
    '1D': [],
    '7D': [],
    '1M': [],
    '6M': [],
    'YTD': [],
  };

  final Map<String, List<double>> valoresGraficoFallback = {
    '1D': [20.0, 40.0, 35.0, 55.0, 70.0, 90.0],
    '7D': [35.0, 55.0, 48.0, 80.0, 95.0, 120.0],
    '1M': [50.0, 70.0, 65.0, 105.0, 130.0, 155.0],
    '6M': [72.0, 105.0, 82.0, 135.0, 165.0, 210.0],
    'YTD': [60.0, 95.0, 125.0, 160.0, 200.0, 190.0],
  };

  final Map<String, List<String>> labelsGraficoFallback = {
    '1D': ['09h', '11h', '13h', '15h', '17h', '19h'],
    '7D': ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb'],
    '1M': ['Sem 1', 'Sem 2', 'Sem 3', 'Sem 4', 'Sem 5', 'Sem 6'],
    '6M': ['Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun'],
    'YTD': ['Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun'],
  };

  @override
  void initState() {
    super.initState();
    carregarDadosDaTela();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> carregarDadosDaTela() async {
    setState(() {
      carregando = true;
      erro = null;
    });

    try {
      final dados = await StartupService.getStartupDetails(widget.startupId);

      setState(() {
        startup = dados;
        carregando = false;
      });

      await carregarHistoricoGrafico(periodoSelecionado);
    } on FirebaseFunctionsException catch (e) {
      setState(() {
        carregando = false;
        erro = 'Erro: ${e.message}';
      });

      debugPrint('Código: ${e.code}');
      debugPrint('Mensagem: ${e.message}');
      debugPrint('Detalhes: ${e.details}');
    } catch (e) {
      setState(() {
        carregando = false;
        erro = 'Erro inesperado ao carregar dados.';
      });

      debugPrint('Erro inesperado: $e');
    }
  }

  Future<void> enviarPergunta() async {
    final texto = _controller.text.trim();
    if (texto.isEmpty) return;

    final user = FirebaseAuth.instance.currentUser;

    setState(() => enviandoPergunta = true);


    try {
      await StartupService.createStartupQuestion(
        startupId: widget.startupId,
        message: texto,
      );

      _controller.clear();

      if (!mounted) return;

      setState(() {
        mensagensLocais.add({
          'authorName': user?.displayName?.trim().isNotEmpty == true
              ? user!.displayName!
              : user?.email?.split('@').first ?? 'Você',
          'message': texto,
          'isAnswer': false,
        });

        mensagensLocais.add({
          'authorName': startup?.name ?? 'Time da startup',
          'message':
          'Olá! Recebemos sua pergunta. Nosso time irá analisar e responder em breve.',
          'isAnswer': true,
        });
      });
    } on FirebaseFunctionsException catch (e) {
      setState(() => erro = 'Erro: ${e.message}');
      debugPrint('Código: ${e.code}');
      debugPrint('Mensagem: ${e.message}');
    } catch (e) {
      setState(() => erro = 'Erro inesperado ao enviar pergunta.');
      debugPrint('Erro inesperado: $e');
    } finally {
      setState(() => enviandoPergunta = false);
    }
  }

  String iniciais(String nome) {
    final partes = nome.trim().split(' ');
    if (partes.isEmpty) return '?';
    if (partes.length == 1) return partes.first[0].toUpperCase();
    return '${partes.first[0]}${partes.last[0]}'.toUpperCase();
  }


  @override
  Widget build(BuildContext context) {
    if (carregando) {
      return const Scaffold(
        backgroundColor: Color(0xFFEFF4FF),
        body: SafeArea(
          child: TelaCarregamento(),
        ),
      );
    }

    if (erro != null) {
      return Scaffold(
        backgroundColor: const Color(0xFFEFF4FF),
        body: SafeArea(
          child: EstadoVazio(
            mensagem: erro!,
          ),
        ),
      );
    }

    final s = startup!;

    return Scaffold(
      bottomNavigationBar: const BottomNavBar(
        selectedIndex: 0,
      ),
      backgroundColor: const Color(0xFFEFF4FF),

      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 12, 18, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _topBar(),
                    const SizedBox(height: 24),
                    _chips(s),
                    const SizedBox(height: 16),
                    Text(
                      s.name,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _series(s),
                    const SizedBox(height: 18),
                    Text(
                      s.description.isNotEmpty
                          ? s.description
                          : s.shortDescription.isNotEmpty
                          ? s.shortDescription
                          : 'Sem descrição.',
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.6,
                        color: Color(0xFF4B5563),
                      ),
                    ),
                    const SizedBox(height: 28),
                    _metrics(s),
                    const SizedBox(height: 24),
                    if (s.access.isInvestor) ...[
                      _investorAreaCard(s),
                      const SizedBox(height: 24),
                    ],
                    _chartCard(),
                    const SizedBox(height: 24),
                    _teamCard(s),
                    const SizedBox(height: 24),
                    const Text(
                      'Documentação Pública',
                      style: TextStyle(
                        fontSize: 15,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 14),
                    _docs(s),
                    const SizedBox(height: 24),
                    _questionsCard(s),
                    const SizedBox(height: 18),
                    _investButton(),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _topBar() {
    return BarraSuperiorMescla(
      mostrarFavorito: true,
      aoVoltar: () => Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const CatalogoStartUp()),
      ),
    );
  }

  Widget _chips(StartupDetails s) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        _chip(s.tagsFormatadas),
        _chip(s.stageFormatado),
      ],
    );
  }

  Widget _chip(String text) {
    return ChipPersonalizado(
      texto: text,
    );
  }

  Widget _series(StartupDetails s) {
    return Row(
      children: [
        const Icon(Icons.eco_outlined, color: Color(0xFF0D2CC8), size: 26),
        const SizedBox(width: 12),
        Text(
          s.name,
          style: const TextStyle(
            color: Color(0xFF0D2CC8),
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _metrics(StartupDetails s) {
    final valorizacaoPositiva = !s.valorizacaoFormatada.contains('-');

    return GridView.count(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      crossAxisCount: 2,
      childAspectRatio: 1.45,
      crossAxisSpacing: 14,
      mainAxisSpacing: 14,
      children: [
        CardInfo(
          titulo: 'Capital aportado',
          valor: s.capitalFormatado,
          icone: Icons.account_balance_wallet_outlined,
        ),
        CardInfo(
          titulo: 'Tokens totais',
          valor: s.tokensFormatados,
          icone: Icons.generating_tokens_outlined,
        ),
        CardInfo(
          titulo: 'Valor do Token',
          valor: s.tokenPriceFormatado,
          icone: Icons.paid_outlined,
        ),
        CardInfo(
          titulo: 'Valorização',
          valor: s.valorizacaoFormatada,
          icone: valorizacaoPositiva ? Icons.trending_up : Icons.trending_down,
          cor: valorizacaoPositiva
              ? const Color(0xFF16A34A)
              : const Color(0xFFDC2626),
        ),
      ],
    );
  }

  Widget _investorAreaCard(StartupDetails s) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(28, 28, 28, 28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF0D2CC8),
            Color(0xFF8D35E6),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.16),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: Colors.white.withOpacity(0.28),
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.lock_outline,
                  color: Colors.white,
                  size: 20,
                ),
                SizedBox(width: 12),
                Text(
                  'ÁREA DO INVESTIDOR',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2.2,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 22),

          GestureDetector(
            onTap: () => abrirModalPerguntaPrivada(
              context,
              startupId: widget.startupId,
              startupName: s.name,
            ),
            child: Container(
              width: double.infinity,
              height: 54,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.14),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: Colors.white.withOpacity(0.32),
                  width: 1.4,
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    color: Colors.white,
                    size: 18,
                  ),
                  SizedBox(width: 10),
                  Text(
                    'Enviar pergunta privada',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }


  Future<void> carregarHistoricoGrafico(String periodoTela) async {
    final periodo = periodoBackend[periodoTela];

    if (periodo == null) return;

    setState(() {
      carregandoGrafico = true;
    });

    try {
      final history = await _chamarHistoricoTokens(periodo);

      final pontosAgrupados = <String, Map<String, dynamic>>{};

      for (final item in history) {
        final criadoEmTexto = item['criadoEm']?.toString();
        final criadoEm = criadoEmTexto != null
            ? DateTime.tryParse(criadoEmTexto)
            : null;

        if (criadoEm == null) continue;

        String chave;

        switch (periodoTela) {
          case '1D':
            chave =
            '${criadoEm.year}-${criadoEm.month}-${criadoEm.day}-${criadoEm.hour}';
            break;
          case '7D':
            chave = '${criadoEm.year}-${criadoEm.month}-${criadoEm.day}';
            break;
          case '1M':
            final semanaDoMes = ((criadoEm.day - 1) ~/ 7) + 1;
            chave = '${criadoEm.year}-${criadoEm.month}-semana-$semanaDoMes';
            break;
          case '6M':
          case 'YTD':
            chave = '${criadoEm.year}-${criadoEm.month}';
            break;
          default:
            chave = criadoEm.toIso8601String();
        }

        pontosAgrupados[chave] = item;
      }

      final pontosOrdenados = pontosAgrupados.values.toList()
        ..sort((a, b) {
          final dataA = DateTime.tryParse(a['criadoEm']?.toString() ?? '') ??
              DateTime.fromMillisecondsSinceEpoch(0);
          final dataB = DateTime.tryParse(b['criadoEm']?.toString() ?? '') ??
              DateTime.fromMillisecondsSinceEpoch(0);
          return dataA.compareTo(dataB);
        });

      final valores = <double>[];
      final labels = <String>[];

      for (final item in pontosOrdenados) {
        final priceCents = item['priceCents'];

        final valorEmReais = priceCents is num
            ? priceCents.toDouble() / 100
            : double.tryParse(priceCents.toString()) ?? 0;

        final criadoEmTexto = item['criadoEm']?.toString();
        final criadoEm = criadoEmTexto != null
            ? DateTime.tryParse(criadoEmTexto)
            : null;

        valores.add(valorEmReais);
        labels.add(_labelGrafico(periodoTela, criadoEm));
      }

      if (!mounted) return;

      setState(() {
        valoresGrafico[periodoTela] = valores;
        labelsGrafico[periodoTela] = labels;
      });
    } on FirebaseFunctionsException catch (e) {
      debugPrint('Erro ao buscar histórico: ${e.code} - ${e.message}');
    } catch (e) {
      debugPrint('Erro inesperado ao buscar histórico: $e');
    } finally {
      if (mounted) {
        setState(() {
          carregandoGrafico = false;
        });
      }
    }
  }

  Future<List<Map<String, dynamic>>> _chamarHistoricoTokens(String periodo) async {
    try {
      final callable = FirebaseFunctions.instance.httpsCallable(
        'getTokenPriceHistoryHandler',
      );

      final result = await callable.call({
        'startupId': widget.startupId,
        'periodo': periodo,
      });

      final data = Map<String, dynamic>.from(result.data as Map);
      final history = data['history'] as List? ?? [];

      return history
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList();
    } on FirebaseFunctionsException catch (e) {
      if (e.code != 'not-found') rethrow;

      final callable = FirebaseFunctions.instance.httpsCallable(
        'getTokenPriceHistory',
      );

      final result = await callable.call({
        'startupId': widget.startupId,
        'periodo': periodo,
      });

      final data = Map<String, dynamic>.from(result.data as Map);
      final history = data['history'] as List? ?? [];

      return history
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList();
    }
  }

  String _labelGrafico(String periodoTela, DateTime? data) {
    if (data == null) return '';

    switch (periodoTela) {
      case '1D':
        return '${data.hour.toString().padLeft(2, '0')}h';
      case '7D':
        const dias = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];
        return dias[data.weekday - 1];
      case '1M':
        final semanaDoMes = ((data.day - 1) ~/ 7) + 1;
        return 'Sem $semanaDoMes';
      case '6M':
      case 'YTD':
        const meses = [
          'Jan',
          'Fev',
          'Mar',
          'Abr',
          'Mai',
          'Jun',
          'Jul',
          'Ago',
          'Set',
          'Out',
          'Nov',
          'Dez',
        ];
        return meses[data.month - 1];
      default:
        return '';
    }
  }

  String _formatarValorEscala(double valor) {
    return 'R\$ ${valor.toStringAsFixed(valor >= 10 ? 0 : 2)}';
  }

  List<String> _montarEscala(List<double> values) {
    if (values.isEmpty) {
      return ['R\$ 0', 'R\$ 0', 'R\$ 0', 'R\$ 0'];
    }

    final menorValor = values.reduce((a, b) => a < b ? a : b);
    final maiorValor = values.reduce((a, b) => a > b ? a : b);

    if (maiorValor <= 0) {
      return ['R\$ 0', 'R\$ 0', 'R\$ 0', 'R\$ 0'];
    }

    if (maiorValor == menorValor) {
      return [
        _formatarValorEscala(maiorValor),
        _formatarValorEscala(maiorValor),
        _formatarValorEscala(maiorValor),
        _formatarValorEscala(menorValor),
      ];
    }

    final intervalo = maiorValor - menorValor;

    return [
      _formatarValorEscala(maiorValor),
      _formatarValorEscala(menorValor + (intervalo * 0.66)),
      _formatarValorEscala(menorValor + (intervalo * 0.33)),
      _formatarValorEscala(menorValor),
    ];
  }

  Widget _chartCard() {
    final values = valoresGrafico[periodoSelecionado]!.isNotEmpty
        ? valoresGrafico[periodoSelecionado]!
        : valoresGraficoFallback[periodoSelecionado]!;

    final labels = labelsGrafico[periodoSelecionado]!.isNotEmpty
        ? labelsGrafico[periodoSelecionado]!
        : labelsGraficoFallback[periodoSelecionado]!;

    final escala = _montarEscala(values);

    final menorValor = values.isEmpty
        ? 0.0
        : values.reduce((a, b) => a < b ? a : b);

    final maiorValor = values.isEmpty
        ? 1.0
        : values.reduce((a, b) => a > b ? a : b);

    final intervalo = maiorValor - menorValor;

    final alturas = values.map((valor) {
      if (values.isEmpty) return 0.0;


      if (intervalo <= 0) return 120.0;


      final altura = 40 + ((valor - menorValor) / intervalo) * 150;
      return altura.clamp(12.0, 190.0);
    }).toList();

    return CardSecao(
      padding: const EdgeInsets.all(22),
      filho: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Histórico de Valorização',
            style: TextStyle(fontSize: 16),
          ),
          const Text(
            'Desempenho acumulado do token no período',
            style: TextStyle(
              fontSize: 11,
              color: Color(0xFF4B5563),
            ),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              _period('1D', active: periodoSelecionado == '1D'),
              _period('7D', active: periodoSelecionado == '7D'),
              _period('1M', active: periodoSelecionado == '1M'),
              _period('6M', active: periodoSelecionado == '6M'),
              _period('YTD', active: periodoSelecionado == 'YTD'),
            ],
          ),

          const SizedBox(height: 26),

          if (carregandoGrafico)
            const SizedBox(
              height: 260,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          else
            SizedBox(
              height: 260,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  SizedBox(
                    width: 48,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: escala.map((item) {
                        return Text(
                          item,
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.grey,
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final larguraMinima = constraints.maxWidth;
                        final larguraConteudo = values.length * 48.0;
                        final larguraGrafico = larguraConteudo < larguraMinima
                            ? larguraMinima
                            : larguraConteudo;

                        return SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          child: SizedBox(
                            width: larguraGrafico,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisAlignment: values.length <= 6
                                  ? MainAxisAlignment.spaceAround
                                  : MainAxisAlignment.start,
                              children: List.generate(values.length, (index) {
                                final active = index == values.length - 1;

                                return Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 5),
                                  child: SizedBox(
                                    width: 38,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        TweenAnimationBuilder<double>(
                                          key: ValueKey('$periodoSelecionado-$index-${alturas[index]}'),
                                          tween: Tween<double>(
                                            begin: 0,
                                            end: alturas[index],
                                          ),
                                          duration: const Duration(milliseconds: 700),
                                          curve: Curves.easeOutCubic,
                                          builder: (context, alturaAnimada, child) {
                                            return Container(
                                              width: 34,
                                              height: alturaAnimada,
                                              decoration: BoxDecoration(
                                                gradient: active
                                                    ? const LinearGradient(
                                                  colors: [
                                                    Color(0xFF0D2CC8),
                                                    Color(0xFF8D35E6),
                                                  ],
                                                  begin: Alignment.bottomCenter,
                                                  end: Alignment.topCenter,
                                                )
                                                    : null,
                                                color: active
                                                    ? null
                                                    : const Color(0xFF9DB7EA),
                                                borderRadius:
                                                BorderRadius.circular(8),
                                              ),
                                            );
                                          },
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          index < labels.length ? labels[index] : '',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            fontSize: 9,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _period(String text, {bool active = false}) {
    return GestureDetector(
      onTap: () async {
        setState(() {
          periodoSelecionado = text;
        });

        await carregarHistoricoGrafico(text);
      },
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF0D2CC8) : const Color(0xFFE7EEFF),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: active ? Colors.white : const Color(0xFF64748B),
            fontSize: 10,
            fontWeight: active ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _teamCard(StartupDetails s) {
    if (s.founders.isEmpty) {
      return const CardSecao(
        filho: Text(
          'Equipe e Governança não informada.',
          style: TextStyle(fontSize: 14),
        ),
      );
    }

    return CardSecao(
      filho: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Equipe e Governança', style: TextStyle(fontSize: 16)),
          const SizedBox(height: 22),
          const Text(
            'PARTICIPAÇÃO SOCIETÁRIA',
            style: TextStyle(fontSize: 10, letterSpacing: 2, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          ...s.founders.map((founder) => _progress(
            '${founder.name} (${founder.role})',
            founder.equityPercent / 100,
            '${founder.equityPercent.toStringAsFixed(0)}%',
          )),
        ],
      ),
    );
  }

  Widget _progress(String name, double value, String percent) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: Text(name, style: const TextStyle(fontSize: 13))),
              Text(percent, style: const TextStyle(fontSize: 13)),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: value,
              minHeight: 7,
              backgroundColor: const Color(0xFFE3EAF8),
              valueColor: const AlwaysStoppedAnimation(Color(0xFF0D2CC8)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _docs(StartupDetails s) {
    if (s.documents.isEmpty) {
      return const Text(
        'Nenhum documento público disponível.',
        style: TextStyle(fontSize: 13, color: Color(0xFF4B5563)),
      );
    }

    return Wrap(
      spacing: 14,
      runSpacing: 14,
      children: s.documents.map((doc) {
        final title = doc['title']?.toString() ?? 'Documento';
        final type = doc['type']?.toString() ?? 'pdf';
        final url = doc['url']?.toString() ?? '';

        final icon = type == 'video'
            ? Icons.play_circle_outline
            : Icons.description_outlined;

        return _doc(title, icon, url);
      }).toList(),
    );
  }

  Widget _doc(String text, IconData icon, String url) {
    return GestureDetector(
      onTap: () async {
        if (url.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('URL do documento não disponível.')),
          );
          return;
        }

        final uri = Uri.parse(url);

        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Não foi possível abrir o documento.')),
            );
          }
        }
      },
      child: Container(
        width: 160,
        height: 95,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFCBD5E1)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: const Color(0xFF0D2CC8), size: 28),
            const SizedBox(height: 12),
            Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }

  Widget _questionsCard(StartupDetails s) {
    final currentUid = FirebaseAuth.instance.currentUser?.uid;

    return CardSecao(
      padding: const EdgeInsets.all(22),
      filho: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Perguntas da\nComunidade',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 18),
          _inputField(),
          const SizedBox(height: 18),
          if (s.publicQuestions.isEmpty && mensagensLocais.isEmpty)
            const Text(
              'Nenhuma pergunta enviada ainda.',
              style: TextStyle(fontSize: 13, color: Color(0xFF4B5563)),
            )
          else ...[
            ...s.publicQuestions.map((q) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _questionBubble(
                question: q,
                currentUid: currentUid,
              ),
            )),
            ...mensagensLocais.map((mensagem) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _localQuestionBubble(mensagem),
            )),
          ],
        ],
      ),
    );
  }

  Widget _localQuestionBubble(Map<String, dynamic> mensagem) {
    final isAnswer = mensagem['isAnswer'] == true;
    final authorName = mensagem['authorName']?.toString() ?? 'Usuário';
    final message = mensagem['message']?.toString() ?? '';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor:
          isAnswer ? const Color(0xFF0D2CC8) : const Color(0xFFEBD5FF),
          child: Text(
            isAnswer ? '◎' : iniciais(authorName),
            style: TextStyle(
              color: isAnswer ? Colors.white : const Color(0xFF8D35E6),
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: isAnswer ? Colors.white : const Color(0xFFEFF4FF),
              borderRadius: BorderRadius.circular(16),
              border: isAnswer
                  ? Border.all(color: const Color(0xFFCBD5E1))
                  : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  authorName,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  style: const TextStyle(fontSize: 13, height: 1.55),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _questionBubble({
    required StartupQuestion question,
    required String? currentUid,
  }) {
    final isAnswer = question.isAnswer;
    final canDelete = currentUid != null && question.authorUid == currentUid;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor:
          isAnswer ? const Color(0xFF0D2CC8) : const Color(0xFFEBD5FF),
          child: Text(
            isAnswer ? '◎' : iniciais(question.authorName),
            style: TextStyle(
              color: isAnswer ? Colors.white : const Color(0xFF8D35E6),
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: isAnswer ? Colors.white : const Color(0xFFEFF4FF),
              borderRadius: BorderRadius.circular(16),
              border: isAnswer ? Border.all(color: const Color(0xFFCBD5E1)) : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        question.authorName,
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w700),
                      ),
                    ),
                    if (canDelete)
                      GestureDetector(
                        onTap: () => _confirmarExclusao(question),
                        child: const Icon(
                          Icons.delete_outline,
                          size: 18,
                          color: Color(0xFFEF4444),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(question.message,
                    style: const TextStyle(fontSize: 13, height: 1.55)),
              ],
            ),
          ),
        ),
      ],
    );
  }
  Future<void> _confirmarExclusao(StartupQuestion question) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir pergunta'),
        content: const Text('Tem certeza que deseja excluir esta pergunta?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Excluir',
              style: TextStyle(color: Color(0xFFEF4444)),
            ),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    try {
      await StartupService.deleteStartupQuestion(
        startupId: widget.startupId,
        questionId: question.id,
      );
      await carregarDadosDaTela();
    } on FirebaseFunctionsException catch (e) {
      setState(() => erro = 'Erro: ${e.message}');
    } catch (e) {
      setState(() => erro = 'Erro ao excluir pergunta.');
    }
  }


  Widget _inputField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(
                hintText: 'Escreva sua pergunta...',
                border: InputBorder.none,
              ),
            ),
          ),
          IconButton(
            icon: enviandoPergunta
                ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
                : const Icon(Icons.send, color: Color(0xFF0D2CC8)),
            onPressed: enviandoPergunta ? null : enviarPergunta,
          ),
        ],
      ),
    );
  }

  Widget _investButton() {
    return BotaoGradiente(
      texto: 'Quero Investir  →',
      aoPressionar: () => abrirModalInvestimento(
        context,
        startup: startup!,
        startupId: widget.startupId,
        onSucesso: carregarDadosDaTela,
      ),
    );
  }


  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(26),
    );
  }



}


