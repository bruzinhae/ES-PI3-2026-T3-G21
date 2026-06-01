// Autor: Bruna Barbour Fernandes
// RA: 23007950

import 'package:flutter/material.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:mescla_mobile/utils/app_colors.dart';
import 'startupInicial.dart';
import 'services/startup_service.dart';
import '../balcão/balcao.dart';
import '../carteira/carteira.dart';
import '../../widgets/bottom_navBar.dart';

class CatalogoStartUp extends StatelessWidget {
  const CatalogoStartUp({super.key});

  @override
  Widget build(BuildContext context) {
    return const HomeScreen();
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String filtroSelecionado = "Todas";
  String busca = "";

  bool carregando = true;
  String? erro;

  List<Map<String, dynamic>> startups = [];
  Map<String, String> valorizacoesFormatadas = {};
  bool carregandoValorizacoes = false;

  @override
  void initState() {
    super.initState();
    carregarStartups();
  }

  Future<void> carregarStartups() async {
    setState(() {
      carregando = true;
      erro = null;
    });

    try {
      String? stage;

      if (filtroSelecionado == "Nova") {
        stage = "nova";
      } else if (filtroSelecionado == "Em operação") {
        stage = "em_operacao";
      } else if (filtroSelecionado == "Expansão") {
        stage = "em_expansao";
      }

      final result = await FirebaseFunctions.instanceFor(
        region: "us-central1",
      ).httpsCallable("listStartups").call({
        "stage": stage,
        "search": busca,
      });

      final List data = result.data["data"];

      final startupsCarregadas = data.map((item) {
        return Map<String, dynamic>.from(item);
      }).toList();

      setState(() {
        startups = startupsCarregadas;
        valorizacoesFormatadas = {};
        carregandoValorizacoes = true;
        carregando = false;
      });

      await carregarValorizacoesDasStartups(startupsCarregadas);
    } on FirebaseFunctionsException catch (e) {
      setState(() {
        carregando = false;
        erro = "Erro: ${e.message}";
      });

      debugPrint("Código: ${e.code}");
      debugPrint("Mensagem: ${e.message}");
      debugPrint("Detalhes: ${e.details}");
    } catch (e) {
      setState(() {
        carregando = false;
        erro = "Erro inesperado ao carregar startups.";
      });

      debugPrint("Erro inesperado: $e");
    }
  }

  String? _extrairStartupId(Map<String, dynamic> startup) {
    final id = startup["id"] ??
        startup["startupId"] ??
        startup["documentId"] ??
        startup["uid"];

    final texto = id?.toString().trim();
    if (texto == null || texto.isEmpty) return null;
    return texto;
  }

  String _formatarValorizacaoParaCard(dynamic valor) {
    if (valor == null) return 'Não informado';

    final texto = valor.toString().trim();
    if (texto.isEmpty) return 'Não informado';

    if (texto.contains('%')) return texto;

    return formatarPorcentagem(valor);
  }

  Future<String?> buscarValorizacaoStartup(String startupId) async {
    try {
      final detalhes = await StartupService.getStartupDetails(startupId);
      final valor = detalhes.valorizacaoFormatada.trim();

      if (valor.isEmpty) return null;
      return valor;
    } on FirebaseFunctionsException catch (e) {
      debugPrint(
        "Erro ao buscar detalhes da valorização para $startupId: ${e.code} - ${e.message}",
      );
      return null;
    } catch (e) {
      debugPrint("Erro inesperado ao buscar valorização da startup $startupId: $e");
      return null;
    }
  }

  Future<void> carregarValorizacoesDasStartups(
      List<Map<String, dynamic>> listaStartups,
      ) async {
    final novasValorizacoes = <String, String>{};

    for (final startup in listaStartups) {
      final startupId = _extrairStartupId(startup);
      if (startupId == null) continue;

      final variacaoFormatada = await buscarValorizacaoStartup(startupId);

      if (variacaoFormatada != null && variacaoFormatada.isNotEmpty) {
        novasValorizacoes[startupId] = variacaoFormatada;
        startup["valorizacaoFormatada"] = variacaoFormatada;
      }
    }

    if (!mounted) return;

    setState(() {
      valorizacoesFormatadas = novasValorizacoes;
      carregandoValorizacoes = false;
    });
  }

  String formatarStage(String? stage) {
    if (stage == "nova") return "Nova";
    if (stage == "em_operacao") return "Em operação";
    if (stage == "em_expansao") return "Expansão";
    return "Sem estágio";
  }

  Color corStage(String? stage) {
    if (stage == "nova") return kPrimary.withOpacity(0.12);
    if (stage == "em_operacao") return kSecondary.withOpacity(0.12);
    if (stage == "em_expansao") return const Color(0xFFDFF3E4);
    return kOutline.withOpacity(0.15);
  }

  IconData iconeStartup(Map<String, dynamic> startup) {
    final tags = startup["tags"];

    if (tags is List) {
      final textoTags = tags.join(" ").toLowerCase();

      if (textoTags.contains("agricultura")) return Icons.eco;
      if (textoTags.contains("saúde") || textoTags.contains("saude")) {
        return Icons.health_and_safety;
      }
      if (textoTags.contains("finança") || textoTags.contains("financa")) {
        return Icons.attach_money;
      }
      if (textoTags.contains("varejo")) return Icons.store;
      if (textoTags.contains("casa") || textoTags.contains("home")) {
        return Icons.home;
      }
    }

    return Icons.rocket_launch;
  }

  String formatarTags(dynamic tags) {
    if (tags is List && tags.isNotEmpty) {
      return tags.join(" • ").toUpperCase();
    }

    return "STARTUP";
  }

  num? _converterNumero(dynamic valor) {
    if (valor == null) return null;

    if (valor is num) return valor;

    final texto = valor
        .toString()
        .replaceAll('R\$', '')
        .replaceAll('%', '')
        .replaceAll('.', '')
        .replaceAll(',', '.')
        .trim();

    return num.tryParse(texto);
  }

  String _formatarCompacto(num valor) {
    final absoluto = valor.abs();

    if (absoluto >= 1000000000) {
      final v = valor / 1000000000;
      return '${v.toStringAsFixed(v.abs() >= 10 ? 1 : 2).replaceAll('.', ',')} bi';
    }

    if (absoluto >= 1000000) {
      final v = valor / 1000000;
      return '${v.toStringAsFixed(v.abs() >= 10 ? 1 : 2).replaceAll('.', ',')} mi';
    }

    if (absoluto >= 1000) {
      final v = valor / 1000;
      return '${v.toStringAsFixed(v.abs() >= 10 ? 0 : 1).replaceAll('.', ',')} mil';
    }

    return valor.toStringAsFixed(0).replaceAll('.', ',');
  }

  String formatarDinheiro(dynamic valor, {bool emCentavos = true}) {
    final numero = _converterNumero(valor);

    if (numero == null) return 'Não informado';

    final valorReais = emCentavos ? numero / 100 : numero;

    if (valorReais == 0) return 'R\$ 0';

    return 'R\$ ${_formatarCompacto(valorReais)}';
  }

  String formatarQuantidade(dynamic valor) {
    final numero = _converterNumero(valor);

    if (numero == null) return 'Não informado';

    return _formatarCompacto(numero);
  }

  String formatarPorcentagem(dynamic valor) {
    final numero = _converterNumero(valor);

    if (numero == null) return 'Não informado';

    final texto = numero.toStringAsFixed(2).replaceAll('.', ',');
    final sinal = numero > 0 ? '+' : '';

    return '$sinal$texto%';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const BottomNavBar(
        selectedIndex: 0,
      ),
      backgroundColor: kSurface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _topBar(),
              const SizedBox(height: 16),
              const Text(
                "Olá, Investidor",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: kOnSurface,
                ),
              ),
              const SizedBox(height: 16),
              _search(),
              const SizedBox(height: 16),
              _filters(),
              const SizedBox(height: 20),

              if (carregando)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(kPrimary),
                    ),
                  ),
                )
              else if (erro != null)
                Center(
                  child: Text(
                    erro!,
                    style: const TextStyle(color: Colors.red),
                  ),
                )
              else if (startups.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Text("Nenhuma startup encontrada."),
                    ),
                  )
                else
                  ...startups.map((startup) {
                    return _startupCard(context, startup);
                  }),

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _topBar() {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "MesclaInvest",
          style: TextStyle(
            color: kPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _search() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: kOutline.withOpacity(0.16)),
      ),
      child: TextField(
        onChanged: (value) {
          busca = value;
          carregarStartups();
        },
        decoration: const InputDecoration(
          icon: Icon(Icons.search, color: kOutline),
          hintText: "Buscar startups...",
          hintStyle: TextStyle(color: kOutline),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _filters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _chip("Todas"),
          _chip("Nova"),
          _chip("Em operação"),
          _chip("Expansão"),
        ],
      ),
    );
  }

  Widget _chip(String text) {
    final selected = filtroSelecionado == text;

    return GestureDetector(
      onTap: () {
        setState(() {
          filtroSelecionado = text;
        });

        carregarStartups();
      },
      child: Padding(
        padding: const EdgeInsets.only(right: 8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          decoration: BoxDecoration(
            gradient: selected ? kGradient : null,
            color: selected ? null : Colors.white,
            borderRadius: BorderRadius.circular(25),
            border: selected ? null : Border.all(color: kOutline.withOpacity(0.16)),
          ),
          child: Text(
            text,
            style: TextStyle(
              color: selected ? Colors.white : kOutline,
              fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _startupCard(BuildContext context, Map<String, dynamic> startup) {
    final nome = startup["name"] ?? "Startup sem nome";
    final descricao = startup["shortDescription"] ?? "Sem descrição.";
    final stage = startup["stage"];
    final tags = startup["tags"];

    final valorAportado = startup["capitalRaisedCents"] ??
        startup["value"] ??
        startup["valuation"];
    final tokens = startup["totalTokensIssued"] ?? startup["totalTokens"];
    final startupId = _extrairStartupId(startup);

    final crescimento = startupId != null && valorizacoesFormatadas.containsKey(startupId)
        ? valorizacoesFormatadas[startupId]
        : startup["valorizacaoFormatada"] ??
        startup["valuationFormatted"] ??
        startup["variacaoFormatada"] ??
        startup["variacaoPercent"] ??
        startup["growth"] ??
        startup["profitability"];

    final valorAportadoFormatado = formatarDinheiro(valorAportado);
    final tokensFormatados = formatarQuantidade(tokens);
    final crescimentoFormatado = crescimento == null && carregandoValorizacoes
        ? "Buscando..."
        : _formatarValorizacaoParaCard(crescimento);
    final crescimentoNumero = _converterNumero(crescimento);
    final crescimentoPositivo = (crescimentoNumero ?? 0) >= 0;
    final crescimentoColor = crescimentoNumero == null
        ? kSecondary
        : crescimentoPositivo
        ? const Color(0xFF16A34A)
        : const Color(0xFFDC2626);
    final crescimentoIcon = crescimentoNumero == null
        ? Icons.trending_up
        : crescimentoPositivo
        ? Icons.trending_up
        : Icons.trending_down;

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: kPrimary.withOpacity(0.08),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: kGradient,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  iconeStartup(startup),
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nome,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: kOnSurface,
                      ),
                    ),
                    Text(
                      formatarTags(tags),
                      style: const TextStyle(
                        fontSize: 12,
                        letterSpacing: 1.2,
                        color: kPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: corStage(stage),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  formatarStage(stage),
                  style: const TextStyle(fontSize: 12, color: kOnSurface),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            descricao,
            style: const TextStyle(
              color: kOutline,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _info(
                  "Aportado",
                  valorAportadoFormatado,
                  icon: Icons.account_balance_wallet_outlined,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _info(
                  "Tokens",
                  tokensFormatados,
                  icon: Icons.generating_tokens_outlined,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _info(
                  "Valorização",
                  crescimentoFormatado,
                  icon: crescimentoIcon,
                  color: crescimentoColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StartupInicial(
                      startupId: _extrairStartupId(startup) ?? startup["id"].toString(),
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: kPrimary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                side: BorderSide(color: kPrimary.withOpacity(0.20)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: const Text("Ver detalhes"),
            ),
          ),
        ],
      ),
    );
  }

  Widget _info(
      String title,
      String value, {
        Color? color,
        IconData? icon,
      }) {
    final corPrincipal = color ?? kOnSurface;

    return Container(
      constraints: const BoxConstraints(
        minHeight: 86,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: kOutline.withOpacity(0.14),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 18,
              color: corPrincipal.withOpacity(0.78),
            ),
            const SizedBox(height: 8),
          ],
          Text(
            title.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 9,
              letterSpacing: 0.8,
              fontWeight: FontWeight.w700,
              color: kOutline,
            ),
          ),
          const SizedBox(height: 5),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              maxLines: 1,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: corPrincipal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
