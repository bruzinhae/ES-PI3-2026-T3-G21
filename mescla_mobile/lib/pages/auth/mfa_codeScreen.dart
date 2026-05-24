import 'package:flutter/material.dart';
import 'package:cloud_functions/cloud_functions.dart';
import '../startups/catalogoStartUp.dart';

class MfaCodeScreen extends StatefulWidget {
  final bool isLogin; 

  const MfaCodeScreen({super.key, required this.isLogin});

  @override
  State<MfaCodeScreen> createState() => _MfaCodeScreenState();
}

class _MfaCodeScreenState extends State<MfaCodeScreen> {
  final TextEditingController _codeController = TextEditingController();
  bool _carregando = false;

  @override
  void initState() {
    super.initState();
    _enviarCodigo(); // envia o código automaticamente ao abrir a tela
  }

  Future<void> _enviarCodigo() async {
    try {
      await FirebaseFunctions.instance
          .httpsCallable('sendMfaCodeByEmail')
          .call();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao enviar código. Tente novamente.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _confirmarCodigo() async {
    final code = _codeController.text.trim();

    if (code.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Digite o código de 6 dígitos.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _carregando = true);

    try {
      // verifyMfaLoginCode → login com MFA já ativo
      // enableMfa → ativando MFA pela primeira vez
      final functionName =
          widget.isLogin ? 'verifyMfaLoginCode' : 'enableMfa';

      await FirebaseFunctions.instance
          .httpsCallable(functionName)
          .call({'code': code});

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const CatalogoStartUp()),
      );
    } on FirebaseFunctionsException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message ?? 'Código inválido ou expirado.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header com gradiente igual ao login
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 48, 24, 90),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF1F46D8),
                    Color(0xFF7B3FCB),
                  ],
                ),
              ),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: CircleAvatar(
                      backgroundColor: Colors.white24,
                      child: IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Icon(
                    Icons.lock_outline_rounded,
                    color: Colors.white,
                    size: 60,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'MesclaInvest',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 34,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Verificação em duas etapas',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),

            // Card com o formulário
            Transform.translate(
              offset: const Offset(0, -55),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(22, 28, 22, 28),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(34),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.isLogin
                            ? 'Confirme sua identidade'
                            : 'Ativar verificação em duas etapas',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0E1733),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.isLogin
                            ? 'Enviamos um código de 6 dígitos para o seu e-mail. Digite abaixo para continuar.'
                            : 'Enviamos um código de 6 dígitos para o seu e-mail. Digite abaixo para ativar a verificação.',
                        style: const TextStyle(
                          fontSize: 15,
                          height: 1.45,
                          color: Color(0xFF3B4257),
                        ),
                      ),
                      const SizedBox(height: 28),
                      const Text(
                        'Código de verificação',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2F354A),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F3FA),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: const Color(0xFFD8DCEB)),
                        ),
                        child: TextField(
                          controller: _codeController,
                          keyboardType: TextInputType.number,
                          maxLength: 6,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 12,
                            color: Color(0xFF0E1733),
                          ),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            counterText: '',
                            contentPadding: EdgeInsets.symmetric(vertical: 22),
                            hintText: '______',
                            hintStyle: TextStyle(
                              color: Color(0xFFB5B9C9),
                              fontSize: 28,
                              letterSpacing: 12,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 70,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(35),
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF173FD2),
                                Color(0xFF7A42C5),
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF5A4CCB)
                                    .withValues(alpha: 0.35),
                                blurRadius: 16,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: _carregando ? null : _confirmarCodigo,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(35),
                              ),
                            ),
                            child: _carregando
                                ? const CircularProgressIndicator(
                                    color: Colors.white)
                                : const Text(
                                    'Confirmar',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Center(
                        child: TextButton(
                          onPressed: _enviarCodigo,
                          child: const Text(
                            'Reenviar código',
                            style: TextStyle(
                              color: Color(0xFF133BCE),
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}