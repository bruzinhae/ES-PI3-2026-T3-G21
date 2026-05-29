// Autor: Bruna Barbour Fernandes
// RA: 23007950

import 'package:flutter/material.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'catalogoStartUp.dart';
import '../pages/../startups/services/startup_service.dart';
import '../../widgets/bottom_navBar.dart';
import 'modal_investimento.dart';
import 'modal_perguntaPrivada.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
      debugPrint('=== DOCUMENTS ===');
      debugPrint(dados.documents.toString());
      debugPrint('executiveSummary: ${dados.executiveSummary}');
      debugPrint('pitchDeckUrl: ${dados.pitchDeckUrl}');
      debugPrint('demoVideos: ${dados.demoVideos}');

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
    debugPrint('=== ANTES DE ENVIAR ===');
    debugPrint('uid: ${user?.uid}');
    debugPrint('email: ${user?.email}');
    if (user != null) {
      final token = await user.getIdToken(false);
      debugPrint('token (primeiros 30): ${token?.substring(0, 30)}');
    }

    setState(() => enviandoPergunta = true);


    try {
      await StartupService.createStartupQuestion(
        startupId: widget.startupId,
        message: texto,
      );

      _controller.clear();
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

  // ─── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (carregando) {
      return const Scaffold(
        backgroundColor: Color(0xFFEFF4FF),
        body: SafeArea(
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (erro != null) {
      return Scaffold(
        backgroundColor: const Color(0xFFEFF4FF),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: Text(
                erro!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
            ),
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

  // ─── Widgets ───────────────────────────────────────────────────────────────

  Widget _topBar() {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const CatalogoStartUp()),
          ),
          child: const Icon(Icons.arrow_back, color: Color(0xFF0D2CC8), size: 22),
        ),
        const SizedBox(width: 18),
        const Expanded(
          child: Text(
            'MesclaInvest',
            style: TextStyle(
              color: Color(0xFF0D2CC8),
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
        ),
        const Icon(Icons.favorite_border, color: Color(0xFF0D2CC8), size: 24),
      ],
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFDDE8FF),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF0D2CC8),
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1,
        ),
      ),
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
    return GridView.count(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      crossAxisCount: 2,
      childAspectRatio: 2,
      crossAxisSpacing: 14,
      mainAxisSpacing: 14,
      children: [
        _MetricCard(
          title: 'Capital aportado',
          value: s.capitalFormatado,
        ),
        _MetricCard(
          title: 'Tokens totais',
          value: s.tokensFormatados,
        ),
        _MetricCard(
          title: 'Valor do Token',
          value: s.tokenPriceFormatado,
        ),
        _MetricCard(
          title: 'Valorização',
          value: s.valorizacaoFormatada,
          green: true,
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

      final valores = <double>[];
      final labels = <String>[];

      for (final item in history) {
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
        return '${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}';
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

    final maiorValor = values.reduce((a, b) => a > b ? a : b);

    if (maiorValor <= 0) {
      return ['R\$ 0', 'R\$ 0', 'R\$ 0', 'R\$ 0'];
    }

    return [
      _formatarValorEscala(maiorValor),
      _formatarValorEscala(maiorValor * 0.66),
      _formatarValorEscala(maiorValor * 0.33),
      'R\$ 0',
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

    final maiorValor = values.isEmpty
        ? 1.0
        : values.reduce((a, b) => a > b ? a : b);

    final alturas = values.map((valor) {
      if (maiorValor <= 0) return 0.0;

      final altura = (valor / maiorValor) * 190;
      return altura < 12 ? 12.0 : altura;
    }).toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: _cardDecoration(),
      child: Column(
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
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
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

                  const SizedBox(width: 14),

                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: List.generate(values.length, (index) {
                        final active = index == values.length - 1;

                        return SizedBox(
                          width: 38,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TweenAnimationBuilder<double>(
                                key: ValueKey('$periodoSelecionado-$index'),
                                tween: Tween<double>(
                                  end: alturas[index],
                                ),
                                duration: const Duration(milliseconds: 800),
                                curve: Curves.easeInOutCubic,
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
                                      color: active ? null : const Color(0xFF9DB7EA),
                                      borderRadius: BorderRadius.circular(8),
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
                        );
                      }),
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
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: _cardDecoration(),
        child: const Text(
          'Equipe e Governança não informada.',
          style: TextStyle(fontSize: 14),
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: _cardDecoration(),
      child: Column(
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

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Perguntas da\nComunidade',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 18),
          _inputField(),
          const SizedBox(height: 18),
          if (s.publicQuestions.isEmpty)
            const Text(
              'Nenhuma pergunta enviada ainda.',
              style: TextStyle(fontSize: 13, color: Color(0xFF4B5563)),
            )
          else
            ...s.publicQuestions.map((q) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _questionBubble(
                question: q,
                currentUid: currentUid,
              ),
            )),
        ],
      ),
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
    return GestureDetector(
      onTap: () => abrirModalInvestimento(
        context,
        startup: startup!,
        startupId: widget.startupId,
        onSucesso: carregarDadosDaTela,
      ),
      child: Container(
        width: double.infinity,
        height: 58,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: const LinearGradient(
            colors: [Color(0xFF0D2CC8), Color(0xFF8D35E6)],
          ),
        ),
        child: const Center(
          child: Text(
            'Quero Investir  →',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
          ),
        ),
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

// metricCard

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final bool green;

  const _MetricCard({
    required this.title,
    required this.value,
    this.green = false,
  });



  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 11, color: Color(0xFF4B5563)),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              if (green)
                const Icon(Icons.trending_up, color: Colors.green, size: 16),
              if (green) const SizedBox(width: 4),
              Expanded(
                child: Text(
                  value,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: green ? Colors.green : Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
class _InvestorMetric extends StatelessWidget {
  final String title;
  final String value;
  final String? suffix;
  final bool green;

  const _InvestorMetric({
    required this.title,
    required this.value,
    this.suffix,
    this.green = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF94A3B8),
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.4,
          ),
        ),
        const SizedBox(height: 8),
        RichText(
          text: TextSpan(
            text: value,
            style: TextStyle(
              color: green ? const Color(0xFF34D399) : Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
            children: [
              if (suffix != null)
                TextSpan(
                  text: suffix,
                  style: const TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}