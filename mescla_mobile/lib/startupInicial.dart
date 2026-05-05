import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: InvestPage(),
    );
  }
}

class InvestPage extends StatelessWidget {
  const InvestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const Icon(Icons.arrow_back, color: Colors.black),
        title: const Text("MesclaInvest", style: TextStyle(color: Colors.black)),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.favorite_border, color: Colors.black),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _header(),
            const SizedBox(height: 16),
            _metrics(),
            const SizedBox(height: 16),
            _chart(),
            const SizedBox(height: 16),
            _team(),
            const SizedBox(height: 16),
            _docs(),
            const SizedBox(height: 16),
            _messages(),
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomNavigationBar: _bottomBar(),
    );
  }

  Widget _header() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _chip("SUSTENTABILIDADE"),
            const SizedBox(width: 8),
            _chip("Em expansão", isBlue: true),
          ],
        ),
        const SizedBox(height: 10),
        const Text("EcoTech Solutions", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Row(
          children: const [
            Icon(Icons.eco, color: Colors.blue, size: 18),
            SizedBox(width: 6),
            Text("Series A", style: TextStyle(color: Colors.blue)),
          ],
        ),
        const SizedBox(height: 10),
        const Text(
          "Revolucionando a economia circular através de tecnologia proprietária de triagem automatizada e reciclagem química de alta eficiência.",
          style: TextStyle(color: Colors.black54),
        ),
      ],
    );
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
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(name), Text("${(value*100).toInt()}%")]),
      const SizedBox(height: 6),
      ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: LinearProgressIndicator(value: value, minHeight: 6),
      ),
      const SizedBox(height: 10),
    ]);
  }

  Widget _docs() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text("Documentação Pública"),
      const SizedBox(height: 10),
      Row(children: [
        _doc("Sumário Executivo"),
        _doc("Plano de Negócios"),
      ]),
      Row(children: [
        _doc("Vídeo Demo", icon: Icons.play_circle_outline),
      ])
    ]);
  }

  Widget _doc(String text, {IconData icon = Icons.description_outlined}) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(6),
        height: 90,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
        ),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, color: Colors.blue),
          const SizedBox(height: 6),
          Text(text, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12)),
        ]),
      ),
    );
  }

  Widget _messages() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: const [
        Text("Perguntas da Comunidade", style: TextStyle(fontWeight: FontWeight.bold)),
        Text("Ver todas", style: TextStyle(color: Colors.blue))
      ]),
      const SizedBox(height: 12),
      _userMessage(),
      const SizedBox(height: 8),
      _responseMessage(),
    ]);
  }

  Widget _userMessage() {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const CircleAvatar(radius: 14, child: Text("RC", style: TextStyle(fontSize: 10))),
      const SizedBox(width: 8),
      Expanded(
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
          child: const Text("Ricardo Camargo\nComo a EcoTech planeja mitigar o risco de flutuação no preço das commodities recicladas?"),
        ),
      )
    ]);
  }

  Widget _responseMessage() {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const CircleAvatar(radius: 14, backgroundColor: Colors.blue, child: Icon(Icons.business, size: 14, color: Colors.white)),
      const SizedBox(width: 8),
      Expanded(
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(12)),
          child: const Text("Time EcoTech (CEO)\nOlá Ricardo! Mantemos contratos de longo prazo (take-or-pay) com grandes indústrias que garantem estabilidade de margem independente do spot."),
        ),
      )
    ]);
  }

  Widget _bottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(color: Colors.white),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: const LinearGradient(colors: [Colors.blue, Colors.purple]),
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          onPressed: () {},
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Quero Investir"),
              SizedBox(width: 8),
              Icon(Icons.arrow_forward)
            ],
          ),
        ),
      ),
    );
  }
}
