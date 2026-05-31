// Autor: Alinne Monteiro de Melo
// RA: 24801649

import 'package:flutter/material.dart';

// onConfirmar recebe o valor total e atualiza o saldo na tela pai
void showCarregarSaldoModal(BuildContext context, {required Function(double) onConfirmar}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => CarregarSaldoModal(onConfirmar: onConfirmar),
  );
}

class CarregarSaldoModal extends StatefulWidget {
  final Function(double) onConfirmar;

  const CarregarSaldoModal({super.key, required this.onConfirmar});

  @override
  State<CarregarSaldoModal> createState() => _CarregarSaldoModalState();
}

class _CarregarSaldoModalState extends State<CarregarSaldoModal> {
  final List<double> _valoresPredefinidos = [500, 1000, 2000, 5000];
  final Map<double, int> _selecionados = {};
  bool _carregando = false;

  double get _totalSelecionado {
    double total = 0;
    _selecionados.forEach((valor, qtd) => total += valor * qtd);
    return total;
  }

  void _adicionar(double valor) {
    setState(() => _selecionados[valor] = (_selecionados[valor] ?? 0) + 1);
  }

  void _remover(double valor) {
    setState(() {
      if ((_selecionados[valor] ?? 0) > 1) {
        _selecionados[valor] = _selecionados[valor]! - 1;
      } else {
        _selecionados.remove(valor);
      }
    });
  }

  void _limpar() => setState(() => _selecionados.clear());

  String _formatarMoeda(double valor) {
    return 'R\$ ${valor.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]}.',
        )}';
  }

  Future<void> _confirmarCarregamento() async {
    if (_totalSelecionado == 0) return;
    setState(() => _carregando = true);


    await Future.delayed(const Duration(seconds: 1));

    setState(() => _carregando = false);

    if (mounted) {
      final total = _totalSelecionado;

      // avisa a tela pai pra atualizar o saldo
      widget.onConfirmar(total);

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF0035B9),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 10),
              Text(
                '${_formatarMoeda(total)} adicionados (simulado)!',
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 24, right: 24, top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Carregar Saldo', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0B1C30))),
              if (_selecionados.isNotEmpty)
                TextButton(onPressed: _limpar, child: const Text('Limpar', style: TextStyle(color: Colors.redAccent))),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3CD),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFFFD700)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.science_outlined, size: 14, color: Color(0xFF856404)),
                SizedBox(width: 4),
                Text('Ambiente simulado — sem dinheiro real', style: TextStyle(fontSize: 12, color: Color(0xFF856404))),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text('Toque para adicionar valores', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF555555))),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 2.5,
            physics: const NeverScrollableScrollPhysics(),
            children: _valoresPredefinidos.map((valor) {
              final qtd = _selecionados[valor] ?? 0;
              final selecionado = qtd > 0;
              return GestureDetector(
                onTap: () => _adicionar(valor),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: selecionado ? const Color(0xFF0035B9) : const Color(0xFFF4F6FF),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: selecionado ? const Color(0xFF0035B9) : const Color(0xFFDDE1FF),
                      width: 1.5,
                    ),
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: Text(
                          '+ ${_formatarMoeda(valor)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: selecionado ? Colors.white : const Color(0xFF0035B9),
                          ),
                        ),
                      ),
                      if (selecionado)
                        Positioned(
                          top: 6, right: 6,
                          child: GestureDetector(
                            onTap: () => _remover(valor),
                            child: Container(
                              width: 22, height: 22,
                              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                              child: Center(
                                child: Text('$qtd', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0035B9))),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: _totalSelecionado > 0 ? 56 : 0,
            child: _totalSelecionado > 0
                ? Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(color: const Color(0xFFF4F6FF), borderRadius: BorderRadius.circular(14)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total a adicionar', style: TextStyle(color: Color(0xFF555555))),
                        Text(_formatarMoeda(_totalSelecionado), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF0035B9))),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: (_totalSelecionado == 0 || _carregando) ? null : _confirmarCarregamento,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0035B9),
                disabledBackgroundColor: Colors.grey[300],
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: _carregando
                  ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                  : const Text('Confirmar (Simulado)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}