import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'confirmacao.dart';

// Função principal do app.
// É o ponto inicial onde o Flutter começa a executar o projeto.
void main() {
  runApp(const TradingApp());
}

// Widget principal do aplicativo.
// Ele configura o MaterialApp, tema, fonte e tela inicial.
class TradingApp extends StatelessWidget {
  const TradingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Remove a faixa vermelha de "Debug" no canto da tela.
      debugShowCheckedModeBanner: false,

      // Define o tema visual do aplicativo.
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1A56DB),
          brightness: Brightness.light,
        ),
        fontFamily: 'Roboto',
      ),

      // Define a primeira tela que será aberta no app.
      home: const TradingPage(),
    );
  }
}

// ─── Data Models ────────────────────────────────────────────────────────────

// Modelo de dados para cada oferta do livro de ofertas.
// Ele guarda quantidade, preço por token e valor total.
class OfferItem {
  final int quantity;
  final double pricePerToken;
  final double total;

  const OfferItem({
    required this.quantity,
    required this.pricePerToken,
    required this.total,
  });
}

// Modelo de dados para cada item do histórico de negociações.
// Guarda informações como empresa, quantidade, tokens, valor e status.
class HistoryItem {
  final String company;
  final String companyInitial;
  final Color companyColor;
  final int quantity;
  final int tokens;
  final double value;
  final String status;
  final Color statusColor;

  const HistoryItem({
    required this.company,
    required this.companyInitial,
    required this.companyColor,
    required this.quantity,
    required this.tokens,
    required this.value,
    required this.status,
    required this.statusColor,
  });
}

// ─── Main Page ───────────────────────────────────────────────────────────────

// Tela principal de negociação.
// StatefulWidget porque a tela muda conforme o usuário interage.
// Exemplo: muda aba, digita quantidade, mostra mais ofertas etc.
class TradingPage extends StatefulWidget {
  const TradingPage({super.key});

  @override
  State<TradingPage> createState() => _TradingPageState();
}

