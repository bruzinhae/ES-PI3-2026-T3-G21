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

  
  return true;
}

// email
bool validarEmail(String email) {
  final regex = RegExp(
    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
  );

  return regex.hasMatch(email);
}