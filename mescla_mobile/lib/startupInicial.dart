// Autor: Bruna Barbour Fernandes
// RA: 23007950

import 'package:flutter/material.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'catalogoStartUp.dart';

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

  Map<String, dynamic>? startup;
  List<Map<String, dynamic>> messages = [];

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
      await carregarDetalhesStartup();
      //await carregarPerguntas();

      setState(() {
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
        erro = "Erro inesperado ao carregar dados.";
      });

      debugPrint("Erro inesperado: $e");
    }
  }

  Future<void> carregarDetalhesStartup() async {
    debugPrint("Chamando getStartupDetails com id: ${widget.startupId}");

    final result = await FirebaseFunctions.instanceFor(
      region: "us-central1",
    ).httpsCallable("getStartupDetails").call({
      "startupId": widget.startupId,
    });

    debugPrint("Resposta recebida: ${result.data}");
    startup = Map<String, dynamic>.from(result.data["data"]);
    final List perguntas = startup?["publicQuestions"] ?? [];
    messages = perguntas.map((item) => Map<String, dynamic>.from(item)).toList();
  }

  /* Future<void> carregarPerguntas() async {
    final result = await FirebaseFunctions.instanceFor(
      region: "us-central1",
    ).httpsCallable("listStartupQuestions").call({
      "startupId": widget.startupId,
    });

    debugPrint("Resposta perguntas: ${result.data}");

    final List data = result.data["data"] ?? [];

    messages = data.map((item) {
      return Map<String, dynamic>.from(item);
    }).toList();
  }
  */

  Future<void> enviarPergunta() async {
    final texto = _controller.text.trim();

    if (texto.isEmpty) return;

    setState(() {
      enviandoPergunta = true;
    });

    try {
      await FirebaseFunctions.instanceFor(
        region: "us-central1",
      ).httpsCallable("createStartupQuestion").call({
        "startupId": widget.startupId,
        "message": texto,
      });

      _controller.clear();

      //await carregarPerguntas();

      setState(() {
        enviandoPergunta = false;
      });
    } on FirebaseFunctionsException catch (e) {
      setState(() {
        enviandoPergunta = false;
        erro = "Erro: ${e.message}";
      });

      debugPrint("Código: ${e.code}");
      debugPrint("Mensagem: ${e.message}");
    } catch (e) {
      setState(() {
        enviandoPergunta = false;
        erro = "Erro inesperado ao enviar pergunta.";
      });

      debugPrint("Erro inesperado: $e");
    }
  }

  String texto(dynamic valor, String padrao) {
    if (valor == null) return padrao;
    return valor.toString();
  }

  String formatarStage(dynamic stage) {
    if (stage == "nova") return "Nova";
    if (stage == "em_operacao") return "Em operação";
    if (stage == "em_expansao") return "Em expansão";
    return texto(stage, "Sem estágio");
  }

  String formatarTags(dynamic tags) {
    if (tags is List && tags.isNotEmpty) {
      return tags.join(" • ").toUpperCase();
    }

    return "STARTUP";
  }

  String iniciais(String nome) {
    final partes = nome.trim().split(" ");

    if (partes.isEmpty) return "?";
    if (partes.length == 1) return partes.first[0].toUpperCase();

    return "${partes.first[0]}${partes.last[0]}".toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    if (carregando) {
      return Scaffold(
        backgroundColor: const Color(0xFFEFF4FF),
        body: SafeArea(
          child: Center(
            child: CircularProgressIndicator(),
          ),
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

    return Scaffold(
      backgroundColor: const Color(0xFFEFF4FF),
      bottomNavigationBar: _bottomNav(),
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
                    _chips(),
                    const SizedBox(height: 16),
                    Text(
                      texto(startup?["name"], "Startup"),
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _series(),
                    const SizedBox(height: 18),
                    Text(
                      texto(
                        startup?["description"] ?? startup?["shortDescription"],
                        "Sem descrição.",
                      ),
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.6,
                        color: Color(0xFF4B5563),
                      ),
                    ),
                    const SizedBox(height: 28),
                    _metrics(),
                    const SizedBox(height: 24),
                    _chartCard(),
                    const SizedBox(height: 24),
                    _teamCard(),
                    const SizedBox(height: 24),
                    const Text(
                      "Documentação Pública",
                      style: TextStyle(
                        fontSize: 15,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 14),
                    _docs(),
                    const SizedBox(height: 24),
                    _questionsCard(),
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
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const CatalogoStartUp(),
              ),
            );
          },
          child: const Icon(
            Icons.arrow_back,
            color: Color(0xFF0D2CC8),
            size: 22,
          ),
        ),
        const SizedBox(width: 18),
        const Expanded(
          child: Text(
            "MesclaInvest",
            style: TextStyle(
              color: Color(0xFF0D2CC8),
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
        ),
        const Icon(
          Icons.favorite_border,
          color: Color(0xFF0D2CC8),
          size: 24,
        ),
      ],
    );
  }

  Widget _chips() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        _chip(formatarTags(startup?["tags"])),
        _chip(formatarStage(startup?["stage"])),
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

  Widget _series() {
    return Row(
      children: [
        const Icon(Icons.eco_outlined, color: Color(0xFF0D2CC8), size: 26),
        const SizedBox(width: 12),
        Text(
          texto(startup?["round"] ?? startup?["series"], "Rodada não informada"),
          style: const TextStyle(
            color: Color(0xFF0D2CC8),
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _metrics() {
    return GridView.count(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      crossAxisCount: 2,
      childAspectRatio: 2,
      crossAxisSpacing: 14,
      mainAxisSpacing: 14,
      children: [
        _MetricCard(
          title: "Capital aportado",
          value: texto(startup?["amountRaised"] ?? startup?["value"], "-"),
        ),
        _MetricCard(
          title: "Tokens totais",
          value: texto(startup?["tokens"] ?? startup?["totalTokens"], "-"),
        ),
        _MetricCard(
          title: "Valor do Token",
          value: texto(startup?["tokenValue"], "-"),
        ),
        _MetricCard(
          title: "Valorização",
          value: texto(startup?["growth"] ?? startup?["profitability"], "-"),
          green: true,
        ),
      ],
    );
  }

  Widget _chartCard() {
    final values = [72.0, 105.0, 82.0, 135.0, 165.0, 210.0];
    final months = ["Jan", "Fev", "Mar", "Abr", "Mai", "Jun"];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Histórico de Valorização",
            style: TextStyle(fontSize: 16),
          ),
          const Text(
            "Desempenho acumulado do token no período",
            style: TextStyle(fontSize: 11, color: Color(0xFF4B5563)),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _period("1D"),
              _period("7D"),
              _period("1M"),
              _period("6M", active: true),
              _period("YTD"),
            ],
          ),
          const SizedBox(height: 26),
          SizedBox(
            height: 240,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("R\$ 30", style: TextStyle(fontSize: 10, color: Colors.grey)),
                    Text("R\$ 20", style: TextStyle(fontSize: 10, color: Colors.grey)),
                    Text("R\$ 10", style: TextStyle(fontSize: 10, color: Colors.grey)),
                    Text("R\$ 0", style: TextStyle(fontSize: 10, color: Colors.grey)),
                  ],
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: List.generate(values.length, (index) {
                      final active = index == values.length - 1;

                      return Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            width: 34,
                            height: values[index],
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
                          ),
                          const SizedBox(height: 12),
                          Text(
                            months[index],
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.grey,
                            ),
                          ),
                        ],
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
    return Container(
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: active ? Colors.white : const Color(0xFFE7EEFF),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: active ? const Color(0xFF0D2CC8) : const Color(0xFF64748B),
          fontSize: 10,
          fontWeight: active ? FontWeight.w700 : FontWeight.w500,
        ),
      ),
    );
  }

  Widget _teamCard() {
    final team = startup?["team"];

    if (team is! List || team.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: _cardDecoration(),
        child: const Text(
          "Equipe e Governança não informada.",
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
          const Text("Equipe e Governança", style: TextStyle(fontSize: 16)),
          const SizedBox(height: 22),
          const Text(
            "PARTICIPAÇÃO SOCIETÁRIA",
            style: TextStyle(fontSize: 10, letterSpacing: 2, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          ...team.map((person) {
            final item = Map<String, dynamic>.from(person);
            final name = texto(item["name"], "Integrante");
            final role = texto(item["role"], "Cargo não informado");
            final percent = item["equity"] ?? 0;

            return _progress(
              "$name ($role)",
              percent is num ? percent / 100 : 0,
              "${texto(percent, "0")}%",
            );
          }),
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

  Widget _docs() {
    final docs = startup?["documents"];

    if (docs is! List || docs.isEmpty) {
      return const Text(
        "Nenhum documento público disponível.",
        style: TextStyle(fontSize: 13, color: Color(0xFF4B5563)),
      );
    }

    return Wrap(
      spacing: 14,
      runSpacing: 14,
      children: docs.map((doc) {
        final item = Map<String, dynamic>.from(doc);

        return _doc(
          texto(item["title"], "Documento"),
          Icons.description_outlined,
        );
      }).toList(),
    );
  }

  Widget _doc(String text, IconData icon) {
    return Container(
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
    );
  }

  Widget _questionsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Perguntas da\nComunidade",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 18),
          _inputField(),
          const SizedBox(height: 18),
          if (messages.isEmpty)
            const Text(
              "Nenhuma pergunta enviada ainda.",
              style: TextStyle(fontSize: 13, color: Color(0xFF4B5563)),
            )
          else
            ...messages.map((msg) {
              final name = texto(msg["name"] ?? msg["authorName"], "Usuário");
              final message = texto(msg["message"], "");
              final isAnswer = msg["isAnswer"] == true || msg["isUser"] == false;

              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _questionBubble(
                  initials: isAnswer ? "◎" : iniciais(name),
                  name: name,
                  text: message,
                  isAnswer: isAnswer,
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _questionBubble({
    required String initials,
    required String name,
    required String text,
    required bool isAnswer,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: isAnswer
              ? const Color(0xFF0D2CC8)
              : const Color(0xFFEBD5FF),
          child: Text(
            initials,
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
                  name,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Text(
                  text,
                  style: const TextStyle(fontSize: 13, height: 1.55),
                ),
              ],
            ),
          ),
        ),
      ],
    );
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
                hintText: "Escreva sua pergunta...",
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
      onTap: () {
        debugPrint("Investir na startup: ${widget.startupId}");
      },
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
            "Quero Investir  →",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }

  Widget _bottomNav() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFF0D2CC8),
      unselectedItemColor: const Color(0xFF64748B),
      selectedFontSize: 11,
      unselectedFontSize: 11,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.search), label: "Catálogo"),
        BottomNavigationBarItem(icon: Icon(Icons.swap_vert), label: "Negociar"),
        BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet), label: "Carteira"),
        BottomNavigationBarItem(icon: Icon(Icons.grid_view), label: "Dashboard"),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: "Perfil"),
      ],
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(26),
    );
  }
}

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