// Autor: Alinne Monteiro de Melo
// RA: 24801649

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mescla_mobile/pages/balc%C3%A3o/service/balcao_service.dart';
import 'package:mescla_mobile/pages/balcão/balcaoHelpers.dart';

/// seção de criação de oferta (formulário com abas comprar / vender)
class TradeSection extends StatelessWidget {
  final List<StartupItem>        startups;
  final StartupItem?             selectedStartup;
  final bool                     carregandoStartups;
  final bool                     offerTabComprar;
  final bool                     processando;
  final TextEditingController    quantityController;
  final TextEditingController    priceController;
  final int                      precoReferenciaCents;
  final int                      totalCents;
  final ValueChanged<StartupItem> onStartupChanged;
  final ValueChanged<bool>        onTabChanged;
  final VoidCallback              onCriarOferta;

  const TradeSection({
    super.key,
    required this.startups,
    required this.selectedStartup,
    required this.carregandoStartups,
    required this.offerTabComprar,
    required this.processando,
    required this.quantityController,
    required this.priceController,
    required this.precoReferenciaCents,
    required this.totalCents,
    required this.onStartupChanged,
    required this.onTabChanged,
    required this.onCriarOferta,
  });

  // helpers locais

  int get _precoOfertaCents {
    final raw = priceController.text.replaceAll(',', '.');
    final reais = double.tryParse(raw) ?? 0.0;
    return (reais * 100).round();
  }

  bool get _habilitado =>
      !processando &&
      (int.tryParse(quantityController.text) ?? 0) > 0 &&
      _precoOfertaCents > 0;

  // build

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
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
          // Título + abas
          Row(
            children: [
              Container(
                width: 4, height: 18,
                decoration: BoxDecoration(
                    color: const Color(0xFF1A56DB),
                    borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(width: 8),
              const Text('Criar oferta',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF111827))),
              const Spacer(),
              _TabChip(
                  label: 'Comprar',
                  isActive: offerTabComprar,
                  onTap: () => onTabChanged(true)),
              const SizedBox(width: 6),
              _TabChip(
                  label: 'Vender',
                  isActive: !offerTabComprar,
                  onTap: () => onTabChanged(false)),
            ],
          ),
          const SizedBox(height: 16),

          // Dropdown de startups
          _label('Selecionar startup'),
          const SizedBox(height: 6),
          carregandoStartups
              ? const Center(child: CircularProgressIndicator())
              : _StartupDropdown(
                  startups:        startups,
                  selectedStartup: selectedStartup,
                  onChanged:       onStartupChanged,
                ),
          const SizedBox(height: 14),

          // quantidade + Preço
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _label('Quantidade'),
                    const SizedBox(height: 6),
                    _QuantityField(controller: quantityController),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _label('Preço por token (R\$)'),
                    const SizedBox(height: 6),
                    _PriceField(controller: priceController),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // hint de preço de referência
          if (precoReferenciaCents > 0)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded,
                      size: 13, color: Colors.grey[400]),
                  const SizedBox(width: 4),
                  Text(
                    'Preço atual de referência: '
                    '${TradingPageHelpers.formatCurrency(precoReferenciaCents)}',
                    style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                  ),
                ],
              ),
            ),

          // Total
          _TotalRow(totalCents: totalCents),
          const SizedBox(height: 16),

          // Botão
          _ConfirmButton(
            habilitado:     _habilitado,
            processando:    processando,
            isComprar:      offerTabComprar,
            onTap:          onCriarOferta,
          ),
        ],
      ),
    );
  }

  Widget _label(String text) => Text(
        text,
        style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF6B7280),
            letterSpacing: 0.2),
      );
}

// sub-widgets privados 

class _TabChip extends StatelessWidget {
  final String   label;
  final bool     isActive;
  final VoidCallback onTap;

  const _TabChip({
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
              ? const Color(0xFF1A56DB)
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

class _StartupDropdown extends StatelessWidget {
  final List<StartupItem>         startups;
  final StartupItem?              selectedStartup;
  final ValueChanged<StartupItem> onChanged;

  const _StartupDropdown({
    required this.startups,
    required this.selectedStartup,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (startups.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: const Text('Nenhuma startup disponível',
            style: TextStyle(color: Colors.grey)),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<StartupItem>(
          value: selectedStartup,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down,
              color: Color(0xFF1A56DB)),
          style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF111827)),
          items: startups
              .map((s) => DropdownMenuItem(value: s, child: Text(s.name)))
              .toList(),
          onChanged: (val) {
            if (val != null) onChanged(val);
          },
        ),
      ),
    );
  }
}

class _QuantityField extends StatelessWidget {
  final TextEditingController controller;
  const _QuantityField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF111827)),
        decoration: InputDecoration(
          hintText: '0',
          hintStyle: TextStyle(color: Colors.grey[400]),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          border: InputBorder.none,
          suffixText: 'tkn',
          suffixStyle: TextStyle(
              fontSize: 12,
              color: Colors.grey[500],
              fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}

class _PriceField extends StatelessWidget {
  final TextEditingController controller;
  const _PriceField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: TextField(
        controller: controller,
        keyboardType:
            const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'^\d*[,.]?\d{0,2}')),
        ],
        style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF111827)),
        decoration: InputDecoration(
          hintText: '0,00',
          hintStyle: TextStyle(color: Colors.grey[400]),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          border: InputBorder.none,
          prefixText: 'R\$ ',
          prefixStyle: TextStyle(
              fontSize: 12,
              color: Colors.grey[500],
              fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}

class _TotalRow extends StatelessWidget {
  final int totalCents;
  const _TotalRow({required this.totalCents});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F4FF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Total da oferta',
              style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500)),
          Text(
            TradingPageHelpers.formatCurrency(totalCents),
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1A56DB)),
          ),
        ],
      ),
    );
  }
}

class _ConfirmButton extends StatelessWidget {
  final bool         habilitado;
  final bool         processando;
  final bool         isComprar;
  final VoidCallback onTap;

  const _ConfirmButton({
    required this.habilitado,
    required this.processando,
    required this.isComprar,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: habilitado ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          gradient: habilitado
              ? const LinearGradient(
                  colors: [
                    Color(0xFF0D2CC8),
                    Color(0xFF1A56DB),
                    Color(0xFF2563EB)
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                )
              : null,
          color: habilitado ? null : const Color(0xFFE5E7EB),
          borderRadius: BorderRadius.circular(16),
          boxShadow: habilitado
              ? [
                  BoxShadow(
                      color: const Color(0xFF1A56DB).withOpacity(0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 8))
                ]
              : [],
        ),
        child: processando
            ? const Center(
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2.5),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isComprar
                        ? Icons.add_shopping_cart_rounded
                        : Icons.sell_rounded,
                    color:
                        habilitado ? Colors.white : Colors.grey[400],
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isComprar
                        ? 'Publicar oferta de compra'
                        : 'Publicar oferta de venda',
                    style: TextStyle(
                      color: habilitado ? Colors.white : Colors.grey[400],
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}