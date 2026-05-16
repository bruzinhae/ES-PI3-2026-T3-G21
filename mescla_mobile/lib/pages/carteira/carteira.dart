// Autor: Alinne Monteiro de Melo
// RA: 24801649

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mescla_mobile/utils/formatters.dart';
import 'package:mescla_mobile/widgets/carregarSaldo_modal.dart';
import 'package:mescla_mobile/pages/carteira/wallet_service.dart';
import 'package:mescla_mobile/pages/carteira/widgets/saldo_card.dart';
import 'package:mescla_mobile/pages/carteira/widgets/startups_section.dart';
import 'package:mescla_mobile/pages/carteira/widgets/transacoes_section.dart';
import 'package:mescla_mobile/utils/app_colors.dart';
import '../../widgets/bottom_navBar.dart';


class CarteiraScreen extends StatefulWidget {
  const CarteiraScreen({super.key});

  @override
  State<CarteiraScreen> createState() => _CarteiraScreenState();
}

class _CarteiraScreenState extends State<CarteiraScreen> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const BottomNavBar(
        selectedIndex: 2,
      ),
      backgroundColor: kSurface,
      extendBody: true,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card de saldo — stream em tempo real
            StreamBuilder<DocumentSnapshot>(
              stream: WalletService.saldoStream(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const _CardSkeleton();
                final data         = snapshot.data!.data() as Map<String, dynamic>?;
                final balanceCents = (data?['balanceCents'] as int?) ?? 0;
                return SaldoCard(saldo: formatarMoeda(balanceCents));
              },
            ),
            const SizedBox(height: 16),

            // Botão carregar saldo
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => showCarregarSaldoModal(
                  context,
                  onConfirmar: (valorAdicionado) async {
                    try {
                      print('depositando: $valorAdicionado');
                      await WalletService.depositar(valorAdicionado);
                      print('depósito ok!');
                    } catch (e) {
                      print('ERRO: $e');
                    }
                  },
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: kPrimary,
                  side: const BorderSide(color: kPrimary, width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('Carregar Saldo', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),

            const SizedBox(height: 28),

            // Meus Tokens — stream em tempo real
            StreamBuilder<QuerySnapshot>(
              stream: WalletService.assetsStream(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const _ListSkeleton();
                return StartupsSection(docs: snapshot.data!.docs);
              },
            ),

            const SizedBox(height: 28),

            // Histórico de transações
            const TransacoesSection(),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(64),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.85),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              children: [
                const SizedBox(width: 12),
                const Text(
                  'Carteira',
                  style: TextStyle(fontFamily: 'Manrope', fontSize: 22, fontWeight: FontWeight.w700, color: Color(0xFF1E3A8A)),
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }

}

// Skeletons de carregamento
class _CardSkeleton extends StatelessWidget {
  const _CardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      decoration: BoxDecoration(gradient: kGradient, borderRadius: BorderRadius.circular(24)),
      child: const Center(child: CircularProgressIndicator(color: Colors.white)),
    );
  }
}

class _ListSkeleton extends StatelessWidget {
  const _ListSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}