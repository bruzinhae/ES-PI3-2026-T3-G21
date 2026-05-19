// Autor: Alinne Monteiro de Melo
// RA: 24801649

// converte centavos para string formatada
String formatarMoeda(int centavos) {
  final reais  = centavos / 100;
  final partes = reais.toStringAsFixed(2).split('.');
  final inteiro = partes[0].replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
    (m) => '${m[1]}.',
  );
  return 'R\$ $inteiro,${partes[1]}';
}