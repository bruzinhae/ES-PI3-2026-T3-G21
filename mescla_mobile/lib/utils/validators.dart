// Autor: Alinne Monteiro de Melo
// RA: 24801649

// cpf
bool validarCPF(String cpf) {
  // Remove tudo que não for número
  cpf = cpf.replaceAll(RegExp(r'[^0-9]'), '');

  // Deve ter 11 dígitos
  if (cpf.length != 11) return false;

  // Elimina CPFs iguais (11111111111, 00000000000, etc)
  if (RegExp(r'^(\d)\1*$').hasMatch(cpf)) return false;

  // --- Cálculo do 1º dígito ---
  int soma = 0;
  for (int i = 0; i < 9; i++) {
    soma += int.parse(cpf[i]) * (10 - i);
  }

  int primeiroDigito = (soma * 10) % 11;
  if (primeiroDigito == 10) primeiroDigito = 0;

  if (primeiroDigito != int.parse(cpf[9])) return false;

  // --- Cálculo do 2º dígito ---
  soma = 0;
  for (int i = 0; i < 10; i++) {
    soma += int.parse(cpf[i]) * (11 - i);
  }

  int segundoDigito = (soma * 10) % 11;
  if (segundoDigito == 10) segundoDigito = 0;

  if (segundoDigito != int.parse(cpf[10])) return false;

  return true;
}

// email
bool validarEmail(String email) {
  final regex = RegExp(
    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
  );

  return regex.hasMatch(email);
}