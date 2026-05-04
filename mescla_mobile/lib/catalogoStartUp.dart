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

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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

              _startupCard(
                context,
                title: "GreenfarmTech",
                category: "AGRICULTURA",
                tag: "NOVA",
                tagColor: const Color(0xFFDDE5F7),
                description:
                "Desenvolvimento de soluções tecnológicas para otimizar a produção agrícola sustentável utilizando IA e IoT.",
                value: "R\$ 280.000",
                tokens: "1000000",
                growth: "+12,4%",
              ),

              _startupCard(
                context,
                title: "TechHome Solutions",
                category: "TECNOLOGIA",
                tag: "EM OPERAÇÃO",
                tagColor: const Color(0xFFE5E8F5),
                description:
                "Plataforma que utiliza automação residencial para tornar a casa mais inteligente e eficiente energeticamente.",
                value: "R\$ 150.000",
                tokens: "3000000",
                growth: "+4,2%",
              ),

              _startupCard(context,
                title: "HealthTrack",
                category: "SAÚDE",
                tag: "EM EXPANSÃO",
                tagColor: const Color(0xFFDFF3E4),
                description:
                "Tecnologia para monitoramento de condições de saúde em tempo real e prevenção personalizada.",
                value: "5000000",
                tokens: "18.200",
                growth: "+22,8%",
              ),

              _startupCard(context,
                title: "SmartRetail",
                category: "VAREJO INTELIGENTE",
                tag: "EM OPERAÇÃO",
                tagColor: const Color(0xFFDFF3E4),
                description:
                "Plataforma de análise de dados para otimização do varejo, utilizando IA para prever tendências de consumo.",
                value: "2000000",
                tokens: "18.200",
                growth: "+22,8%",
              ),

              _startupCard(context,
                title: "FinPrime",
                category: "FINANÇAS",
                tag: "EM EXPANSÃO",
                tagColor: const Color(0xFFDFF3E4),
                description:
                "Plataforma de investimentos em pequenas e médias empresas com foco em inovação financeira.",
                value: "1500000",
                tokens: "18.200",
                growth: "+22,8%",
              ),

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
    return Row(
      children: [
        _chip("Todas", true),
        _chip("Nova", false),
        _chip("Em operação", false),
        _chip("Expansão", false),
      ],
    );
  }

  Widget _chip(String text, bool selected) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          gradient: selected
              ? const LinearGradient(
            colors: [Color(0xFF3D5AFE), Color(0xFF7B1FA2)],
          )
              : null,
          color: selected ? null : Colors.white,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: selected ? Colors.white : Colors.black54,
          ),
        ),
      ),
    );
  }

  Widget _startupCard(
      BuildContext context, {
        required String title,
        required String category,
        required String tag,
        required Color tagColor,
        required String description,
        required String value,
        required String tokens,
        required String growth,
      }) {
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
                    colors: [Color(0xFF3D5AFE), Color(0xFF7B1FA2)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.eco, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    Text(category,
                        style: const TextStyle(
                            fontSize: 12,
                            letterSpacing: 1.2,
                            color: Colors.blue)),
                  ],
                ),
              ),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: tagColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(tag, style: const TextStyle(fontSize: 12)),
              )
            ],
          ),
          const SizedBox(height: 12),
          Text(description,
              style: const TextStyle(color: Colors.black54, height: 1.4)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _info("Aportado", value),
              _info("Tokens", tokens),
              _info("Valorização", growth, color: Colors.purple),
            ],
          ),
          const SizedBox(height: 16),

          // 🔥 BOTÃO BRANCO + NAVEGAÇÃO
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
          )
        ],
      ),
    );
  }

  Widget _info(String title, String value, {Color? color}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(fontSize: 12, color: Colors.black45)),
        const SizedBox(height: 4),
        Text(value,
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color ?? Colors.black)),
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
            icon: Icon(Icons.account_balance_wallet), label: "Carteira"),
        BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: "Dashboard"),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: "Perfil"),
      ],
    );
  }
}