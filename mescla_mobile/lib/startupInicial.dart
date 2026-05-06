// Autor: Bruna Barbour Fernandes
// RA: 23007950

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

  String filtroSelecionado = "Todas";

  final List<Map<String, dynamic>> startups = [
    {
      "nome": "GreenfarmTech",
      "categoria": "Nova",
      "descricao":
      "Desenvolvimento de soluções tecnológicas para agricultura sustentável utilizando IA e IoT.",
      "valor": "R\$ 280.000",
      "token": "1.000.000",
      "valorizacao": "+12,4%",
    },

    {
      "nome": "TechHome Solutions",
      "categoria": "EM operação",
      "descricao":
      "Automação residencial inteligente focada em eficiência energética.",
      "valor": "R\$ 150.000",
      "token": "3.000.000",
      "valorizacao": "+4,2%",
    },

    {
      "nome": "UrbanLog",
      "categoria": "Expansão",
      "descricao":
      "Logística urbana inteligente com rastreamento em tempo real.",
      "valor": "R\$ 500.000",
      "token": "2.500.000",
      "valorizacao": "+18,1%",
    },

    {
      "nome": "EcoCharge",
      "categoria": "Nova",
      "descricao":
      "Infraestrutura para carregamento rápido de veículos elétricos.",
      "valor": "R\$ 320.000",
      "token": "850.000",
      "valorizacao": "+9,7%",
    },

    {
      "nome": "FinFlow",
      "categoria": "EM operação",
      "descricao":
      "Fintech focada em pagamentos digitais e tokenização financeira.",
      "valor": "R\$ 420.000",
      "token": "1.900.000",
      "valorizacao": "+15,3%",
    },

    {
      "nome": "AgroFuture",
      "categoria": "Expansão",
      "descricao":
      "Tecnologia agrícola inteligente para produtividade no campo.",
      "valor": "R\$ 600.000",
      "token": "3.400.000",
      "valorizacao": "+22,8%",
    },
  ];

  List<Map<String, dynamic>> messages = [
    {
      "name": "Ricardo Camargo",
      "message": "Como a EcoTech planeja mitigar o risco?",
      "isUser": true,
    },
    {
      "name": "Time EcoTech",
      "message": "Usamos contratos de longo prazo para estabilidade.",
      "isUser": false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final startupsFiltradas = filtroSelecionado == "Todas"
        ? startups
        : startups.where((startup) {
      return startup["categoria"] == filtroSelecionado;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "MesclaInvest",
          style: TextStyle(color: Colors.black),
        ),
      ),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: _filtros(),
          ),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                ...startupsFiltradas.map((startup) {
                  return _startupCard(startup);
                }).toList(),

                const SizedBox(height: 16),

                _messages(),

                const SizedBox(height: 90),
              ],
            ),
          ),

          _inputField(),
        ],
      ),

      bottomNavigationBar: _bottomBar(),
    );
  }

  Widget _filtros() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _filtroChip("Todas"),
          const SizedBox(width: 8),
          _filtroChip("Nova"),
          const SizedBox(width: 8),
          _filtroChip("EM operação"),
          const SizedBox(width: 8),
          _filtroChip("Expansão"),
        ],
      ),
    );
  }

  Widget _filtroChip(String filtro) {
    final ativo = filtroSelecionado == filtro;

    return GestureDetector(
      onTap: () {
        setState(() {
          filtroSelecionado = filtro;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: ativo ? const Color(0xFF0D2CC8) : Colors.white,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Text(
          filtro,
          style: TextStyle(
            color: ativo ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _startupCard(Map<String, dynamic> startup) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: const Color(0xFF0D2CC8).withOpacity(0.12),
                child: Text(
                  startup["nome"].toString()[0],
                  style: const TextStyle(
                    color: Color(0xFF0D2CC8),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      startup["nome"],
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 4),

                    _chip(
                      startup["categoria"],
                      isBlue: startup["categoria"] == "Nova",
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Text(
            startup["descricao"],
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black54,
            ),
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              _miniInfo("Capital", startup["valor"]),
              _miniInfo("Token", startup["token"]),
              _miniInfo(
                "Valorização",
                startup["valorizacao"],
                green: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _miniInfo(String title, String value, {bool green = false}) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 6),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFFF4F6FA),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 11,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: green ? Colors.green : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(String text, {bool isBlue = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isBlue ? Colors.blue.shade50 : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: isBlue ? Colors.blue : Colors.black87,
        ),
      ),
    );
  }

  Widget _messages() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text(
              "Perguntas da Comunidade",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              "Ver todas",
              style: TextStyle(color: Colors.blue),
            ),
          ],
        ),

        const SizedBox(height: 16),

        ...messages.map((msg) {
          return _chatBubble(
            name: msg["name"],
            message: msg["message"],
            isUser: msg["isUser"],
          );
        }).toList(),
      ],
    );
  }

  Widget _chatBubble({
    required String name,
    required String message,
    required bool isUser,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
        isUser ? MainAxisAlignment.start : MainAxisAlignment.end,
        children: [
          if (isUser) ...[
            const CircleAvatar(radius: 16, child: Text("RC")),
            const SizedBox(width: 8),
          ],

          Flexible(
            child: Column(
              crossAxisAlignment:
              isUser ? CrossAxisAlignment.start : CrossAxisAlignment.end,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),

                const SizedBox(height: 4),

                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isUser ? Colors.white : Colors.blue,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    message,
                    style: TextStyle(
                      color: isUser ? Colors.black : Colors.white,
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
          ),
        ],
      ),
    );
  }

  Widget _bottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0D2CC8),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        onPressed: () {},
        child: const Text("Quero Investir"),
      ),
    );
  }
}