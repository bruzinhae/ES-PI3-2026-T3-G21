// Autor: Bruna Barbour Fernandes
// RA: 23007950

import 'package:flutter/material.dart';
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
  String filtroSelecionado = "Todas";

  final List<Map<String, dynamic>> startups = [
    {
      "title": "GreenfarmTech",
      "category": "AGRICULTURA",
      "tag": "Nova",
      "tagColor": Color(0xFFDDE5F7),
      "description":
      "Desenvolvimento de soluções tecnológicas para otimizar a produção agrícola sustentável utilizando IA e IoT.",
      "value": "R\$ 280.000",
      "tokens": "1000000",
      "growth": "+12,4%",
      "icon": Icons.eco,
    },
    {
      "title": "TechHome Solutions",
      "category": "TECNOLOGIA",
      "tag": "Em operação",
      "tagColor": Color(0xFFE5E8F5),
      "description":
      "Plataforma que utiliza automação residencial para tornar a casa mais inteligente e eficiente energeticamente.",
      "value": "R\$ 150.000",
      "tokens": "3000000",
      "growth": "+4,2%",
      "icon": Icons.home,
    },
    {
      "title": "HealthTrack",
      "category": "SAÚDE",
      "tag": "Expansão",
      "tagColor": Color(0xFFDFF3E4),
      "description":
      "Tecnologia para monitoramento de condições de saúde em tempo real e prevenção personalizada.",
      "value": "R\$ 5.000.000",
      "tokens": "18.200",
      "growth": "+22,8%",
      "icon": Icons.health_and_safety,
    },
    {
      "title": "SmartRetail",
      "category": "VAREJO INTELIGENTE",
      "tag": "Em operação",
      "tagColor": Color(0xFFDFF3E4),
      "description":
      "Plataforma de análise de dados para otimização do varejo, utilizando IA para prever tendências de consumo.",
      "value": "R\$ 2.000.000",
      "tokens": "18.200",
      "growth": "+22,8%",
      "icon": Icons.store,
    },
    {
      "title": "FinPrime",
      "category": "FINANÇAS",
      "tag": "Expansão",
      "tagColor": Color(0xFFDFF3E4),
      "description":
      "Plataforma de investimentos em pequenas e médias empresas com foco em inovação financeira.",
      "value": "R\$ 1.500.000",
      "tokens": "18.200",
      "growth": "+22,8%",
      "icon": Icons.attach_money,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final startupsFiltradas = filtroSelecionado == "Todas"
        ? startups
        : startups.where((startup) {
      return startup["tag"] == filtroSelecionado;
    }).toList();

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

              ...startupsFiltradas.map((startup) {
                return _startupCard(context, startup);
              }).toList(),

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _bottomNav(),
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
      child: const TextField(
        decoration: InputDecoration(
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
                  startup["icon"],
                  color: Colors.white,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      startup["title"],
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      startup["category"],
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
                  color: startup["tagColor"],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  startup["tag"],
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Text(
            startup["description"],
            style: const TextStyle(
              color: Colors.black54,
              height: 1.4,
            ),
          ),

          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _info("Aportado", startup["value"]),
              _info("Tokens", startup["tokens"]),
              _info(
                "Valorização",
                startup["growth"],
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
                    builder: (context) => const StartupInicial(),
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

  Widget _bottomNav() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFF3D5AFE),
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "Início"),
        BottomNavigationBarItem(icon: Icon(Icons.grid_view), label: "Catálogo"),
        BottomNavigationBarItem(
          icon: Icon(Icons.account_balance_wallet),
          label: "Carteira",
        ),
        BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: "Dashboard"),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: "Perfil"),
      ],
    );
  }
}