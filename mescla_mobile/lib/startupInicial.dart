import 'package:flutter/material.dart';

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
      "message": "Como a EcoTech planeja mitigar o risco?",
      "isUser": true
    },
    {
      "name": "Time EcoTech",
      "message": "Usamos contratos de longo prazo para estabilidade.",
      "isUser": false
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("MesclaInvest", style: TextStyle(color: Colors.black)),
      ),

      body: Column(
        children: [

          /// 🔽 CHAT (lista rolável)
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                return _chatBubble(
                  name: msg["name"],
                  message: msg["message"],
                  isUser: msg["isUser"],
                );
              },
            ),
          ),

          /// 🔽 INPUT
          _inputField(),
        ],
      ),
    );
  }

  /// 💬 BOLHA
  Widget _chatBubble({
    required String name,
    required String message,
    required bool isUser,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
        isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Flexible(
            child: Column(
              crossAxisAlignment:
              isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isUser ? Colors.blue : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    message,
                    style: TextStyle(
                      color: isUser ? Colors.white : Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 🧠 INPUT + ENVIO
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
            icon: const Icon(Icons.send, color: Colors.blue),
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

              /// resposta fake automática
              Future.delayed(const Duration(seconds: 1), () {
                setState(() {
                  messages.add({
                    "name": "EcoTech",
                    "message": "Obrigado pela pergunta! Em breve responderemos.",
                    "isUser": false,
                  });
                });
              });
            },
          )
        ],
      ),
    );
  }
}

  Widget _chip(String text, {bool isBlue = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isBlue ? Colors.blue.shade50 : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(text, style: TextStyle(fontSize: 12, color: isBlue ? Colors.blue : Colors.black87)),
    );
  }

  Widget _metrics() {
    return Column(
      children: [
        Row(children: [_card("Capital aportado", "R\$ 280k"), _card("Tokens totais", "10.000")]),
        Row(children: [_card("Valor do Token", "R\$ 28,00"), _card("Valorização", "+12.4%", green: true)]),
      ],
    );
  }

  Widget _card(String title, String value, {bool green = false}) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(6),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 12, color: Colors.black54)),
            const SizedBox(height: 6),
            Row(
              children: [
                if (green) const Icon(Icons.trending_up, color: Colors.green, size: 16),
                if (green) const SizedBox(width: 4),
                Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: green ? Colors.green : Colors.black)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _chart() {
    final heights = [40.0, 70.0, 60.0, 110.0, 140.0, 170.0];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text("Histórico de Valorização", style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        const Text("Desempenho acumulado do token no período", style: TextStyle(fontSize: 12, color: Colors.black54)),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: List.generate(6, (i) {
            return Column(
              children: [
                Container(
                  width: 28,
                  height: heights[i],
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [Colors.blue.shade200, Colors.blue.shade700]),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                const SizedBox(height: 6),
                Text(["Jan","Fev","Mar","Abr","Mai","Jun"][i], style: const TextStyle(fontSize: 10)),
              ],
            );
          }),
        )
      ]),
    );
  }

  Widget _team() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text("Equipe e Governança", style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        _progress("João Silva (CEO)", 0.45),
        _progress("Maria Costa (CTO)", 0.30),
        _progress("Lucas Mendes (COO)", 0.25),
      ]),
    );
  }

  Widget _progress(String name, double value) {
    return Column(children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(name), Text("${(value * 100).toInt()}%")]),
      const SizedBox(height: 6),
      ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: LinearProgressIndicator(value: value, minHeight: 6),
      ),
      const SizedBox(height: 10),
    ]);
  }

  Widget _docs() {
    return Column(children: [
      const Text("Documentação Pública"),
      const SizedBox(height: 10),
      Row(children: [_doc("Sumário Executivo"), _doc("Plano de Negócios")]),
      Row(children: [_doc("Vídeo Demo", icon: Icons.play_circle_outline)]),
    ]);
  }

  Widget _doc(String text, {IconData icon = Icons.description_outlined}) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(6),
        height: 90,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, color: Colors.blue),
          const SizedBox(height: 6),
          Text(text, textAlign: TextAlign.center),
        ]),
      ),
    );
  }

  // 🔥 NOVA PARTE DE MENSAGENS

  Widget _messages() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text("Perguntas da Comunidade", style: TextStyle(fontWeight: FontWeight.bold)),
            Text("Ver todas", style: TextStyle(color: Colors.blue)),
          ],
        ),
        const SizedBox(height: 16),

        _chatBubble(
          name: "Ricardo Camargo",
          message: "Como a EcoTech planeja mitigar o risco de flutuação no preço das commodities recicladas?",
          isUser: true,
        ),

        const SizedBox(height: 12),

        _chatBubble(
          name: "Time EcoTech (CEO)",
          message: "Olá Ricardo! Mantemos contratos de longo prazo...",
          isUser: false,
        ),
      ],
    );
  }

  Widget _chatBubble({
    required String name,
    required String message,
    required bool isUser,
  }) {
    return Row(
      mainAxisAlignment: isUser ? MainAxisAlignment.start : MainAxisAlignment.end,
      children: [
        if (isUser) ...[
          const CircleAvatar(radius: 16, child: Text("RC")),
          const SizedBox(width: 8),
        ],
        Flexible(
          child: Column(
            crossAxisAlignment: isUser ? CrossAxisAlignment.start : CrossAxisAlignment.end,
            children: [
              Text(name, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isUser ? Colors.white : Colors.blue,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(message, style: TextStyle(color: isUser ? Colors.black : Colors.white)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _bottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: ElevatedButton(
        onPressed: () {},
        child: const Text("Quero Investir"),
      ),
    );
  }
}