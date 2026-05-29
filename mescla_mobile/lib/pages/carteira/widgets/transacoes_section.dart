// Autor: Alinne Monteiro de Melo
// RA: 24801649

import 'package:flutter/material.dart';
import 'package:mescla_mobile/pages/carteira/wallet_service.dart';
import 'package:mescla_mobile/utils/app_colors.dart';
import 'package:mescla_mobile/utils/formatters.dart';

class TransacoesSection extends StatefulWidget {
  const TransacoesSection({super.key});

  @override
  State<TransacoesSection> createState() => _TransacoesSectionState();
}

class _TransacoesSectionState extends State<TransacoesSection> {
  late Future<List<Map<String, dynamic>>> _future;

  @override
  void initState() {
    super.initState();
    _future = WalletService.listarTransacoes();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Histórico de transações',
          style: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: kOnSurface,
          ),
        ),
        const SizedBox(height: 12),
        FutureBuilder<List<Map<String, dynamic>>>(
          future: _future,
          builder: (context, snapshot) {
            // Carregando
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            // Erro
            if (snapshot.hasError) {
              return _buildEmpty(
                icon: Icons.error_outline,
                title: 'Não foi possível carregar',
                subtitle: 'Tente novamente mais tarde.',
                showRetry: true,
              );
            }

            final transactions = snapshot.data ?? [];

            // Lista vazia
            if (transactions.isEmpty) {
              return _buildEmpty(
                icon: Icons.receipt_long_outlined,
                title: 'Nenhuma transação ainda',
                subtitle: 'Suas compras e vendas de tokens aparecerão aqui.',
              );
            }

            // Lista preenchida
            return Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.7),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.4)),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: transactions.length,
                separatorBuilder: (_, __) => Divider(
                  height: 1,
                  color: kOutline.withOpacity(0.15),
                  indent: 16,
                  endIndent: 16,
                ),
                itemBuilder: (context, index) {
                  return _TransacaoTile(data: transactions[index]);
                },
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildEmpty({
    required IconData icon,
    required String title,
    required String subtitle,
    bool showRetry = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.4)),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(icon, size: 40, color: kOutline.withOpacity(0.5)),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w600, color: kOnSurface),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: kOutline),
            ),
            if (showRetry) ...[
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => setState(() {
                  _future = WalletService.listarTransacoes();
                }),
                child: const Text('Tentar novamente'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TransacaoTile extends StatelessWidget {
  final Map<String, dynamic> data;

  const _TransacaoTile({required this.data});

  @override
  Widget build(BuildContext context) {
    final isBuy = (data['type'] as String?) == 'buy';
    final startupName = (data['startupName'] as String?) ?? 'Startup';
    final quantity = (data['quantity'] as num?)?.toInt() ?? 0;
    final totalCents = (data['totalCents'] as num?)?.toInt() ?? 0;
    final createdAt = data['createdAt'] as String?;

    final label = isBuy ? 'Compra' : 'Venda';
    final color = isBuy ? const Color(0xFF16A34A) : const Color(0xFFDC2626);
    final icon = isBuy ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded;
    final sinal = isBuy ? '-' : '+';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          // Ícone de tipo
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),

          // Nome e detalhes
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  startupName,
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: kOnSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$label · $quantity token${quantity != 1 ? 's' : ''}',
                  style: const TextStyle(fontSize: 12, color: kOutline),
                ),
              ],
            ),
          ),

          // Valor e data
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$sinal ${formatarMoeda(totalCents)}',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: color,
                ),
              ),
              const SizedBox(height: 2),
              if (createdAt != null)
                Text(
                  _formatDate(createdAt),
                  style: const TextStyle(fontSize: 11, color: kOutline),
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      final day = dt.day.toString().padLeft(2, '0');
      final month = dt.month.toString().padLeft(2, '0');
      final hour = dt.hour.toString().padLeft(2, '0');
      final min = dt.minute.toString().padLeft(2, '0');
      return '$day/$month · $hour:$min';
    } catch (_) {
      return '';
    }
  }
}