// Autor: Alinne Monteiro de Melo
// RA: 24801649

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mescla_mobile/widgets/carregarSaldo_modal.dart';


const kPrimary   = Color(0xFF0035B9);
const kSecondary = Color(0xFF7E41AD);
const kSurface   = Color(0xFFF8F9FF);
const kOnSurface = Color(0xFF0B1C30);
const kOutline   = Color(0xFF747686);

const kGradient = LinearGradient(
  colors: [kPrimary, kSecondary],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

// helpers

// converte centavos para string formatada: 1000000 → "R$ 10.000,00"
String formatarMoeda(int centavos) {
  final reais = centavos / 100;
  final partes = reais.toStringAsFixed(2).split('.');
  final inteiro = partes[0].replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
    (m) => '${m[1]}.',
  );
  return 'R\$ $inteiro,${partes[1]}';
}

// tela carteira
class CarteiraScreen extends StatefulWidget {
  const CarteiraScreen({super.key});

  @override
  State<CarteiraScreen> createState() => _CarteiraScreenState();
}

class _CarteiraScreenState extends State<CarteiraScreen> {
  int _navIndex = 2;

  // UID do usuário logado
  String get _uid => FirebaseAuth.instance.currentUser!.uid;

  // referência ao documento do usuário no Firestore
  DocumentReference get _userDoc =>
      FirebaseFirestore.instance.collection('users').doc(_uid);

  // referência à subcoleção de assets do usuário
  CollectionReference get _assetsCol => _userDoc.collection('assets');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kSurface,
      extendBody: true,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Card de saldo — escuta o documento do usuário em tempo real
            StreamBuilder<DocumentSnapshot>(
              stream: _userDoc.snapshots(),
              builder: (context, snapshot) {
                // Enquanto carrega
                if (!snapshot.hasData) {
                  return const _CardSkeleton();
                }

                final data = snapshot.data!.data() as Map<String, dynamic>?;
                final balanceCents = (data?['balanceCents'] as int?) ?? 0;

                return SaldoCard(
                  saldo: formatarMoeda(balanceCents),
                );
              },
            ),
            const SizedBox(height: 16),

            // botão carregar saldo
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => showCarregarSaldoModal(
                  context,
                  // Após confirmar, o StreamBuilder já atualiza o card
                  // automaticamente — só precisa salvar no Firebase
                  onConfirmar: (valorAdicionado) async {
                    final valorEmCentavos = (valorAdicionado * 100).toInt();
                    await _userDoc.update({
                      'balanceCents': FieldValue.increment(valorEmCentavos),
                    });
                  },
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: kPrimary,
                  side: const BorderSide(color: kPrimary, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text(
                  'Carregar Saldo',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),

            const SizedBox(height: 28),

            // seção Meus Tokens | escuta a subcoleção assets em tempo real
            StreamBuilder<QuerySnapshot>(
              stream: _assetsCol.snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const _ListSkeleton();
                }

                final docs = snapshot.data!.docs;

                return _StartupsSection(docs: docs);
              },
            ),

            const SizedBox(height: 28),

            // histórico de transações
            // (a fazer)
            const TransacoesSection(),
          ],
        ),
      ),
      bottomNavigationBar: _buildNavBar(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(64),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.85),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2)),
          ],
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

// card de saldo
class SaldoCard extends StatelessWidget {
  final String saldo;

  const SaldoCard({super.key, required this.saldo});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: kGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: kPrimary.withOpacity(0.3), blurRadius: 24, offset: const Offset(0, 8))],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Saldo disponível', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14, fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Text(
            saldo,
            style: const TextStyle(fontFamily: 'Manrope', color: Colors.white, fontSize: 36, fontWeight: FontWeight.w700, letterSpacing: -0.5),
          ),
        ],
      ),
    );
  }
}

// seção Meus Tokens
class _StartupsSection extends StatelessWidget {
  final List<QueryDocumentSnapshot> docs;

  const _StartupsSection({required this.docs});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Meus Tokens', style: TextStyle(fontFamily: 'Manrope', fontSize: 20, fontWeight: FontWeight.w700, color: kOnSurface)),
            if (docs.isNotEmpty)
              TextButton(onPressed: () {}, child: const Text('Ver tudo', style: TextStyle(color: kPrimary))),
          ],
        ),
        const SizedBox(height: 12),

        // vazio
        if (docs.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.7),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.4)),
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.rocket_launch_outlined, size: 40, color: kOutline.withOpacity(0.5)),
                  const SizedBox(height: 12),
                  const Text('Você ainda não tem tokens', style: TextStyle(fontWeight: FontWeight.w600, color: kOnSurface)),
                  const SizedBox(height: 4),
                  const Text(
                    'Explore o catálogo e faça seu primeiro investimento!',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: kOutline),
                  ),
                ],
              ),
            ),
          ),

        // lista de tokens do usuário
        for (final doc in docs) ...[
          _buildStartupCard(doc),
          const SizedBox(height: 12),
        ],
      ],
    );
  }

  Widget _buildStartupCard(QueryDocumentSnapshot doc) {
    final data            = doc.data() as Map<String, dynamic>;

    // Campos do UserAssetDocument
    final startupName     = data['startupName']       as String? ?? '—';
    final quantity        = data['quantity']           as int?    ?? 0;
    final avgPriceCents   = data['averagePriceCents']  as int?    ?? 0;
    final coverUrl        = data['coverImageUrl']      as String?;

    // valor total investido nessa startup
    final totalCents      = quantity * avgPriceCents;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.4)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 2))],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Logo da startup
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 6)],
              image: coverUrl != null
                  ? DecorationImage(image: NetworkImage(coverUrl), fit: BoxFit.cover)
                  : null,
            ),
            child: coverUrl == null
                ? const Icon(Icons.rocket_launch_rounded, color: kPrimary, size: 24)
                : null,
          ),
          const SizedBox(width: 12),

          // nome e quantidade
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(startupName, style: const TextStyle(fontFamily: 'Manrope', fontSize: 15, fontWeight: FontWeight.w600, color: kOnSurface)),
                Text('$quantity tokens', style: const TextStyle(fontSize: 12, color: kOutline)),
              ],
            ),
          ),

          // valor total
          Text(
            formatarMoeda(totalCents),
            style: const TextStyle(fontFamily: 'Manrope', fontSize: 15, fontWeight: FontWeight.w600, color: kOnSurface),
          ),
        ],
      ),
    );
  }
}

// histórico de transações
class TransacoesSection extends StatelessWidget {
  const TransacoesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Histórico de transações', style: TextStyle(fontFamily: 'Manrope', fontSize: 20, fontWeight: FontWeight.w700, color: kOnSurface)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.7),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.4)),
          ),
          child: Center(
            child: Column(
              children: [
                Icon(Icons.receipt_long_outlined, size: 40, color: kOutline.withOpacity(0.5)),
                const SizedBox(height: 12),
                const Text('Nenhuma transação ainda', style: TextStyle(fontWeight: FontWeight.w600, color: kOnSurface)),
                const SizedBox(height: 4),
                const Text(
                  'Suas compras e vendas de tokens aparecerão aqui.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: kOutline),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// skeletons de carregamento
class _CardSkeleton extends StatelessWidget {
  const _CardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        gradient: kGradient,
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Center(child: CircularProgressIndicator(color: Colors.white)),
    );
  }
}

class _ListSkeleton extends StatelessWidget {
  const _ListSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator(color: kPrimary));
  }
}