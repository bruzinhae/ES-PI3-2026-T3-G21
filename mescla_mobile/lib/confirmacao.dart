import 'package:flutter/material.dart';

void main() {
  runApp(const MesclaInvestApp());
}

class MesclaInvestApp extends StatelessWidget {
  const MesclaInvestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MesclaInvest',
      theme: ThemeData(
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: const Color(0xFFEDEEFF),
      ),
      home: const ConfirmacaoPage(),
    );
  }
}

class ConfirmacaoPage extends StatelessWidget {
  const ConfirmacaoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEDEEFF),

      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),

            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(22),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // HEADER

                    Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: const DecorationImage(
                              image: NetworkImage(
                                'https://i.imgur.com/BoN9kdC.png',
                              ),
                              fit: BoxFit.cover,
                            ),
                            border: Border.all(
                              color: Colors.white,
                              width: 2,
                            ),
                          ),
                        ),

                        const SizedBox(width: 14),

                        const Expanded(
                          child: Text(
                            'MesclaInvest',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF3045D3),
                            ),
                          ),
                        ),

                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 28,
                            vertical: 16,
                          ),

                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),

                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF3055E8),
                                Color(0xFF8D35E6),
                              ],
                            ),
                          ),

                          child: const Text(
                            'Resgatar',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),

                    // SALDO CARD

                    _card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          const Text(
                            'SALDO TOTAL',
                            style: TextStyle(
                              letterSpacing: 2,
                              color: Color(0xFF6E7080),
                              fontSize: 15,
                            ),
                          ),

                          const SizedBox(height: 10),

                          RichText(
                            text: const TextSpan(
                              children: [

                                TextSpan(
                                  text: 'R\$ 15.420,00 ',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),

                                TextSpan(
                                  text: '850 tokens',
                                  style: TextStyle(
                                    color: Color(0xFF0D2CC8),
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 26),

                          Row(
                            children: [

                              Expanded(
                                child: _actionButton(
                                  title: 'Carregar\nSaldo',
                                  background: const Color(0xFFDDE3F1),
                                  textColor: const Color(0xFF0B2DD6),
                                  icon: Icons.add_circle_outline,
                                ),
                              ),

                              const SizedBox(width: 16),

                              Expanded(
                                child: _gradientButton(
                                  title: 'Resgatar\nLucros',
                                  icon: Icons.account_balance_wallet_outlined,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 22),

                    // DISPONÍVEL

                    _card(
                      child: Row(
                        children: [

                          Container(
                            width: 68,
                            height: 68,

                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18),
                              color: const Color(0xFFDDE3F1),
                            ),

                            child: const Icon(
                              Icons.account_balance_wallet_outlined,
                              color: Color(0xFF0D2CC8),
                              size: 34,
                            ),
                          ),

                          const SizedBox(width: 18),

                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [

                              Text(
                                'Disponível para resgate',
                                style: TextStyle(
                                  color: Color(0xFF717484),
                                  fontSize: 15,
                                ),
                              ),

                              SizedBox(height: 6),

                              Text(
                                'R\$ 1.240,00',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 22),

                    // CONTA DESTINO

                    _card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          const Text(
                            'Conta de Destino',
                            style: TextStyle(
                              color: Color(0xFF6E7080),
                              fontSize: 16,
                            ),
                          ),

                          const SizedBox(height: 22),

                          Row(
                            children: [

                              Container(
                                width: 52,
                                height: 52,

                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: const Color(0xFFDDE3F1),
                                ),

                                child: const Icon(
                                  Icons.account_balance,
                                  color: Color(0xFF3055E8),
                                ),
                              ),

                              const SizedBox(width: 16),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,

                                  children: const [

                                    Text(
                                      'Itaú Unibanco',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),

                                    SizedBox(height: 4),

                                    Text(
                                      'Ag 0432 • CC 29384-1',
                                      style: TextStyle(
                                        color: Color(0xFF6E7080),
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const Icon(
                                Icons.chevron_right,
                                size: 34,
                                color: Color(0xFF6E7080),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 26),

                    const Text(
                      'Valor do resgate',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // INPUT

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),

                      decoration: BoxDecoration(
                        color: const Color(0xFFE6EAF4),
                        borderRadius: BorderRadius.circular(40),
                      ),

                      child: Row(
                        children: [

                          const Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: 'R\$ 0,00',

                                hintStyle: TextStyle(
                                  fontSize: 18,
                                  color: Color(0xFF7D8192),
                                ),
                              ),
                            ),
                          ),

                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 14,
                            ),

                            decoration: BoxDecoration(
                              color: const Color(0xFFD9E1F3),
                              borderRadius: BorderRadius.circular(30),
                            ),

                            child: const Text(
                              'Resgatar tudo',
                              style: TextStyle(
                                color: Color(0xFF0D2CC8),
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 34),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,

                      children: const [

                        Text(
                          'Histórico de Rendimentos',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),

                        Text(
                          'Ver todos',
                          style: TextStyle(
                            color: Color(0xFF0D2CC8),
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    _historyTile(
                      icon: Icons.ev_station,
                      iconColor: Colors.green,
                      iconBg: const Color(0xFFDDF4E4),
                      title: 'EcoCharge',
                      subtitle: 'Dividendo\nMensal',
                      value: '+ R\$ 420,00',
                      date: '12 Out',
                    ),

                    _historyTile(
                      icon: Icons.local_shipping_outlined,
                      iconColor: Colors.blue,
                      iconBg: const Color(0xFFDDE7FA),
                      title: 'UrbanLog',
                      subtitle: 'Rendimentos\nSemestrais',
                      value: '+ R\$ 680,00',
                      date: '05 Out',
                    ),

                    _historyTile(
                      icon: Icons.account_balance_outlined,
                      iconColor: Colors.purple,
                      iconBg: const Color(0xFFF0DFFD),
                      title: 'FinFlow',
                      subtitle: 'Bonificação\nToken',
                      value: '+ R\$ 140,00',
                      date: '01 Out',
                    ),

                    const SizedBox(height: 24),

                    // BOTÃO

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 22),

                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(22),

                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF0A2CCF),
                            Color(0xFF7B39D8),
                          ],
                        ),
                      ),

                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,

                        children: const [

                          Text(
                            'Confirmar Resgate',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w500,
                            ),
                          ),

                          SizedBox(width: 14),

                          Icon(
                            Icons.arrow_forward,
                            color: Colors.white,
                            size: 30,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),

      // BOTTOM NAV

      bottomNavigationBar: Container(
        height: 95,

        decoration: const BoxDecoration(
          color: Colors.white,

          borderRadius: BorderRadius.vertical(
            top: Radius.circular(28),
          ),
        ),

        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,

          children: [
            _navItem(Icons.menu_book_outlined, 'Catálogo'),
            _navActive(),
            _navItem(Icons.account_balance_wallet_outlined, 'Carteira'),
            _navItem(Icons.grid_view_rounded, 'Dashboard'),
            _navItem(Icons.person_outline, 'Perfil'),
          ],
        ),
      ),
    );
  }

  static Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(26),

      decoration: BoxDecoration(
        color: const Color(0xFFF7F7FB),
        borderRadius: BorderRadius.circular(28),
      ),

      child: child,
    );
  }

  static Widget _actionButton({
    required String title,
    required Color background,
    required Color textColor,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18),

      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(24),
      ),

      child: Column(
        children: [
          Icon(icon, color: textColor),

          const SizedBox(height: 8),

          Text(
            title,
            textAlign: TextAlign.center,

            style: TextStyle(
              color: textColor,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  static Widget _gradientButton({
    required String title,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18),

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),

        gradient: const LinearGradient(
          colors: [
            Color(0xFF0D2CC8),
            Color(0xFF7B39D8),
          ],
        ),
      ),

      child: Column(
        children: [
          Icon(icon, color: Colors.white),

          const SizedBox(height: 8),

          Text(
            title,
            textAlign: TextAlign.center,

            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  static Widget _historyTile({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required String subtitle,
    required String value,
    required String date,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(22),

      decoration: BoxDecoration(
        color: const Color(0xFFF7F7FB),
        borderRadius: BorderRadius.circular(28),
      ),

      child: Row(
        children: [

          Container(
            width: 66,
            height: 66,

            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(18),
            ),

            child: Icon(
              icon,
              color: iconColor,
              size: 34,
            ),
          ),

          const SizedBox(width: 18),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [

                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFF6E7080),
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.end,

            children: [

              Text(
                value,
                style: const TextStyle(
                  color: Colors.green,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                date,
                style: const TextStyle(
                  color: Color(0xFF6E7080),
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static Widget _navItem(IconData icon, String label) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,

      children: [

        Icon(
          icon,
          color: const Color(0xFF67748E),
        ),

        const SizedBox(height: 6),

        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF67748E),
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  static Widget _navActive() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 22,
        vertical: 12,
      ),

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),

        gradient: const LinearGradient(
          colors: [
            Color(0xFF0D2CC8),
            Color(0xFF8D35E6),
          ],
        ),
      ),

      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,

        children: const [

          Icon(
            Icons.currency_exchange,
            color: Colors.white,
          ),

          SizedBox(height: 4),

          Text(
            'Negociar',
            style: TextStyle(
              color: Colors.white,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}