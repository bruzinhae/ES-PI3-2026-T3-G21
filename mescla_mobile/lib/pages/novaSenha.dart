import 'package:flutter/material.dart';
import 'login_screen.dart';

class NovaSenhaScreen extends StatefulWidget {
  const NovaSenhaScreen({super.key});

  @override
  State<NovaSenhaScreen> createState() => _NovaSenhaScreenState();
}

class _NovaSenhaScreenState extends State<NovaSenhaScreen> {
  bool obscure1 = true;
  bool obscure2 = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FF),

      appBar: AppBar(
        elevation: 0,
        foregroundColor: Colors.white,
        title: const Text(
          "Nova Senha",
          style: TextStyle(fontWeight: FontWeight.bold),
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

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            const Text(
              "Defina sua nova senha",
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0035B9),
              ),
            ),

            const SizedBox(height: 12),

            const Text(
              "Sua senha deve ter pelo menos 6 caracteres.",
              style: TextStyle(
                fontSize: 15,
                color: Colors.black54,
              ),
            ),

            const SizedBox(height: 35),

            const Text(
              "Nova Senha",
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: Color(0xFF0035B9),
              ),
            ),

            const SizedBox(height: 10),

            TextField(
              obscureText: obscure1,
              decoration: InputDecoration(
                hintText: "Digite sua nova senha",
                filled: true,
                fillColor: Colors.white,
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      obscure1 = !obscure1;
                    });
                  },
                  icon: Icon(
                    obscure1
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 25),

            const Text(
              "Confirmar Nova Senha",
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: Color(0xFF0035B9),
              ),
            ),

            const SizedBox(height: 10),

            TextField(
              obscureText: obscure2,
              decoration: InputDecoration(
                hintText: "Repita a nova senha",
                filled: true,
                fillColor: Colors.white,
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      obscure2 = !obscure2;
                    });
                  },
                  icon: Icon(
                    obscure2
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 28),

            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: Color(0xFF0035B9),
                  ),
                  SizedBox(width: 10),
                  Text(
                    "Pelo menos 6 caracteres",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 35),

            SizedBox(
              width: double.infinity,
              height: 58,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const LoginScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0035B9),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  "Atualizar Senha",
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
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