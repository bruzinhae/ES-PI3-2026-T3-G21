// Autor: Alinne Monteiro de Melo 
// RA: 24801649

import 'package:flutter/material.dart';
import 'login_screen.dart';
import '../../widgets/app_button.dart';
import '../../utils/validators.dart';
import '../../services/auth_service.dart';


class RecuperarSenhaScreen extends StatefulWidget {
  const RecuperarSenhaScreen({super.key});
  
  @override
  State<RecuperarSenhaScreen> createState() => _RecuperarSenhaScreenState();
}

class _RecuperarSenhaScreenState extends State<RecuperarSenhaScreen> {
  // controller para capturar o e-mail digitado pelo usuário
  final emailController = TextEditingController();

  // controla a exibição do indicador de carregamento no botão
  bool carregando = false;

  // libera o controller da memória quando a tela é destruída
  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  // valida o e-mail e solicita o envio do link de recuperação
  Future<void> enviarRecuperacao() async {
    final email = emailController.text.trim();

    // verifica se o campo está vazio
    if (email.isEmpty) {
      mostrarErro("Digite seu e-mail.");
      return;
    }

    // verifica se o formato do e-mail é válido usando a função de validators.dart
    if (!validarEmail(email)) {
      mostrarErro("Digite um e-mail válido.");
      return;
    }

    setState(() {
      carregando = true;
    });

    try {
      // chama o serviço que envia o e-mail de redefinição via Firebase
      await AuthService.requestPasswordResetEmail(email: email);

      if (!mounted) return;

      // exibe confirmação de que o e-mail foi enviado com sucesso
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("E-mail de redefinição enviado com sucesso."),
        ),
      );

      // redireciona para o login após o envio
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        ),
      );
    } catch (e) {
      mostrarErro("Erro ao enviar e-mail de redefinição.");
    } finally {
      // desativa o carregamento independente de sucesso ou erro
      if (mounted) {
        setState(() {
          carregando = false;
        });
      }
    }
  }

  // exibe uma mensagem de erro vermelha na parte inferior da tela
  void mostrarErro(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FF),

      // appBar com gradiente azul-roxo no lugar da cor sólida padrão
      appBar: AppBar(
        elevation: 0,
        foregroundColor: Colors.white,
        title: const Text(
          "Recuperar Senha",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        // flexibleSpace permite aplicar gradiente no fundo da AppBar
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF0035B9),
                Color(0xFF7E41AD),
              ],
            ),
          ),
        ),
      ),

      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(22),
          child: Container(
            width: 500,
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Esqueceu sua senha?",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0E1733),
                  ),
                ),

                const SizedBox(height: 12),

                // instrução explicando o que acontece ao enviar o formulário
                const Text(
                  "Insira seu e-mail cadastrado. Enviaremos um link para redefinição de senha.",
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.5,
                    color: Colors.black54,
                  ),
                ),

                const SizedBox(height: 28),

                const Text(
                  "E-mail",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.black54,
                  ),
                ),

                const SizedBox(height: 10),

                // campo de e-mail com fundo preenchido e borda removida
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    hintText: "nome@exemplo.com",
                    filled: true,
                    fillColor: const Color(0xFFF7F8FD),
                    prefixIcon: const Icon(Icons.person),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                // botão reutilizável que mostra spinner quando loading é true
                AppButton(
                  text: "Enviar link de Redefinição",
                  loading: carregando,
                  onPressed: enviarRecuperacao,
                ),

                const SizedBox(height: 25),

                // divisor visual separando o botão principal do link de voltar
                const Divider(),

                const SizedBox(height: 10),

                // link para voltar ao login sem enviar o formulário
                Center(
                  child: TextButton.icon(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const LoginScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.login),
                    label: const Text(
                      "Voltar para o Login",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),

      // rodapé fixo na parte inferior da tela
      bottomNavigationBar: const Padding(
        padding: EdgeInsets.all(18),
        child: Text(
          "© 2026 MesclaInvest. Todos os direitos reservados.",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            color: Colors.black45,
          ),
        ),
      ),
    );
  }
}