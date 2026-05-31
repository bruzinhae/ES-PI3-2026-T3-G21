// Autor: Alinne Monteiro de Melo
// RA: 24801649

import 'package:flutter/material.dart';
import 'package:mescla_mobile/pages/balc%C3%A3o/service/balcao_service.dart';
import 'package:mescla_mobile/pages/balcão/balcaoHelpers.dart';

/// livro de ofertas com abas independentes "Para comprar / Para vender"
class OrderBook extends StatelessWidget {
  final List<StartupOffer>         ofertas;
  final bool                       carregandoOfertas;
  final bool                       livroTabComprar;
  final bool                       processando;
  final ValueChanged<bool>         onTabChanged;
  final ValueChanged<StartupOffer> onAceitarOferta;

  const OrderBook({
    super.key,
    required this.ofertas,
    required this.carregandoOfertas,
    required this.livroTabComprar,
    required this.processando,
    required this.onTabChanged,
    required this.onAceitarOferta,
  });

  List<StartupOffer> get _ofertasFiltradas => ofertas.where((o) {
        if (livroTabComprar) return o.isSell;
        return o.isBuy;
      }).toList();

  @override
  Widget build(BuildContext context) {
    final filtradas = _ofertasFiltradas;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cabeçalho
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 4, height: 18,
                    decoration: BoxDecoration(
                        color: const Color(0xFF10B981),
                        borderRadius: BorderRadius.circular(2)),
                  ),
                  const SizedBox(width: 8),
                  const Text('Livro de ofertas',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF111827))),
                ],
              ),
              Row(
                children: [
                  _LivroTabChip(
                      label: 'Para comprar',
                      isActive: livroTabComprar,
                      onTap: () => onTabChanged(true)),
                  const SizedBox(width: 6),
                  _LivroTabChip(
                      label: 'Para vender',
                      isActive: !livroTabComprar,
                      onTap: () => onTabChanged(false)),
                ],
              ),
            ],
          ),

          // subtítulo contextual
          Padding(
            padding: const EdgeInsets.only(top: 6, bottom: 14),
            child: Text(
              livroTabComprar
                  ? 'Ofertas de venda — aceite para comprar tokens'
                  : 'Ofertas de compra — aceite para vender tokens',
              style: TextStyle(fontSize: 11, color: Colors.grey[500]),
            ),
          ),

          // conteúdo
          if (carregandoOfertas)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: CircularProgressIndicator(),
              ),
            )
          else if (filtradas.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Column(
                  children: [
                    Icon(Icons.list_alt_rounded,
                        size: 40, color: Colors.grey[300]),
                    const SizedBox(height: 12),
                    Text('Nenhuma oferta disponível',
                        style: TextStyle(
                            fontSize: 13, color: Colors.grey[500])),
                    const SizedBox(height: 4),
                    Text('Seja o primeiro a criar uma!',
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey[400])),
                  ],
                ),
              ),
            )
          else ...[
            // header da tabela
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(8)),
              child: const Row(
                children: [
                  Expanded(
                      flex: 2,
                      child: Text('Qtd.',
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF6B7280)))),
                  Expanded(
                      flex: 2,
                      child: Text('Preço/token',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF6B7280)))),
                  Expanded(
                      flex: 2,
                      child: Text('Total',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF6B7280)))),
                  SizedBox(width: 76),
                ],
              ),
            ),
            const SizedBox(height: 4),

            for (final oferta in filtradas)
              _OfferRow(
                oferta:     oferta,
                processando: processando,
                onAceitar:  () => onAceitarOferta(oferta),
              ),
          ],

          const SizedBox(height: 4),
        ],
      ),
    );
  }
}

// sub-widgets privados

class _LivroTabChip extends StatelessWidget {
  final String     label;
  final bool       isActive;
  final VoidCallback onTap;

  const _LivroTabChip({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isActive
              ? const Color(0xFF10B981)
              : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isActive ? Colors.white : Colors.grey[600])),
      ),
    );
  }
}

class _OfferRow extends StatelessWidget {
  final StartupOffer oferta;
  final bool         processando;
  final VoidCallback onAceitar;

  const _OfferRow({
    required this.oferta,
    required this.processando,
    required this.onAceitar,
  });

  @override
  Widget build(BuildContext context) {
    final isOwn = oferta.isOwn;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      decoration: BoxDecoration(
        color: isOwn ? const Color(0xFFFFFBEB) : null,
        border:
            Border(bottom: BorderSide(color: Colors.grey[100]!, width: 1)),
      ),
      child: Row(
        children: [
          // Quantidade + badge "minha"
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Text('${oferta.quantity}',
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF111827))),
                if (isOwn) ...[
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(4)),
                    child: const Text('minha',
                        style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF92400E))),
                  ),
                ],
              ],
            ),
          ),

          // Preço
          Expanded(
            flex: 2,
            child: Text(
              TradingPageHelpers.formatCurrency(oferta.priceCents),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: oferta.isSell
                    ? const Color(0xFF059669)
                    : const Color(0xFFDC2626),
              ),
            ),
          ),

          // Total
          Expanded(
            flex: 2,
            child: Text(
              TradingPageHelpers.formatCurrency(oferta.totalCents),
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111827)),
            ),
          ),

          // botão aceitar / label "sua oferta"
          SizedBox(
            width: 76,
            child: isOwn
                ? Center(
                    child: Text('sua oferta',
                        style: TextStyle(
                            fontSize: 9,
                            color: Colors.grey[400],
                            fontWeight: FontWeight.w500)),
                  )
                : GestureDetector(
                    onTap: processando ? null : onAceitar,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: oferta.isSell
                            ? const Color(0xFF059669)
                            : const Color(0xFFDC2626),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        oferta.isSell ? 'Comprar' : 'Vender',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}