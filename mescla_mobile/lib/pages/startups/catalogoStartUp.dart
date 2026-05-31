// Autor: Bruna Barbour Fernandes
// RA: 23007950

import 'package:flutter/material.dart';
import 'package:cloud_functions/cloud_functions.dart';

import '../../widgets/bottom_navBar.dart';
import 'services/startup_service.dart';
import 'startupInicial.dart';

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
  String filtroSelecionado = 'Todas';
  String busca = '';

  bool carregando = true;
  String? erro;

  List<Map<String, dynamic>> startups = [];

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
      final result = await FirebaseFunctions.instanceFor(
        region: 'us-central1',
      ).httpsCallable('listStartups').call({
        'stage': _stageSelecionado(),
        'search': busca,
      });

      final List data = result.data['data'];

      final lista = data.map((item) {
        return Map<String, dynamic>.from(item);
      }).toList();

      await _adicionarValorizacaoFormatada(lista);

      if (!mounted) return;

      setState(() {
        startups = lista;
        carregando = false;
      });
    } on FirebaseFunctionsException catch (e) {
      if (!mounted) return;

      setState(() {
        carregando = false;
        erro = 'Erro: ${e.message}';
      });

      debugPrint('Código: ${e.code}');
      debugPrint('Mensagem: ${e.message}');
      debugPrint('Detalhes: ${e.details}');
    } catch (e) {
      if (!mounted) return;

      setState(() {
        carregando = false;
        erro = 'Erro inesperado ao carregar startups.';
      });

      debugPrint('Erro inesperado: $e');
    }
  }

  String? _stageSelecionado() {
    switch (filtroSelecionado) {
      case 'Nova':
        return 'nova';
      case 'Em operação':
        return 'em_operacao';
      case 'Expansão':
        return 'em_expansao';
      default:
        return null;
    }
  }

  Future<void> _adicionarValorizacaoFormatada(
      List<Map<String, dynamic>> lista,
      ) async {
    for (final startup in lista) {
      final id = _startupId(startup);
      if (id == null) continue;

      try {
        final detalhes = await StartupService.getStartupDetails(id);
        startup['valorizacaoFormatada'] = detalhes.valorizacaoFormatada;
      } catch (e) {
        debugPrint('Erro ao carregar valorização da startup $id: $e');
      }
    }
  }

  String? _startupId(Map<String, dynamic> startup) {
    final id = startup['id'] ??
        startup['startupId'] ??
        startup['documentId'] ??
        startup['uid'];

    final texto = id?.toString().trim();
    return texto == null || texto.isEmpty ? null : texto;
  }

  String _formatarStage(String? stage) {
    switch (stage) {
      case 'nova':
        return 'Nova';
      case 'em_operacao':
        return 'Em operação';
      case 'em_expansao':
        return 'Expansão';
      default:
        return 'Sem estágio';
    }
  }

  Color _corStage(String? stage) {
    switch (stage) {
      case 'nova':
        return const Color(0xFFDDE5F7);
      case 'em_operacao':
        return const Color(0xFFE5E8F5);
      case 'em_expansao':
        return const Color(0xFFDFF3E4);
      default:
        return const Color(0xFFEDEDED);
    }
  }

  IconData _iconeStartup(Map<String, dynamic> startup) {
    final tags = startup['tags'];

    if (tags is List) {
      final textoTags = tags.join(' ').toLowerCase();

      if (textoTags.contains('agricultura')) return Icons.eco;
      if (textoTags.contains('saúde') || textoTags.contains('saude')) {
        return Icons.health_and_safety;
      }
      if (textoTags.contains('finança') || textoTags.contains('financa')) {
        return Icons.attach_money;
      }
      if (textoTags.contains('varejo')) return Icons.store;
      if (textoTags.contains('casa') || textoTags.contains('home')) {
        return Icons.home;
      }
    }

    return Icons.rocket_launch;
  }

  String _formatarTags(dynamic tags) {
    if (tags is List && tags.isNotEmpty) {
      return tags.join(' • ').toUpperCase();
    }

    return 'STARTUP';
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

  String _formatarDinheiro(dynamic valor) {
    final numero = _converterNumero(valor);
    if (numero == null) return 'Não informado';

    final reais = numero / 100;
    return reais == 0 ? 'R\$ 0' : 'R\$ ${_formatarCompacto(reais)}';
  }

  String _formatarQuantidade(dynamic valor) {
    final numero = _converterNumero(valor);
    return numero == null ? 'Não informado' : _formatarCompacto(numero);
  }

  bool _valorizacaoPositiva(dynamic valor) {
    final numero = _converterNumero(valor);
    return numero == null || numero >= 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const BottomNavBar(selectedIndex: 0),
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
                'Olá, Investidor',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _search(),
              const SizedBox(height: 16),
              _filters(),
              const SizedBox(height: 20),
              _content(),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _content() {
    if (carregando) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (erro != null) {
      return Center(
        child: Text(
          erro!,
          style: const TextStyle(color: Colors.red),
        ),
      );
    }

    if (startups.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text('Nenhuma startup encontrada.'),
        ),
      );
    }

    return Column(
      children: startups.map((startup) {
        return _startupCard(context, startup);
      }).toList(),
    );
  }

  Widget _topBar() {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'MesclaInvest',
          style: TextStyle(
            color: Color(0xFF3D5AFE),
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
      ),
      child: TextField(
        onChanged: (value) {
          busca = value;
          carregarStartups();
        },
        decoration: const InputDecoration(
          icon: Icon(Icons.search),
          hintText: 'Buscar startups...',
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
          _chip('Todas'),
          _chip('Nova'),
          _chip('Em operação'),
          _chip('Expansão'),
        ],
      ),
    );
  }

  Widget _chip(String text) {
    final selected = filtroSelecionado == text;

    return GestureDetector(
      onTap: () {
        setState(() => filtroSelecionado = text);
        carregarStartups();
      },
      child: Padding(
        padding: const EdgeInsets.only(right: 8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          decoration: BoxDecoration(
            gradient: selected
                ? const LinearGradient(
              colors: [
                Color(0xFF3D5AFE),
                Color(0xFF7B1FA2),
              ],
            )
                : null,
            color: selected ? null : Colors.white,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Text(
            text,
            style: TextStyle(
              color: selected ? Colors.white : Colors.black54,
              fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _startupCard(BuildContext context, Map<String, dynamic> startup) {
    final id = _startupId(startup);
    final nome = startup['name'] ?? 'Startup sem nome';
    final descricao = startup['shortDescription'] ?? 'Sem descrição.';
    final stage = startup['stage'];
    final tags = startup['tags'];

    final valorAportado = startup['capitalRaisedCents'] ??
        startup['value'] ??
        startup['valuation'];

    final tokens = startup['totalTokensIssued'] ?? startup['totalTokens'];
    final valorizacao = startup['valorizacaoFormatada'] ?? 'Não informado';
    final valorizacaoPositiva = _valorizacaoPositiva(valorizacao);

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _startupHeader(nome, tags, stage, startup),
          const SizedBox(height: 12),
          Text(
            descricao,
            style: const TextStyle(
              color: Colors.black54,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _info(
                  title: 'Aportado',
                  value: _formatarDinheiro(valorAportado),
                  icon: Icons.account_balance_wallet_outlined,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _info(
                  title: 'Tokens',
                  value: _formatarQuantidade(tokens),
                  icon: Icons.generating_tokens_outlined,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _info(
                  title: 'Valorização',
                  value: valorizacao,
                  icon: valorizacaoPositiva
                      ? Icons.trending_up
                      : Icons.trending_down,
                  color: valorizacaoPositiva
                      ? const Color(0xFF16A34A)
                      : const Color(0xFFDC2626),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: id == null
                  ? null
                  : () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => StartupInicial(startupId: id),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: const Text('Ver detalhes'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _startupHeader(
      String nome,
      dynamic tags,
      String? stage,
      Map<String, dynamic> startup,
      ) {
    return Row(
      children: [
        Container(
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
          child: Icon(
            _iconeStartup(startup),
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
                ),
              ),
              Text(
                _formatarTags(tags),
                style: const TextStyle(
                  fontSize: 12,
                  letterSpacing: 1.2,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _corStage(stage),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            _formatarStage(stage),
            style: const TextStyle(fontSize: 12),
          ),
        ),
      ],
    );
  }

  Widget _info({
    required String title,
    required String value,
    Color? color,
    IconData? icon,
  }) {
    final corPrincipal = color ?? const Color(0xFF0B1C30);

    return Container(
      constraints: const BoxConstraints(minHeight: 86),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F6FF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE1E6F5)),
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
              color: Color(0xFF747686),
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
