// Autor: Alinne Monteiro de Melo
// RA: 24801649

import 'package:flutter/material.dart';
import 'package:cloud_functions/cloud_functions.dart';
import '../startups/catalogoStartUp.dart';

// usada tanto para confirmar o login quanto para ativar o MFA pela primeira vez
class MfaCodeScreen extends StatefulWidget {
  // isLogin define o comportamento da tela:
  // true  = usuário já tem MFA e está fazendo login
  // false = usuário está ativando o MFA pela primeira vez
  final bool isLogin;

  const MfaCodeScreen({super.key, required this.isLogin});

  @override
  State<MfaCodeScreen> createState() => _MfaCodeScreenState();
}

class _MfaCodeScreenState extends State<MfaCodeScreen> {
  // controller para capturar o código de 6 dígitos digitado pelo usuário
  final TextEditingController _codeController = TextEditingController();

  // controla a exibição do indicador de carregamento no botão
  bool _carregando = false;

  // ao abrir a tela, envia o código automaticamente sem precisar de ação do usuário
  @override
  void initState() {
    super.initState();
    _enviarCodigo();
  }

  // chama a Cloud Function do Firebase que envia o código por e-mail
  Future<void> _enviarCodigo() async {
    try {
      await FirebaseFunctions.instance
          .httpsCallable('sendMfaCodeByEmail')
          .call();
    } catch (e) {
      // exibe erro se o envio falhar, mas não bloqueia a tela
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

  // verifica o código digitado chamando a Cloud Function correspondente
  Future<void> _confirmarCodigo() async {
    final code = _codeController.text.trim();

    // valida se o código tem exatamente 6 dígitos antes de enviar
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
      // escolhe qual Cloud Function chamar dependendo do contexto da tela
      // verifyMfaLoginCode: verifica o código durante o login com MFA ativo
      // enableMfa: ativa o MFA pela primeira vez após verificar o código
      final functionName =
          widget.isLogin ? 'verifyMfaLoginCode' : 'enableMfa';

      await FirebaseFunctions.instance
          .httpsCallable(functionName)
          .call({'code': code});

      if (!mounted) return;

      // se o código for correto, vai para a tela principal do app
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const CatalogoStartUp()),
      );
    } on FirebaseFunctionsException catch (e) {
      // captura erros específicos do Firebase e exibe a mensagem retornada pela função
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message ?? 'Código inválido ou expirado.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      // desativa o carregamento independente de sucesso ou erro
      if (mounted) setState(() => _carregando = false);
    }
  }

  // libera o controller da memória quando a tela é destruída
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
            // cabeçalho com gradiente azul-roxo, ícone de cadeado e título
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
                  // botão de voltar alinhado à esquerda
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
                  // ícone de cadeado reforçando visualmente o tema de segurança
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

            // card branco com formulário sobreposto ao cabeçalho
            Transform.translate(
              offset: const Offset(0, -55), // sobe 55px para sobrepor ao gradiente
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
                      // título muda dependendo se é login ou ativação do MFA
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
                      // instrução também varia conforme o contexto da tela
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

                      // campo de entrada do código com estilo grande e espaçado
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F3FA),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: const Color(0xFFD8DCEB)),
                        ),
                        child: TextField(
                          controller: _codeController,
                          keyboardType: TextInputType.number,
                          maxLength: 6, // limita a entrada a exatamente 6 dígitos
                          textAlign: TextAlign.center,
                          // estilo com fonte grande e espaçamento entre os dígitos
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 12,
                            color: Color(0xFF0E1733),
                          ),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            counterText: '', // esconde o contador padrão do maxLength
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

                      // botão de confirmar com gradiente e sombra colorida
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
                            // desabilita o botão enquanto está carregando
                            onPressed: _carregando ? null : _confirmarCodigo,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(35),
                              ),
                            ),
                            // mostra spinner enquanto verifica ou o texto quando ocioso
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

                      // botão para reenviar o código caso o usuário não tenha recebido
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