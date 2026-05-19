// Autor: Bruna Barbour Fernandes
// RA: 23007950

import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';

import '../startups/services/startup_service.dart';

/// Abre o bottom sheet de investimento.
/// Chame assim na tela:
///
/// ```dart
/// abrirModalInvestimento(context, startup: s, startupId: widget.startupId);
/// ```
void abrirModalInvestimento(
  BuildContext context, {
  required StartupDetails startup,
  required String startupId,
  VoidCallback? onSucesso, // opcional: recarregar dados da tela pai
}) {
  final tokenPriceReais = startup.currentTokenPriceCents / 100;

  final tokenController = TextEditingController();
  final valorController = TextEditingController();
  bool atualizando = false;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setModalState) {
          bool comprando = false;

          void onTokenChanged(String value) {
            if (atualizando) return;
            atualizando = true;
            final qtd = double.tryParse(value.replaceAll(',', '.')) ?? 0;
            valorController.text =
                qtd > 0 ? (qtd * tokenPriceReais).toStringAsFixed(2) : '';
            atualizando = false;
          }

          void onValorChanged(String value) {
            if (atualizando) return;
            atualizando = true;
            final reais = double.tryParse(value.replaceAll(',', '.')) ?? 0;
            tokenController.text =
                reais > 0 && tokenPriceReais > 0
                    ? (reais / tokenPriceReais).toStringAsFixed(0)
                    : '';
            atualizando = false;
          }

          Future<void> confirmar() async {
            final qtd = int.tryParse(
                  tokenController.text.trim().split('.').first,
                ) ??
                0;

            if (qtd <= 0) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Informe a quantidade de tokens.'),
                ),
              );
              return;
            }

            setModalState(() => comprando = true);

            try {
              final resultado = await StartupService.buyTokens(
                startupId: startupId,
                quantity: qtd,
              );

              final novoSaldoCents =
                  resultado['balanceCents'] as int? ?? 0;
              final novoSaldo =
                  StartupDetails.formatarReais(novoSaldoCents);

              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '$qtd tokens comprados! Saldo restante: $novoSaldo',
                    ),
                    backgroundColor: const Color(0xFF0D2CC8),
                  ),
                );
                onSucesso?.call();
              }
            } on FirebaseFunctionsException catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(e.message ?? 'Erro ao comprar tokens.'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
              debugPrint('${e.code}: ${e.message}');
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Erro inesperado ao comprar tokens.'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
              debugPrint('Erro inesperado: $e');
            } finally {
              setModalState(() => comprando = false);
            }
          }

          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFEFF4FF),
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(28)),
              ),
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFCBD5E1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Título
                  Text(
                    'Investir em ${startup.name}',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Preço atual: ${startup.tokenPriceFormatado} / token',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF4B5563),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Campo: tokens
                  const Text(
                    'Quantidade de tokens',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF374151),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _InputModal(
                    controller: tokenController,
                    hint: '0',
                    sufixo: 'tokens',
                    onChanged: onTokenChanged,
                  ),
                  const SizedBox(height: 16),

                  // Campo: reais
                  const Text(
                    'Valor em reais',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF374151),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _InputModal(
                    controller: valorController,
                    hint: 'R\$ 0,00',
                    prefixo: 'R\$',
                    onChanged: onValorChanged,
                  ),
                  const SizedBox(height: 32),

                  // Botão confirmar
                  GestureDetector(
                    onTap: comprando ? null : confirmar,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: double.infinity,
                      height: 54,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        gradient: LinearGradient(
                          colors: comprando
                              ? [Colors.grey, Colors.grey]
                              : [
                                  const Color(0xFF0D2CC8),
                                  const Color(0xFF8D35E6),
                                ],
                        ),
                      ),
                      child: Center(
                        child: comprando
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Confirmar Investimento',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                ),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

// ─── Widget auxiliar de input ──────────────────────────────────────────────

class _InputModal extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final Function(String) onChanged;
  final String? prefixo;
  final String? sufixo;

  const _InputModal({
    required this.controller,
    required this.hint,
    required this.onChanged,
    this.prefixo,
    this.sufixo,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFCBD5E1)),
      ),
      child: Row(
        children: [
          if (prefixo != null) ...[
            Text(prefixo!,
                style: const TextStyle(color: Color(0xFF4B5563))),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                hintText: hint,
                border: InputBorder.none,
              ),
              onChanged: onChanged,
            ),
          ),
          if (sufixo != null) ...[
            const SizedBox(width: 8),
            Text(sufixo!,
                style: const TextStyle(color: Color(0xFF4B5563))),
          ],
        ],
      ),
    );
  }
}