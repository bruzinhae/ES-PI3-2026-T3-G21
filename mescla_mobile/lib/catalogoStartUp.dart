// Autor: Bruna Barbour Fernandes
// RA: 23007950

import 'package:flutter/material.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'startupInicial.dart';

const kPrimary   = Color(0xFF0035B9);
const kSecondary = Color(0xFF7E41AD);
const kSurface   = Color(0xFFF8F9FF);
const kOnSurface = Color(0xFF0B1C30);
const kOutline   = Color(0xFF747686);

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
  int _navIndex = 0;

  String filtroSelecionado = "Todas";
  String busca = "";

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

      setState(() {
        startups = data.map((item) {
          return Map<String, dynamic>.from(item);
        }).toList();

        carregando = false;
      });
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

  String formatarStage(String? stage) {
    if (stage == "nova") return "Nova";
    if (stage == "em_operacao") return "Em operação";
    if (stage == "em_expansao") return "Expansão";
    return "Sem estágio";
  }

  Color corStage(String? stage) {
    if (stage == "nova") return const Color(0xFFDDE5F7);
    if (stage == "em_operacao") return const Color(0xFFE5E8F5);
    if (stage == "em_expansao") return const Color(0xFFDFF3E4);
    return const Color(0xFFEDEDED);
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

  String valorTexto(dynamic valor) {
    if (valor == null) return "-";
    return valor.toString();
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
                "Olá, Investidor",
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

              if (carregando)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(),
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
                  }).toList(),

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
          hintText: "Buscar startups...",
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
    final nome = startup["name"] ?? "Startup sem nome";
    final descricao = startup["shortDescription"] ?? "Sem descrição.";
    final stage = startup["stage"];
    final tags = startup["tags"];

    final valorAportado =
        startup["amountRaised"] ?? startup["value"] ?? startup["valuation"];
    final tokens = startup["tokens"] ?? startup["totalTokens"];
    final crescimento = startup["growth"] ?? startup["profitability"];

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
          Row(
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
                      ),
                    ),
                    Text(
                      formatarTags(tags),
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
                padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: corStage(stage),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  formatarStage(stage),
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _info("Aportado", valorTexto(valorAportado)),
              _info("Tokens", valorTexto(tokens)),
              _info(
                "Valorização",
                valorTexto(crescimento),
                color: Colors.purple,
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
                      startupId: startup["id"],
                    ),
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
              child: const Text("Ver detalhes"),
            ),
          ),
        ],
      ),
    );
  }

  Widget _info(String title, String value, {Color? color}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.black45,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: color ?? Colors.black,
          ),
        ),
      ],
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
