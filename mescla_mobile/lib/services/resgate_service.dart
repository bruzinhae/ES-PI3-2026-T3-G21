class ResgateService {
  String? validarResgate({
    required double valor,
    required double saldoDisponivel,
  }) {
    if (valor <= 0) {
      return 'Digite um valor válido.';
    }

    if (valor > saldoDisponivel) {
      return 'Saldo insuficiente para resgate.';
    }

    return null;
  }

  double calcularNovoSaldo({
    required double saldoAtual,
    required double valorResgate,
  }) {
    return saldoAtual - valorResgate;
  }
}