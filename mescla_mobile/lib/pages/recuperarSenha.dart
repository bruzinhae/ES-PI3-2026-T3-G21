import 'package:flutter/material.dart';
import 'login_screen.dart';

class RecuperarSenhaScreen extends StatelessWidget {
  const RecuperarSenhaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FF),

      appBar: AppBar(
        elevation: 0,
        foregroundColor: Colors.white,
        title: const Text(
          "Recuperar Senha",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
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
                  color: Colors.black.withOpacity(0.08),
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

                const Text(
                  "Insira seu e-mail ou CPF cadastrado. Enviaremos um código de verificação para redefinir sua senha.",
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.5,
                    color: Colors.black54,
                  ),
                ),

                const SizedBox(height: 28),

                const Text(
                  "E-mail ou CPF",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.black54,
                  ),
                ),

                const SizedBox(height: 10),

                TextField(
                  decoration: InputDecoration(
                    hintText: "nome@exemplo.com ou 000.000.000-00",
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

                SizedBox(
                  width: double.infinity,
                  height: 58,
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.send),
                    label: const Text(
                      "Enviar Código de Recuperação",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: const Color(0xFF0035B9),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                const Divider(),

                const SizedBox(height: 10),

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