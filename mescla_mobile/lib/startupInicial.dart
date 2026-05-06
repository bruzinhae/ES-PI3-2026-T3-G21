// Autor: Bruna Barbour Fernandes
// RA: 23007950

import 'package:flutter/material.dart';
import 'catalogoStartUp.dart';

class StartupInicial extends StatelessWidget {
  const StartupInicial({super.key});

  @override
  Widget build(BuildContext context) {
    return const InvestPage();
  }
}

class InvestPage extends StatefulWidget {
  const InvestPage({super.key});

  @override
  State<InvestPage> createState() => _InvestPageState();
}

class _InvestPageState extends State<InvestPage> {
  final TextEditingController _controller = TextEditingController();

  List<Map<String, dynamic>> messages = [
    {
      "name": "Ricardo Camargo",
      "message":
      "Como a EcoTech planeja mitigar o risco de flutuação no preço das commodities recicladas?",
      "isUser": true,
    },
    {
      "name": "Time EcoTech (CEO)",
      "message":
      "Olá Ricardo! Mantemos contratos de longo prazo com grandes indústrias que garantem estabilidade de margem.",
      "isUser": false,
    },
  ];

  @override
  Widget build(BuildContext context) {
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
                    const Text(
                      "EcoTech Solutions",
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _series(),
                    const SizedBox(height: 18),
                    const Text(
                      "Revolucionando a economia circular através de tecnologia proprietária de triagem automatizada e reciclagem química de alta eficiência.",
                      style: TextStyle(
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
            Navigator.push(
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
    return Row(
      children: [
        _chip("SUSTENTABILIDADE"),
        const SizedBox(width: 10),
        _chip("Em expansão"),
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
      children: const [
        Icon(Icons.eco_outlined, color: Color(0xFF0D2CC8), size: 26),
        SizedBox(width: 12),
        Text(
          "Series A",
          style: TextStyle(
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
      children: const [
        _MetricCard(title: "Capital aportado", value: "R\$ 280k"),
        _MetricCard(title: "Tokens totais", value: "10.000"),
        _MetricCard(title: "Valor do Token", value: "R\$ 28,00"),
        _MetricCard(
          title: "Valorização",
          value: "+12,4%",
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
          _progress("João Silva (CEO)", 0.45, "45%"),
          _progress("Maria Costa (CTO)", 0.30, "30%"),
          _progress("Lucas Mendes (COO)", 0.25, "25%"),
          const SizedBox(height: 20),
          const Text(
            "MENTORES E CONSELHEIROS",
            style: TextStyle(fontSize: 10, letterSpacing: 2, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          _person("Roberto Alencar", "Estrategista ESG"),
          const SizedBox(height: 12),
          _person("Sandra Rocha", "Ex-Diretora BNDES"),
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

  Widget _person(String name, String role) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF4FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD9E4FA)),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 23,
            backgroundImage: NetworkImage("https://i.imgur.com/BoN9kdC.png"),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
              ),
              Text(
                role,
                style: const TextStyle(fontSize: 12, color: Color(0xFF4B5563)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _docs() {
    return Wrap(
      spacing: 14,
      runSpacing: 14,
      children: [
        _doc("Sumário Executivo", Icons.description_outlined),
        _doc("Plano de Negócios", Icons.assignment_outlined),
        _doc("Vídeo Demo", Icons.play_circle_outline),
      ],
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

          Row(
            children: const [
              Expanded(
                child: Text(
                  "Perguntas da\nComunidade",
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          _inputField(),

          const SizedBox(height: 18),

          ...messages.map((msg) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _questionBubble(
                initials: msg["isUser"] ? "RC" : "◎",
                name: msg["name"],
                text: msg["message"],
                isAnswer: !msg["isUser"],
              ),
            );
          }).toList(),
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
          backgroundColor:
          isAnswer ? const Color(0xFF0D2CC8) : const Color(0xFFEBD5FF),
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
              border: isAnswer ? Border.all(color: const Color(0xFFCBD5E1)) : null,
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
      color: Colors.white,
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
            icon: const Icon(Icons.send, color: Color(0xFF0D2CC8)),
            onPressed: () {
              if (_controller.text.trim().isEmpty) return;

              setState(() {
                messages.add({
                  "name": "Você",
                  "message": _controller.text,
                  "isUser": true,
                });
              });

              _controller.clear();

              Future.delayed(const Duration(seconds: 1), () {
                setState(() {
                  messages.add({
                    "name": "Time EcoTech",
                    "message": "Obrigado pela pergunta! Em breve responderemos.",
                    "isUser": false,
                  });
                });
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _investButton() {
    return Container(
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
          Text(title, style: const TextStyle(fontSize: 11, color: Color(0xFF4B5563))),
          const SizedBox(height: 8),
          Row(
            children: [
              if (green) const Icon(Icons.trending_up, color: Colors.green, size: 16),
              if (green) const SizedBox(width: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: green ? Colors.green : Colors.black,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}