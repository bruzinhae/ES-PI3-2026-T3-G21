// Autor: Alinne Monteiro de Melo 
// RA: 24801649

import 'package:flutter/material.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'register_screen.dart';
import 'recuperar_senha.dart';
import '../auth/mfa_codeScreen.dart';
import '../../services/auth_service.dart';
import '../startups/catalogoStartUp.dart';
import 'package:mescla_mobile/utils/formatters.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}


class _LoginScreenState extends State<LoginScreen> {
  // controladores para capturar o texto digitado em cada campo
  final TextEditingController emailController = TextEditingController();
  final TextEditingController senhaController = TextEditingController();

  // controla se a senha está visível ou oculta
  bool obscurePassword = true;

  // controla a exibição do indicador de carregamento no botão
  bool carregando = false;

  // formatador de CPF para aplicar a máscara 000.000.000-00
  final _cpfFormatter = CpfInputFormatter();

  // indica se o usuário está digitando CPF em vez de e-mail
  bool _usandoCpf = false;

  // exibe uma mensagem de erro vermelha na parte inferior da tela
  void mostrarErro(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: Colors.red,
      ),
    );
  }

  // valida os campos antes de tentar fazer o login
  bool validarLogin() {
    final emailOuCpf = emailController.text.trim();
    final senha = senhaController.text.trim();

    // verifica se os campos estão vazios
    if (emailOuCpf.isEmpty || senha.isEmpty) {
      mostrarErro("Preencha e-mail/CPF e senha.");
      return false;
    }

    // verifica se a senha tem no mínimo 6 caracteres
    if (senha.length < 6) {
      mostrarErro("A senha deve ter no mínimo 6 caracteres.");
      return false;
    }

    return true;
  }

  // navega para a tela principal do app substituindo a pilha de navegação
  void _irParaHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const CatalogoStartUp()),
    );
  }

  // exibe um popup perguntando se o usuário quer ativar a verificação em duas etapas
  Future<void> mostrarPopup2FA() async {
    await showDialog(
      context: context,
      barrierDismissible: false, // impede fechar o popup clicando fora dele
      builder: (_) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: const Text("Ativar verificação em duas etapas?"),
          content: const Text(
            "Essa segurança extra protege sua conta com um código enviado por e-mail.",
          ),
          actions: [
            // opção de pular a ativação do MFA e ir direto para o home
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _irParaHome();
              },
              child: const Text("Agora não"),
            ),
            // opção de ativar o MFA agora, levando para a tela de código
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    // isLogin: false indica que é ativação, não verificação de login
                    builder: (_) => const MfaCodeScreen(isLogin: false),
                  ),
                );
              },
              child: const Text("Ativar agora"),
            ),
          ],
        );
      },
    );
  }

  // função principal que executa o fluxo de login
  Future<void> fazerLogin() async {
    // interrompe se a validação dos campos falhar
    if (!validarLogin()) return;

    // ativa o indicador de carregamento
    setState(() => carregando = true);

    try {
      // chama o serviço de autenticação com e-mail/CPF e senha
      final userData = await AuthService.login(
        email: emailController.text.trim(),
        password: senhaController.text.trim(),
      );

      if (!mounted) return;

      if (userData['mfaEnabled'] == true) {
        // se o usuário já tem MFA ativo, envia o código por e-mail e redireciona para verificação
        await FirebaseFunctions.instance
            .httpsCallable('sendMfaCodeByEmail')
            .call();

        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            // isLogin: true indica que é uma verificação de login com MFA já ativo
            builder: (_) => const MfaCodeScreen(isLogin: true),
          ),
        );
      } else {
        // se o usuário não tem MFA, pergunta se quer ativar
        await mostrarPopup2FA();
      }
    } catch (e) {
      mostrarErro("Erro ao entrar. Verifique seus dados.");
    } finally {
      // desativa o carregamento independente de sucesso ou erro
      if (mounted) setState(() => carregando = false);
    }
  }

  // libera os controladores da memória quando a tela é destruída
  @override
  void dispose() {
    emailController.dispose();
    senhaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // cabeçalho com gradiente azul-roxo contendo logo e título
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
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      // botão de voltar posicionado à esquerda do cabeçalho
                      Align(
                        alignment: Alignment.centerLeft,
                        child: CircleAvatar(
                          backgroundColor: Colors.white24,
                          child: IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      // logo centralizado usando Stack para sobrepor ao botão de voltar
                      Image.asset(
                        'assets/images/logoMescla.png',
                        height: 110,
                        fit: BoxFit.contain,
                      ),
                    ],
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
                    'Login',
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

            // card branco com o formulário, sobreposto ao cabeçalho usando Transform
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
                      const Text(
                        'Bem-vindo de volta',
                        style: TextStyle(
                          fontSize: 27,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0E1733),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Acesse sua carteira e acompanhe seus rendimentos.',
                        style: TextStyle(
                          fontSize: 16,
                          height: 1.45,
                          color: Color(0xFF3B4257),
                        ),
                      ),
                      const SizedBox(height: 25),

                      const Text(
                        'E-mail ou CPF',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2F354A),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // campo de e-mail ou CPF com detecção automática do tipo de entrada
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F3FA),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: const Color(0xFFD8DCEB)),
                        ),
                        child: TextField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress, // tipo de teclado que será aberto 
                          // aplica o formatador de CPF somente quando o campo detectar números
                          inputFormatters: _usandoCpf ? [_cpfFormatter] : [],
                          onChanged: (value) {
                            // detecta se o conteúdo é apenas numérico (CPF) ou texto (e-mail)
                            final eNumerico = value.trim().isNotEmpty &&
                                value.trim().replaceAll(RegExp(r'[\d.\-]'), '').isEmpty;
                            setState(() {
                              _usandoCpf = eNumerico;
                            });
                          },
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 22),
                            prefixIcon: Icon(
                              Icons.person_rounded,
                              color: Color(0xFFB5B9C9),
                            ),
                            hintText: 'Insira seus dados',
                            hintStyle: TextStyle(
                              color: Color(0xFF8E93A8),
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      const Text(
                        'Senha',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2F354A),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // campo de senha com botão para alternar visibilidade
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F3FA),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: const Color(0xFFD8DCEB)),
                        ),
                        child: TextField(
                          controller: senhaController,
                          // obscureText oculta os caracteres quando true
                          obscureText: obscurePassword,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 22),
                            prefixIcon: const Icon(
                              Icons.lock_rounded,
                              color: Color(0xFFB5B9C9),
                            ),
                            hintText: '••••••••',
                            hintStyle: const TextStyle(
                              color: Color(0xFF8E93A8),
                              fontSize: 16,
                            ),
                            // ícone de olho para mostrar ou esconder a senha
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  obscurePassword = !obscurePassword;
                                });
                              },
                              icon: Icon(
                                obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: const Color(0xFFB5B9C9),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),

                      // link para a tela de recuperação de senha alinhado à direita
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const RecuperarSenhaScreen(),
                              ),
                            );
                          },
                          child: const Text(
                            'Esqueceu a senha?',
                            style: TextStyle(
                              color: Color(0xFF133BCE),
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 1),

                      // botão de entrar com gradiente e sombra colorida
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
                            onPressed: carregando ? null : fazerLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(35),
                              ),
                            ),
                            // mostra spinner enquanto carrega ou o texto/ícone quando ocioso
                            child: carregando
                                ? const CircularProgressIndicator(
                                    color: Colors.white)
                                : const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Entrar',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      SizedBox(width: 12),
                                      Icon(
                                        Icons.arrow_forward_rounded,
                                        color: Colors.white,
                                        size: 30,
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // rodapé com link para a tela de cadastro
            Transform.translate(
              offset: const Offset(0, -20),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Não tem uma conta ainda? ',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF2F354A),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const CadastroScreen(),
                              ),
                            );
                          },
                          child: const Text(
                            'Cadastre-se',
                            style: TextStyle(
                              color: Color(0xFF133BCE),
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}