import 'package:flutter/material.dart';
import 'package:mescla_mobile/utils/app_colors.dart';
import '../../widgets/bottom_navBar.dart';

class AlterarEmailPage extends StatefulWidget {
  const AlterarEmailPage({super.key});

  @override
  State<AlterarEmailPage> createState() => _AlterarEmailPageState();
}

class _AlterarEmailPageState extends State<AlterarEmailPage> {
  final TextEditingController novoEmailController = TextEditingController();
  final TextEditingController confirmarEmailController = TextEditingController();

  @override
  void dispose() {
    novoEmailController.dispose();
    confirmarEmailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kSurface,
      bottomNavigationBar: const BottomNavBar(selectedIndex: 4),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 18, 22, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _topBar(context),

              const SizedBox(height: 46),

              const Text(
                'Alterar Email',
                style: TextStyle(
                  color: kOnSurface,
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 34),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(26, 28, 26, 28),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'E-mail atual',
                      style: TextStyle(
                        color: kOnSurface,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _inputField(
                      text: 'usuario@exemplo.com.br',
                    ),

                    const SizedBox(height: 24),

                    const Text(
                      'Novo e-mail',
                      style: TextStyle(
                        color: kOnSurface,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _inputField(
                      controller: novoEmailController,
                      hint: 'Digite o novo e-mail',
                    ),

                    const SizedBox(height: 24),

                    const Text(
                      'Confirmar novo e-mail',
                      style: TextStyle(
                        color: kOnSurface,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _inputField(
                      controller: confirmarEmailController,
                      hint: 'Repita o novo e-mail',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 26),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F0FF),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0xFFDCE7FF),
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.shield_outlined,
                      color: kPrimary,
                      size: 30,
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'Nunca compartilhe seus dados de acesso com terceiros.',
                        style: TextStyle(
                          color: kOnSurface,
                          fontSize: 16,
                          height: 1.4,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 34),

              GestureDetector(
                onTap: () {},
                child: Container(
                  width: double.infinity,
                  height: 62,
                  decoration: BoxDecoration(
                    gradient: kGradient,
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: kPrimary.withOpacity(0.18),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      'Atualizar e-mail',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _topBar(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(
            Icons.arrow_back,
            color: kPrimary,
            size: 30,
          ),
        ),
        const Expanded(
          child: Center(
            child: Text(
              'Segurança',
              style: TextStyle(
                color: kPrimary,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
        const SizedBox(width: 30),
      ],
    );
  }

  Widget _inputField({
    TextEditingController? controller,
    String? hint,
    String? text,
    bool enabled = true,
  }) {
    return TextField(
      controller: controller ?? TextEditingController(text: text),
      enabled: enabled,
      keyboardType: TextInputType.emailAddress,
      style: const TextStyle(
        color: kOnSurface,
        fontSize: 18,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: kOnSurface.withOpacity(0.85),
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 26,
          vertical: 18,
        ),
        filled: true,
        fillColor: Colors.white,
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(
            color: kOutline.withOpacity(0.35),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(
            color: kOutline.withOpacity(0.35),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(
            color: kPrimary,
            width: 1.5,
          ),
        ),
      ),
    );
  }
}