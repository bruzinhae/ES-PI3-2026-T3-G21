// Autor: Alinne Monteiro de Melo 
// RA: 24801649

import 'package:flutter/material.dart';
import 'login_screen.dart';
import '../../services/auth_service.dart';
import 'package:mescla_mobile/utils/validators.dart';
import '../../widgets/app_button.dart';

class CadastroScreen extends StatefulWidget {
  const CadastroScreen({super.key});

  @override
  State<CadastroScreen> createState() => _CadastroScreenState();
}

class _CadastroScreenState extends State<CadastroScreen> {
  final nomeController = TextEditingController();
  final cpfController = TextEditingController();
  final emailController = TextEditingController();
  final telefoneController = TextEditingController();
  final senhaController = TextEditingController();
  final confirmarSenhaController = TextEditingController();

  bool carregando = false;

  @override
  void dispose() {
    nomeController.dispose();
    cpfController.dispose();
    emailController.dispose();
    telefoneController.dispose();
    senhaController.dispose();
    confirmarSenhaController.dispose();
    super.dispose();
  }

  bool validarCampos() {
    if (nomeController.text.trim().isEmpty ||
        cpfController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty ||
        telefoneController.text.trim().isEmpty ||
        senhaController.text.trim().isEmpty ||
        confirmarSenhaController.text.trim().isEmpty) {
      mostrarErro("Preencha todos os campos obrigatórios.");
      return false;
    }

    if (!validarEmail(emailController.text)) {
      mostrarErro("Email inválido.");
      return false;
    }

    if (senhaController.text.length < 6) {
      mostrarErro("A senha deve ter no mínimo 6 caracteres.");
      return false;
    }

    if (senhaController.text != confirmarSenhaController.text) {
      mostrarErro("As senhas não conferem.");
      return false;
    }

    if (!validarCPF(cpfController.text)) {
      mostrarErro("CPF inválido.");
      return false;
    }

    return true;
  }

  Future<void> cadastrarUsuario() async {
    if (!validarCampos()) return;

    setState(() {
      carregando = true;
    });

    try {
      await AuthService.createUser(
        name: nomeController.text.trim(),
        email: emailController.text.trim(),
        password: senhaController.text.trim(),
        cpf: cpfController.text.trim(),
        telefone: telefoneController.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Conta criada com sucesso! Verifique seu e-mail."),
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        ),
      );
    } catch (e) {
      mostrarErro("Erro ao criar conta. Verifique os dados e tente novamente.");
    } finally {
      if (mounted) {
        setState(() {
          carregando = false;
        });
      }
    }
  }

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
      backgroundColor: const Color(0xFFF8F9FF),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 35),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(40),
                ),
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF0035B9),
                    Color(0xFF5A1A89),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.white24,
                        child: IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                        ),
                      ),
                      const Expanded(
                        child: Center(
                          child: Text(
                            "MesclaInvest",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 40),
                    ],
                  ),
                  const SizedBox(height: 25),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Criar conta",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Comece sua jornada rumo à liberdade financeira hoje mesmo.",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(18),
                child: Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      campo("Nome completo", Icons.person, "Como quer ser chamado?", nomeController),
                      campo("CPF", Icons.badge, "000.000.000-00", cpfController),
                      campo("E-mail", Icons.email, "seuemail@exemplo.com", emailController),
                      campo("Telefone", Icons.phone, "(00) 00000-0000", telefoneController),
                      campo(
                        "Senha",
                        Icons.lock,
                        "••••••••",
                        senhaController,
                        obscure: true,
                        mostrarAvisoSenha: true,
                      ),
                      campo(
                        "Confirme sua senha",
                        Icons.lock_reset,
                        "••••••••",
                        confirmarSenhaController,
                        obscure: true,
                      ),

                      const SizedBox(height: 20),

                      AppButton(
                        text: "Criar conta",
                        loading: carregando,
                        onPressed: cadastrarUsuario,
                      ),

                      const SizedBox(height: 14),

                      const Text(
                        "Ao se cadastrar, você concorda com nossos Termos e Condições.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 13,
                        ),
                      ),

                      const SizedBox(height: 22),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Já tem uma conta?",
                            style: TextStyle(color: Colors.black54),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const LoginScreen(),
                                ),
                              );
                            },
                            child: const Text(
                              "Entrar",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0035B9),
                              ),
                            ),
                          ),
                        ],
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

Widget campo(
  String titulo,
  IconData icone,
  String hint,
  TextEditingController controller, {
  bool obscure = false,
  bool mostrarAvisoSenha = false,
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 18),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              titulo,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black54,
              ),
            ),
            const SizedBox(width: 4),
            const Text(
              "*",
              style: TextStyle(
                color: Colors.red,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        TextField(
          controller: controller,
          obscureText: obscure,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icone),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(vertical: 18),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(50),
              borderSide: BorderSide.none,
            ),
          ),
        ),

        if (mostrarAvisoSenha)
          const Padding(
            padding: EdgeInsets.only(top: 8, left: 10),
            child: Text(
              "Obrigatório no mínimo 6 caracteres",
              style: TextStyle(
                color: Colors.deepPurple,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    ),
  );
}