class _TradingPageState extends State<TradingPage>
    with TickerProviderStateMixin {
  // Controla qual item do menu inferior está selecionado.
  int _selectedTab = 1;

  // Guarda a startup selecionada no dropdown.
  String _selectedStartup = 'Green Energy Co.';

  // Controla o campo onde o usuário digita a quantidade de tokens.
  final TextEditingController _quantityController = TextEditingController();

  // Guarda o valor total da negociação calculado automaticamente.
  double _totalPrice = 0.0;

  // Preço fixo usado para calcular o total.
  final double _pricePerToken = 29.50;

  // Controla se o livro de ofertas mostra todas as ofertas ou só algumas.
  bool _showAllOffers = false;

  // Controla se a aba ativa do livro de ofertas é Comprar ou Vender.
  bool _offerTabComprar = true;

  // Controlador da animação de fade da tela.
  late AnimationController _fadeController;

  // Animação usada para fazer a tela aparecer suavemente.
  late Animation<double> _fadeAnimation;

  // Lista de startups exibidas no dropdown.
  final List<String> _startups = [
    'Green Energy Co.',
    'BioTech Solutions',
    'FinTech Hub',
    'AgriTech Brasil',
  ];

  // Lista fixa com ofertas exibidas no livro de ofertas.
  final List<OfferItem> _offers = const [
    OfferItem(quantity: 128, pricePerToken: 28.30, total: 3622.40),
    OfferItem(quantity: 75, pricePerToken: 28.60, total: 2145.00),
    OfferItem(quantity: 302, pricePerToken: 28.90, total: 8727.80),
    OfferItem(quantity: 56, pricePerToken: 29.10, total: 1629.60),
    OfferItem(quantity: 1003, pricePerToken: 28.20, total: 28284.60),
  ];

  // Lista fixa com o histórico de negociações recentes.
  final List<HistoryItem> _history = const [
    HistoryItem(
      company: 'Green Energy Co.',
      companyInitial: 'G',
      companyColor: Color(0xFF10B981),
      quantity: 50,
      tokens: 15,
      value: 1180.00,
      status: 'Concluido',
      statusColor: Color(0xFF10B981),
    ),
    HistoryItem(
      company: 'BioTech Solutions',
      companyInitial: 'B',
      companyColor: Color(0xFFF59E0B),
      quantity: 312,
      tokens: 48,
      value: 900.00,
      status: 'Pendente',
      statusColor: Color(0xFFF59E0B),
    ),
    HistoryItem(
      company: 'FinTech Hub',
      companyInitial: 'F',
      companyColor: Color(0xFF6366F1),
      quantity: 51,
      tokens: 48,
      value: 28628.00,
      status: 'Concluido',
      statusColor: Color(0xFF10B981),
    ),
  ];

  @override
  void initState() {
    super.initState();

    // Cria o controlador da animação de entrada da tela.
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    // Define a curva da animação para ela ficar mais suave.
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );

    // Inicia a animação quando a tela abre.
    _fadeController.forward();

    // Escuta tudo que o usuário digita no campo de quantidade.
    // Quando o número muda, o total é recalculado automaticamente.
    _quantityController.addListener(() {
      final qty = double.tryParse(_quantityController.text) ?? 0;
      setState(() {
        _totalPrice = qty * _pricePerToken;
      });
    });
  }

  @override
  void dispose() {
    // Libera os controladores da memória quando a tela é fechada.
    // Isso evita vazamento de memória.
    _fadeController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  // Formata valores para moeda brasileira.
  // Exemplo: 15420.00 vira R$ 15.420,00.
  String _formatCurrency(double value) {
    final formatted = value.toStringAsFixed(2).replaceAll('.', ',');
    final parts = formatted.split(',');
    final intPart = parts[0];
    final decPart = parts[1];
    final buffer = StringBuffer();
    int count = 0;

    for (int i = intPart.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) buffer.write('.');
      buffer.write(intPart[i]);
      count++;
    }

    return 'R\$ ${buffer.toString().split('').reversed.join()},$decPart';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Cor de fundo da tela inteira.
      backgroundColor: const Color(0xFFF4F6FA),

      // FadeTransition aplica a animação de entrada na tela.
      body: FadeTransition(
        opacity: _fadeAnimation,

        // Column organiza os principais blocos da tela na vertical.
        child: Column(
          children: [
            // Barra superior da tela.
            _buildAppBar(),

            // Expanded faz a parte central ocupar todo o espaço disponível.
            Expanded(
              // Permite rolar a tela quando o conteúdo for maior que a altura disponível.
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    // Card com patrimônio e tokens.
                    _buildBalanceCard(),
                    const SizedBox(height: 16),

                    // Área principal para negociar tokens.
                    _buildTradeSection(),
                    const SizedBox(height: 16),

                    // Livro com ofertas de compra/venda.
                    _buildOrderBook(),
                    const SizedBox(height: 16),

                    // Histórico recente de operações.
                    _buildRecentHistory(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // Menu inferior da tela.
            _buildBottomNav(),
          ],
        ),
      ),
    );
  }

  // ── AppBar ────────────────────────────────────────────────────────────────

  // Cria a barra superior da tela com botão de voltar, título e ícone de perfil.
  Widget _buildAppBar() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(
        // Usa MediaQuery para respeitar a área segura superior do celular.
        top: MediaQuery.of(context).padding.top + 8,
        left: 16,
        right: 16,
        bottom: 12,
      ),
      child: Row(
        children: [
          // Botão de voltar visual.
          GestureDetector(
            onTap: () {},
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFF0F4FF),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                size: 16,
                color: Color(0xFF1A56DB),
              ),
            ),
          ),

          // Expanded centraliza o título ocupando o espaço entre os botões.
          const Expanded(
            child: Text(
              'Balanço de Negociação',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF111827),
                letterSpacing: -0.3,
              ),
            ),
          ),

          // Botão/ícone de perfil do usuário.
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFF1A56DB),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.person_outline,
              size: 20,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // ── Balance Card ──────────────────────────────────────────────────────────

  // Card azul/roxo que mostra patrimônio, quantidade total de tokens e botões de ação.
  Widget _buildBalanceCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        // Gradiente de fundo do card.
        gradient: const LinearGradient(
          colors: [
            Color(0xFF0D2CC8),
            Color(0xFF8D35E6),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A56DB).withOpacity(0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Texto pequeno acima do valor principal.
          const Text(
            'Patrimônio em Movimentos',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),

          // Linha que mostra valor em reais e total de tokens.
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Expanded(
                child: Text(
                  'R\$ 15.420,00',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1,
                  ),
                ),
              ),

              // Coluna com quantidade de tokens.
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    '850',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    'Tokens',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    'Total de tokens',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 9,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Botões de ação dentro do card.
          Row(
            children: [
              Expanded(
                child: _buildBalanceButton(
                  label: 'Carregar Saldo',
                  icon: Icons.add_circle_outline,
                  filled: true,
                  onTap: () {},
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildBalanceButton(
                  label: 'Negociar Lucros',
                  icon: Icons.trending_up,
                  filled: false,
                  onTap: () {},
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Cria os botões pequenos dentro do card de saldo.
  // O parâmetro filled decide se o botão será branco ou transparente.
  Widget _buildBalanceButton({
    required String label,
    required IconData icon,
    required bool filled,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: filled ? Colors.white : Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
          border: filled ? null : Border.all(color: Colors.white38),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: filled ? const Color(0xFF1A56DB) : Colors.white,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: filled ? const Color(0xFF1A56DB) : Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Trade Section ─────────────────────────────────────────────────────────

  // Card principal onde o usuário escolhe startup, digita quantidade e confirma transação.
  Widget _buildTradeSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título do card de negociação com barrinha colorida.
          Row(
            children: [
              Container(
                width: 4,
                height: 18,
                decoration: BoxDecoration(
                  color: const Color(0xFF1A56DB),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Negociar',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF111827),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Label e dropdown da startup.
          _buildLabel('Selecionar Startup'),
          const SizedBox(height: 6),
          _buildStartupDropdown(),
          const SizedBox(height: 14),

          // Label e campo de quantidade.
          _buildLabel('Quantidade de Tokens'),
          const SizedBox(height: 6),
          _buildQuantityField(),
          const SizedBox(height: 14),

          // Linha com preço por token e valor total calculado.
          _buildPriceRow(),
          const SizedBox(height: 16),

          // Botão que confirma e navega para a página confirmacao.dart.
          _buildConfirmButton(),
          const SizedBox(height: 10),

          // Aviso da taxa de corretagem.
          Center(
            child: Text(
              'Taxa de corretagem de 2% será aplicada no valor total da operação',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[500],
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Cria labels pequenos usados acima de campos.
  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: Color(0xFF6B7280),
        letterSpacing: 0.2,
      ),
    );
  }

  // Dropdown para escolher a startup.
  Widget _buildStartupDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: DropdownButtonHideUnderline(
        // Remove a linha padrão do DropdownButton.
        child: DropdownButton<String>(
          value: _selectedStartup,
          isExpanded: true,
          icon: const Icon(
            Icons.keyboard_arrow_down,
            color: Color(0xFF1A56DB),
          ),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF111827),
          ),
          // Transforma cada startup da lista em uma opção do dropdown.
          items: _startups
              .map((s) => DropdownMenuItem(value: s, child: Text(s)))
              .toList(),
          // Quando o usuário escolhe outra startup, atualiza a tela.
          onChanged: (val) {
            if (val == null) return;
            setState(() => _selectedStartup = val);
          },
        ),
      ),
    );
  }

  // Campo onde o usuário digita a quantidade de tokens.
  Widget _buildQuantityField() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: TextField(
        controller: _quantityController,
        keyboardType: TextInputType.number,
        // Permite apenas números.
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Color(0xFF111827),
        ),
        decoration: InputDecoration(
          hintText: '0',
          hintStyle: TextStyle(color: Colors.grey[400]),
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          border: InputBorder.none,
          suffixText: 'tokens',
          suffixStyle: TextStyle(
            fontSize: 12,
            color: Colors.grey[500],
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  // Mostra preço por token e valor total da operação.
  Widget _buildPriceRow() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F4FF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Valor unitário do token.
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Preço por token',
                style: TextStyle(fontSize: 10, color: Colors.grey[600]),
              ),
              const SizedBox(height: 2),
              const Text(
                'R\$ 29,50',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A56DB),
                ),
              ),
            ],
          ),

          // Divisor vertical entre preço e total.
          Container(
            width: 1,
            height: 36,
            color: Colors.blue[100],
          ),

          // Total calculado conforme a quantidade digitada.
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Total',
                style: TextStyle(fontSize: 10, color: Colors.grey[600]),
              ),
              const SizedBox(height: 2),
              Text(
                _formatCurrency(_totalPrice),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF111827),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Botão principal de confirmação da transação.
  // Ao clicar, vibra levemente e abre a página ConfirmacaoPage.
  Widget _buildConfirmButton() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ConfirmacaoPage(),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFF1A56DB),
              Color(0xFF2563EB),
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1A56DB).withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: const Text(
          'Confirmar Transação',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }

  // ── Order Book ────────────────────────────────────────────────────────────

  // Card que mostra o livro de ofertas.
  // Ele lista ofertas disponíveis e permite alternar entre Comprar/Vender.
  Widget _buildOrderBook() {
    final displayedOffers = _showAllOffers ? _offers : _offers.take(4).toList();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cabeçalho do livro de ofertas.
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 4,
                    height: 18,
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Livro de Ofertas',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF111827),
                    ),
                  ),
                ],
              ),

              // Chips Comprar/Vender.
              Row(
                children: [
                  _buildTabChip('Comprar', true),
                  const SizedBox(width: 6),
                  _buildTabChip('Vender', false),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Cabeçalho da tabela.
          _buildOrderBookHeader(),
          const SizedBox(height: 4),

          // Linhas das ofertas exibidas.
          ...displayedOffers.map((offer) => _buildOfferRow(offer)),
          const SizedBox(height: 8),

          // Botão para ver todas ou esconder ofertas.
          GestureDetector(
            onTap: () => setState(() => _showAllOffers = !_showAllOffers),
            child: Center(
              child: Text(
                _showAllOffers ? 'Ver menos ofertas' : 'Ver todas as ofertas',
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF1A56DB),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Cria os chips Comprar e Vender.
  // O chip ativo fica azul, o inativo fica cinza.
  Widget _buildTabChip(String label, bool isComprar) {
    final isActive = _offerTabComprar == isComprar;
    return GestureDetector(
      onTap: () => setState(() => _offerTabComprar = isComprar),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF1A56DB) : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: isActive ? Colors.white : Colors.grey[600],
          ),
        ),
      ),
    );
  }

  // Cabeçalho da tabela de ofertas.
  Widget _buildOrderBookHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              'Quantidade',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: Color(0xFF6B7280),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Preço/Token',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: Color(0xFF6B7280),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Total',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: Color(0xFF6B7280),
              ),
            ),
          ),
          SizedBox(width: 64),
        ],
      ),
    );
  }

  // Cria cada linha de oferta com quantidade, preço, total e botão Comprar.
  Widget _buildOfferRow(OfferItem offer) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[100]!, width: 1),
        ),
      ),
      child: Row(
        children: [
          // Quantidade de tokens da oferta.
          Expanded(
            flex: 2,
            child: Text(
              '${offer.quantity} tokens',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF111827),
              ),
            ),
          ),

          // Preço por token da oferta.
          Expanded(
            flex: 2,
            child: Text(
              _formatCurrency(offer.pricePerToken),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF111827),
              ),
            ),
          ),

          // Total da oferta.
          Expanded(
            flex: 2,
            child: Text(
              _formatCurrency(offer.total),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF111827),
              ),
            ),
          ),

          // Botão Comprar da linha.
          GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Comprando ${offer.quantity} tokens por ${_formatCurrency(offer.pricePerToken)}',
                  ),
                  backgroundColor: const Color(0xFF1A56DB),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFF1A56DB),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Comprar',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Recent History ────────────────────────────────────────────────────────

  // Card com o histórico recente das operações.
  Widget _buildRecentHistory() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título do histórico.
          Row(
            children: [
              Container(
                width: 4,
                height: 18,
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Histórico Recente',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF111827),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Cabeçalho da tabela de histórico.
          _buildHistoryHeader(),

          // Gera uma linha para cada item do histórico.
          ..._history.map((item) => _buildHistoryRow(item)),
        ],
      ),
    );
  }

  // Cabeçalho da tabela do histórico.
  Widget _buildHistoryHeader() {
    const style = TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.w700,
      color: Color(0xFF6B7280),
    );

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Row(
        children: [
          Expanded(flex: 3, child: Text('Título', style: style)),
          Expanded(
            flex: 2,
            child: Text('Qtd', textAlign: TextAlign.center, style: style),
          ),
          Expanded(
            flex: 2,
            child: Text('Tokens', textAlign: TextAlign.center, style: style),
          ),
          Expanded(
            flex: 2,
            child: Text('Valor', textAlign: TextAlign.center, style: style),
          ),
          Expanded(
            flex: 2,
            child: Text('Status', textAlign: TextAlign.center, style: style),
          ),
        ],
      ),
    );
  }

  // Cria cada linha do histórico.
  Widget _buildHistoryRow(HistoryItem item) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[100]!, width: 1),
        ),
      ),
      child: Row(
        children: [
          // Coluna com avatar/letra da empresa e nome.
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: item.companyColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      item.companyInitial,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: item.companyColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    item.company,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF111827),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          // Quantidade negociada.
          Expanded(
            flex: 2,
            child: Text(
              '${item.quantity}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Color(0xFF374151),
              ),
            ),
          ),

          // Tokens recebidos/negociados.
          Expanded(
            flex: 2,
            child: Text(
              '${item.tokens}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Color(0xFF374151),
              ),
            ),
          ),

          // Valor da operação.
          Expanded(
            flex: 2,
            child: Text(
              _formatCurrency(item.value),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Color(0xFF374151),
              ),
            ),
          ),

          // Status da operação, com cor própria.
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              decoration: BoxDecoration(
                color: item.statusColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                item.status,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: item.statusColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Bottom Navigation ─────────────────────────────────────────────────────

  // Menu inferior da tela.
  // Mostra as seções: Início, Negociar, Mercado e Carteira.
  Widget _buildBottomNav() {
    final items = [
      {'icon': Icons.home_outlined, 'label': 'Início'},
      {'icon': Icons.swap_horiz, 'label': 'Negociar'},
      {'icon': Icons.bar_chart_outlined, 'label': 'Mercado'},
      {'icon': Icons.account_balance_wallet_outlined, 'label': 'Carteira'},
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (i) {
              // Verifica se o item atual é o selecionado.
              final isActive = i == _selectedTab;

              return GestureDetector(
                onTap: () => setState(() => _selectedTab = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isActive
                        ? const Color(0xFF1A56DB).withOpacity(0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Ícone do item do menu.
                      Icon(
                        items[i]['icon'] as IconData,
                        size: 22,
                        color: isActive
                            ? const Color(0xFF1A56DB)
                            : Colors.grey[400],
                      ),
                      const SizedBox(height: 3),

                      // Texto do item do menu.
                      Text(
                        items[i]['label'] as String,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight:
                          isActive ? FontWeight.w700 : FontWeight.w500,
                          color: isActive
                              ? const Color(0xFF1A56DB)
                              : Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
