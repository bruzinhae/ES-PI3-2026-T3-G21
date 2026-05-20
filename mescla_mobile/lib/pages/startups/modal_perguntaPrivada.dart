// Autor: Alinne Monteiro de Melo
// RA: 24801649

import 'package:flutter/material.dart';
import 'package:cloud_functions/cloud_functions.dart';
import '../startups/services/startup_service.dart';

Future<void> abrirModalPerguntaPrivada(
  BuildContext context, {
  required String startupId,
  required String startupName,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _ModalPerguntaPrivada(
      startupId: startupId,
      startupName: startupName,
    ),
  );
}

class _ModalPerguntaPrivada extends StatefulWidget {
  final String startupId;
  final String startupName;

  const _ModalPerguntaPrivada({
    required this.startupId,
    required this.startupName,
  });

  @override
  State<_ModalPerguntaPrivada> createState() => _ModalPerguntaPrivadaState();
}

class _ModalPerguntaPrivadaState extends State<_ModalPerguntaPrivada> {
  final TextEditingController _controller = TextEditingController();
  bool enviando = false;
  bool enviado = false;
  String? erro;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _enviar() async {
    final texto = _controller.text.trim();
    if (texto.isEmpty) return;

    setState(() {
      enviando = true;
      erro = null;
    });

    try {
      await StartupService.createStartupQuestion(
        startupId: widget.startupId,
        message: texto,
        visibility: 'privada', // 👈 privada
      );

      setState(() => enviado = true);
    } on FirebaseFunctionsException catch (e) {
      setState(() => erro = e.message ?? 'Erro ao enviar.');
    } catch (e) {
      setState(() => erro = 'Erro inesperado.');
    } finally {
      setState(() => enviando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(24, 28, 24, 28 + bottom),
      decoration: const BoxDecoration(
        color: Color(0xFF0B1328),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: enviado ? _sucessoView() : _formView(),
    );
  }

  Widget _formView() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.lock_outline, color: Color(0xFFFFD233), size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Pergunta Privada — ${widget.startupName}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Icon(Icons.close, color: Color(0xFF94A3B8)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          'Sua pergunta é visível apenas para a equipe da startup.',
          style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
        ),
        const SizedBox(height: 22),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1F2937),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF374151)),
          ),
          child: TextField(
            controller: _controller,
            maxLines: 4,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: const InputDecoration(
              hintText: 'Escreva sua pergunta...',
              hintStyle: TextStyle(color: Color(0xFF64748B)),
              border: InputBorder.none,
            ),
          ),
        ),
        if (erro != null) ...[
          const SizedBox(height: 12),
          Text(erro!, style: const TextStyle(color: Colors.red, fontSize: 13)),
        ],
        const SizedBox(height: 20),
        GestureDetector(
          onTap: enviando ? null : _enviar,
          child: Container(
            width: double.infinity,
            height: 52,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0D2CC8), Color(0xFF8D35E6)],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: enviando
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Enviar pergunta',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _sucessoView() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.check_circle_outline, color: Color(0xFF34D399), size: 52),
        const SizedBox(height: 16),
        const Text(
          'Pergunta enviada!',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'A equipe da startup responderá em breve.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
        ),
        const SizedBox(height: 24),
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: double.infinity,
            height: 52,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFF4B5563)),
            ),
            child: const Center(
              child: Text(
                'Fechar',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ),
      ],
    );
  }
}