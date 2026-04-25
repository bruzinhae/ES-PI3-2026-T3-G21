import 'package:flutter/material.dart';

class VerificacaoCodigoScreen extends StatelessWidget {
  const VerificacaoCodigoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FF),

      appBar: AppBar(
        elevation: 0,
        foregroundColor: Colors.white,
        title: const Text(
          "Verificação",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF0035B9),
                Color(0xFF625B71),
              ],
            ),
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            const Text(
              "Código de Verificação",
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0035B9),
              ),
            ),

            const SizedBox(height: 12),

            const Text(
              "Insira o código de 6 dígitos que enviamos para seu e-mail.",
              style: TextStyle(
                fontSize: 15,
                color: Colors.black54,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 40),

            TextField(
              keyboardType: TextInputType.number,
              maxLength: 6,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: 8,
              ),
              decoration: InputDecoration(
                counterText: "",
                hintText: "______",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 35),

            SizedBox(
              width: double.infinity,
              height: 58,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0035B9),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  "Verificar código",
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 28),

            Center(
              child: Column(
                children: [
                  const Text(
                    "Não recebeu o código?",
                    style: TextStyle(
                      color: Colors.black54,
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      "Reenviar novo código",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0035B9),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            const Divider(),

            const SizedBox(height: 10),

            const Row(
              children: [
                Icon(
                  Icons.timer_outlined,
                  color: Colors.black54,
                ),
                SizedBox(width: 8),
                Text(
                  "O código expira em 10:00 minutos",
                  style: TextStyle(
                    color: Colors.black54,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 25),

            const Center(
              child: Text(
                "MESCLAINVEST",
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 3,
                  color: Color(0x660035B9),
                ),
              ),
            ),

            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}