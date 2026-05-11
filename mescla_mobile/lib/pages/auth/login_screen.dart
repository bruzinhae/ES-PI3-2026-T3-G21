// Autor: Alinne Monteiro de Melo 
// RA: 24801649


import 'package:flutter/material.dart';
import 'register_screen.dart';
import 'recuperar_senha.dart';
import '../../services/auth_service.dart';
import '../../catalogoStartUp.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController senhaController = TextEditingController();
  bool obscurePassword = true;

  bool carregando = false;

  void mostrarErro(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: Colors.red,
      ),
    );
  }

  bool validarLogin() {
    final emailOuCpf = emailController.text.trim();
    final senha = senhaController.text.trim();

    if (emailOuCpf.isEmpty || senha.isEmpty) {
      mostrarErro("Preencha e-mail/CPF e senha.");
      return false;
    }

    if (senha.length < 6) {
      mostrarErro("A senha deve ter no mínimo 6 caracteres.");
      return false;
    }

    return true;
  }

  void mostrarPopup2FA() {
    showDialog(
      context: context,
      barrierDismissible: false,
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
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                // depois vai para tela principal
              },
              child: const Text("Agora não"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                // depois chama o back e vai para tela de código
              },
              child: const Text("Ativar agora"),
            ),
          ],
        );
      },
    );
  }

  Future<void> fazerLogin() async {
    if (!validarLogin()) return;

    setState(() {
      carregando = true;
    });

    try {
      await AuthService.login(
        email: emailController.text.trim(),
        password: senhaController.text.trim(),
      );
      mostrarPopup2FA();

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const CatalogoStartUp(),
      ),
    );

    } catch (e) {
      mostrarErro("Erro ao entrar. Verifique seus dados.");
    } finally {
      if (mounted) {
        setState(() {
          carregando = false;
        });
      }
    }
  }

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
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F3FA),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: const Color(0xFFD8DCEB),
                          ),
                        ),
                        child: TextField(
                          controller: emailController,
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
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F3FA),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: const Color(0xFFD8DCEB),
                          ),
                        ),
                        child: TextField(
                          controller: senhaController,
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
                                color: const Color(0xFF5A4CCB).withValues(alpha: 0.35),
                                blurRadius: 16,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: carregando ? null : fazerLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(35),
                              ),
                            ),
                            child: carregando
                              ? const CircularProgressIndicator(color: Colors.white)
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
            Transform.translate(
              offset: const Offset(0, -20),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  children: [
                  
                    const SizedBox(height: 0),
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