class TradingService {
  static const double taxaCorretagem = 0.02;

  double calcularTotal({
    required int quantidadeTokens,
    required double precoPorToken,
  }) {
    return quantidadeTokens * precoPorToken;
  }

  double calcularTaxaCorretagem(double total) {
    return total * taxaCorretagem;
  }

  double calcularValorFinal(double total) {
    return total + calcularTaxaCorretagem(total);
  }

  String? validarTransacao({
    required String startup,
    required int quantidadeTokens,
  }) {
    if (startup.isEmpty) {
      return 'Selecione uma startup.';
    }

    if (quantidadeTokens <= 0) {
      return 'Informe uma quantidade válida de tokens.';
    }

    return null;
  }

  Map<String, dynamic> criarTransacao({
    required String startup,
    required int quantidadeTokens,
    required double precoPorToken,
  }) {
    final total = calcularTotal(
      quantidadeTokens: quantidadeTokens,
      precoPorToken: precoPorToken,
    );

    final taxa = calcularTaxaCorretagem(total);
    final valorFinal = calcularValorFinal(total);

    return {
      'startup': startup,
      'quantidadeTokens': quantidadeTokens,
      'precoPorToken': precoPorToken,
      'valorTotal': total,
      'taxaCorretagem': taxa,
      'valorFinal': valorFinal,
      'status': 'Pendente',
      'dataCriacao': DateTime.now().toIso8601String(),
    };
  }
}