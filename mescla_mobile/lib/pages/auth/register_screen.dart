// Autor: Alinne Monteiro de Melo 
// RA: 24801649

import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'login_screen.dart';
import '../../services/auth_service.dart';
import 'package:mescla_mobile/utils/validators.dart';
import '../../widgets/app_button.dart';
import 'package:mescla_mobile/utils/formatters.dart';


class CadastroScreen extends StatefulWidget {
  const CadastroScreen({super.key});

  @override
  State<CadastroScreen> createState() => _CadastroScreenState();
}

class _CadastroScreenState extends State<CadastroScreen> {
  // cada controller captura o texto digitado no seu respectivo campo
  final nomeController = TextEditingController();
  final cpfController = TextEditingController();
  final emailController = TextEditingController();
  final telefoneController = TextEditingController();
  final senhaController = TextEditingController();
  final confirmarSenhaController = TextEditingController();

  // controla a exibição do indicador de carregamento no botão
  bool carregando = false;

  // libera todos os controladores da memória quando a tela é destruída
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

  // valida todos os campos antes de enviar o cadastro
  bool validarCampos() {
    // verifica se algum campo obrigatório está vazio
    if (nomeController.text.trim().isEmpty ||
        cpfController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty ||
        telefoneController.text.trim().isEmpty ||
        senhaController.text.trim().isEmpty ||
        confirmarSenhaController.text.trim().isEmpty) {
      mostrarErro("Preencha todos os campos obrigatórios.");
      return false;
    }

    // verifica se o formato do e-mail é válido usando a função importada de validators.dart
    if (!validarEmail(emailController.text)) {
      mostrarErro("Email inválido.");
      return false;
    }

    // verifica se a senha tem o tamanho mínimo exigido
    if (senhaController.text.length < 6) {
      mostrarErro("A senha deve ter no mínimo 6 caracteres.");
      return false;
    }

    // verifica se as duas senhas digitadas são iguais
    if (senhaController.text != confirmarSenhaController.text) {
      mostrarErro("As senhas não conferem.");
      return false;
    }

    // verifica se o CPF é matematicamente válido (dígitos verificadores)
    if (!validarCPF(cpfController.text)) {
      mostrarErro("CPF inválido.");
      return false;
    }

    return true;
  }

  // realiza o cadastro do usuário chamando o serviço de autenticação
  Future<void> cadastrarUsuario() async {
    // interrompe se a validação falhar
    if (!validarCampos()) return;

    setState(() {
      carregando = true;
    });

    try {
      // envia os dados para o Firebase criar o usuário
      await AuthService.createUser(
        name: nomeController.text.trim(),
        email: emailController.text.trim(),
        password: senhaController.text.trim(),
        cpf: cpfController.text.trim(),
        telefone: telefoneController.text.trim(),
      );

      if (!mounted) return;

      // exibe mensagem de sucesso ao criar a conta
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Conta criada com sucesso! Verifique seu e-mail."),
        ),
      );

      // redireciona para o login substituindo a tela atual
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        ),
      );
    } catch (e) {
      mostrarErro("Erro ao criar conta. Verifique os dados e tente novamente.");
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
      backgroundColor: const Color(0xFFF8F9FF),
      body: SafeArea(
        child: Column(
          children: [
            // cabeçalho com gradiente, botão de voltar e título da tela
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
                      // botão de voltar para a tela anterior
                      CircleAvatar(
                        backgroundColor: Colors.white24,
                        child: IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                        ),
                      ),
                      // título centralizado usando Expanded para ocupar o espaço restante
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
                      // SizedBox vazio para equilibrar o espaço ocupado pelo botão de voltar
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

            // área rolável com o formulário de cadastro
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
                      // campos do formulário usando a função reutilizável campo()
                      campo("Nome completo", Icons.person, "Como quer ser chamado?", nomeController),

                      // campo CPF com formatador que aplica a máscara 000.000.000-00
                      campo(
                        "CPF", Icons.badge, "000.000.000-00", cpfController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [CpfInputFormatter()],
                      ),

                      campo("E-mail", Icons.email, "seuemail@exemplo.com", emailController),

                      // campo telefone com formatador que aplica a máscara (00) 00000-0000
                      campo(
                        "Telefone", Icons.phone, "(00) 00000-0000", telefoneController,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [TelefoneInputFormatter()],
                      ),

                      // campo senha com aviso de mínimo de caracteres abaixo do campo
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

                      // botão reutilizável do app que mostra spinner quando loading é true
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

                      // link para a tela de login caso o usuário já tenha conta
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Já tem uma conta?",
                            style: TextStyle(color: Colors.black54),
                          ),
                          TextButton(
                            onPressed: () {
                              // substitui a tela atual pela de login
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

// função reutilizável que constrói um campo de formulário padronizado
// recebe título, ícone, placeholder, controller e parâmetros opcionais
Widget campo(
  String titulo,
  IconData icone,
  String hint,
  TextEditingController controller, {
  bool obscure = false,             // oculta o texto quando true (usado em senhas)
  bool mostrarAvisoSenha = false,   // exibe aviso de mínimo de caracteres abaixo do campo
  List<TextInputFormatter>? inputFormatters, // aplica máscaras como CPF e telefone
  TextInputType? keyboardType,      // define o tipo de teclado (numérico, e-mail etc)
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
            // asterisco vermelho indicando que o campo é obrigatório
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
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icone),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(vertical: 18),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(50),
              borderSide: BorderSide.none, // remove a borda padrão do campo
            ),
          ),
        ),

        // exibe o aviso de tamanho mínimo somente no campo de senha
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