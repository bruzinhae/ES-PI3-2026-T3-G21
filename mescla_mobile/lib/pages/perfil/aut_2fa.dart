// Autor: Bruna Barbour Fernandes
// RA: 23007950

import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:mescla_mobile/services/perfil_service.dart';
import 'package:mescla_mobile/utils/app_colors.dart';
import '../../widgets/bottom_navBar.dart';

class Seguranca2FAPage extends StatefulWidget {
  const Seguranca2FAPage({super.key});

  @override
  State<Seguranca2FAPage> createState() => _Seguranca2FAPageState();
}

class _Seguranca2FAPageState extends State<Seguranca2FAPage> {
  final UserService _userService = UserService();

  bool twoFactorEnabled = false;
  bool carregando = false;

  @override
  void initState() {
    super.initState();
    carregarStatusMfa();
  }

  Future<void> carregarStatusMfa() async {
    try {
      final user = await _userService.getUserDetails();

      if (!mounted) return;

      setState(() {
        twoFactorEnabled = user.mfaEnabled;
      });
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro ao carregar status do 2FA.'),
        ),
      );
    }
  }

  Future<void> iniciarAtivacaoMfa() async {
    setState(() => carregando = true);

    try {
      await _userService.sendMfaCodeByEmail(); // chama o back para enviar o código no email

      if (!mounted) return;

      final codigo = await _abrirModalCodigo();

      if (codigo == null || codigo.trim().isEmpty) {
        return;
      }

      final result = await _userService.enableMfa(
        code: codigo.trim(),
      );

      if (!mounted) return;

      setState(() {
        twoFactorEnabled = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result['message'] ?? 'MFA ativado com sucesso.',
          ),
        ),
      );
    } on FirebaseFunctionsException catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.message ?? 'Erro ao ativar autenticação.',
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro inesperado ao ativar MFA.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => carregando = false);
      }
    }
  }

  Future<void> desativarMfa() async {
    setState(() => carregando = true);

    try {
      final result = await _userService.disableMfa();

      if (!mounted) return;

      setState(() {
        twoFactorEnabled = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result['message'] ?? '2FA desativado com sucesso.',
          ),
        ),
      );
    } on FirebaseFunctionsException catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.message ?? 'Erro ao desativar autenticação.',
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro inesperado ao desativar MFA.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => carregando = false);
      }
    }
  }

  Future<String?> _abrirModalCodigo() async {
    final controller = TextEditingController();

    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Código de verificação'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            maxLength: 6,
            decoration: const InputDecoration(
              hintText: 'Digite o código recebido',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, controller.text);
              },
              child: const Text('Confirmar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kSurface,
      bottomNavigationBar: const BottomNavBar(
        selectedIndex: 4,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: kPrimary,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Text(
                        'Segurança',
                        style: TextStyle(
                          color: kPrimary,
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.shield_outlined,
                      color: kPrimary,
                      size: 26,
                    ),
                  ],
                ),

                const SizedBox(height: 42),

                const Text(
                  'Autenticação em\ndois fatores',
                  style: TextStyle(
                    color: kOnSurface,
                    fontSize: 32,
                    height: 1.15,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 18),

                const Text(
                  'Ao ativar, enviaremos um código de segurança para seu e-mail sempre que houver uma tentativa de login.',
                  style: TextStyle(
                    color: kOutline,
                    fontSize: 16,
                    height: 1.6,
                  ),
                ),

                const SizedBox(height: 28),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE9EEFF),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Icon(
                          Icons.shield_outlined,
                          color: kPrimary,
                          size: 34,
                        ),
                      ),

                      const SizedBox(width: 18),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'STATUS ATUAL',
                              style: TextStyle(
                                color: kOutline,
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.5,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              twoFactorEnabled
                                  ? '2FA ativado'
                                  : '2FA desativado',
                              style: TextStyle(
                                color: twoFactorEnabled
                                    ? Colors.green
                                    : Colors.red,
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),

                      carregando
                          ? const SizedBox(
                        width: 28,
                        height: 28,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                          : Switch(
                        value: twoFactorEnabled,
                        activeColor: Colors.white,
                        activeTrackColor: kPrimary,
                        inactiveThumbColor: Colors.white,
                        inactiveTrackColor:
                        kOutline.withOpacity(0.35),
                        onChanged: (value) {
                          if (value) {
                            iniciarAtivacaoMfa();
                          } else {
                            desativarMfa();
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}