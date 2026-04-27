import 'package:flutter/material.dart';

class StartupInicial extends StatelessWidget {
  const StartupInicial({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,

        // 🔙 BOTÃO VOLTAR FUNCIONANDO
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.blue),
          onPressed: () {
            Navigator.pop(context);
          },
        ),

        title: const Text("MesclaInvest",
            style: TextStyle(color: Colors.blue)),

        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.favorite, color: Colors.blue),
          )
        ],
      ),

      bottomNavigationBar: _bottomBar(),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Row(
              children: [
                const Text("SUSTENTABILIDADE",
                    style: TextStyle(color: Colors.blue, fontSize: 12)),
                const SizedBox(width: 10),
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text("Em expansão"),
                )
              ],
            ),

            const SizedBox(height: 10),

            const Text(
              "EcoTech Solutions",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            Row(
              children: const [
                Icon(Icons.eco, color: Colors.blue),
                SizedBox(width: 8),
                Text("Series A", style: TextStyle(color: Colors.blue)),
              ],
            ),

            const SizedBox(height: 15),

            const Text(
              "Revolucionando a economia circular através de tecnologia proprietária...",
              style: TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                _expandedInfo("Capital aportado", "R\$ 280k"),
                _expandedInfo("Tokens totais", "10.000"),
              ],
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                _expandedInfo("Valor do Token", "R\$ 28,00"),
                _expandedInfo("Valorização", "+12.4%"),
              ],
            ),

            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: _cardDecoration(),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _bar(40),
                  _bar(70),
                  _bar(55),
                  _bar(90),
                  _bar(120),
                ],
              ),
            ),

            const SizedBox(height: 20),

            _participation("João Silva (CEO)", 0.45),
            _participation("Maria Costa (CTO)", 0.30),

            const SizedBox(height: 80),
          ],
        ),
      ),

      floatingActionButtonLocation:
      FloatingActionButtonLocation.centerFloat,

      floatingActionButton: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        child: ElevatedButton(
          onPressed: () {},
          child: const Text("Quero Investir"),
        ),
      ),
    );
  }

  // 🔧 WIDGETS AUXILIARES

  Widget _expandedInfo(String title, String value) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.all(12),
        decoration: _cardDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 5),
            Text(value,
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _bar(double height) {
    return Container(
      width: 20,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        gradient: const LinearGradient(
          colors: [Colors.blue, Colors.purple],
        ),
      ),
    );
  }

  Widget _participation(String name, double value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(name),
          const SizedBox(height: 5),
          LinearProgressIndicator(value: value),
        ],
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
    );
  }

  Widget _bottomBar() {
    return BottomNavigationBar(
      selectedItemColor: Colors.blue,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.search), label: "Catálogo"),
        BottomNavigationBarItem(icon: Icon(Icons.account_balance), label: "Carteira"),
        BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: "Dashboard"),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: "Perfil"),
      ],
    );
  }
}