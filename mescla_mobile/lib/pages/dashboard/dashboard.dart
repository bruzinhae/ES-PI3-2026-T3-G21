// Autor: Alinne Monteiro de Melo
// RA: 24801649

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_functions/cloud_functions.dart';
import '../../widgets/bottom_navBar.dart';
import '../../utils/app_colors.dart';
import 'service/dashboard_service.dart';
import 'widgets/dashboard_topbar.dart';
import 'widgets/glasscontainer.dart';
import 'widgets/valuationcard.dart';
import 'widgets/startupcard.dart';
import 'widgets/portfoliochart.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String selectedPeriod = '6M';
  final List<String> periods = ['1D', '7D', '1M', '6M', 'YTD'];

  bool carregando = true;
  bool carregandoGrafico = false;
  String? erro;
  DashboardData? dashboard;
  TokenPriceHistory? tokenHistory;

  @override
  void initState() {
    super.initState();
    carregarDashboard();
  }

  Future<void> carregarDashboard() async {
    setState(() {
      carregando = true;
      erro = null;
    });

    try {
      final dados = await DashboardService.getUserDashboard(period: selectedPeriod);
      setState(() {
        dashboard = dados;
        carregando = false;
      });
      await carregarGrafico();
    } on FirebaseFunctionsException catch (e) {
      setState(() {
        carregando = false;
        erro = 'Erro: ${e.message}';
      });
    } catch (e) {
      setState(() {
        carregando = false;
        erro = 'Erro inesperado ao carregar dashboard.';
      });
    }
  }

  Future<void> carregarGrafico() async {
    if (dashboard == null || dashboard!.assets.isEmpty) return;

    setState(() => carregandoGrafico = true);

    try {
      final topAsset = dashboard!.assets.reduce(
        (a, b) => a.currentValueCents > b.currentValueCents ? a : b,
      );

      final history = await DashboardService.getTokenPriceHistory(
        startupId: topAsset.startupId,
        period: selectedPeriod,
      );

      setState(() {
        tokenHistory = history;
        carregandoGrafico = false;
      });
    } catch (e) {
      setState(() => carregandoGrafico = false);
      debugPrint('Erro ao carregar gráfico: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const BottomNavBar(selectedIndex: 3),
      backgroundColor: kSurface,
      body: Stack(
        children: [
          Container(color: kSurface),

          if (carregando)
            const Center(child: CircularProgressIndicator())
          else if (erro != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(erro!, style: const TextStyle(color: Colors.red)),
              ),
            )
          else
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 104, 16, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dashboard',
                    style: TextStyle(
                      fontSize: 32,
                      height: 1.25,
                      fontWeight: FontWeight.w700,
                      color: kOnSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Acompanhe a valorização dos seus tokens',
                    style: TextStyle(fontSize: 16, height: 1.5, color: kOutline),
                  ),
                  const SizedBox(height: 24),

                  ValuationCard(dashboard: dashboard!),

                  const SizedBox(height: 24),

                  GlassContainer(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Evolução do Patrimônio',
                          style: GoogleFonts.manrope(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: kOnSurface,
                          ),
                        ),
                        if (dashboard!.assets.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              dashboard!.assets
                                  .reduce((a, b) => a.currentValueCents > b.currentValueCents ? a : b)
                                  .startupName,
                              style: TextStyle(fontSize: 12, color: kOutline),
                            ),
                          ),
                        const SizedBox(height: 20),
                        SizedBox(
                          height: 230,
                          width: double.infinity,
                          child: carregandoGrafico
                              ? const Center(child: CircularProgressIndicator())
                              : tokenHistory == null || tokenHistory!.history.isEmpty
                                  ? Center(
                                      child: Text(
                                        'Sem dados para o período.',
                                        style: TextStyle(color: kOutline, fontSize: 13),
                                      ),
                                    )
                                  : PortfolioChart(points: tokenHistory!.history),
                        ),
                        const SizedBox(height: 28),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: periods.map((period) {
                            final bool isSelected = selectedPeriod == period;
                            return GestureDetector(
                              onTap: () {
                                setState(() => selectedPeriod = period);
                                carregarDashboard();
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                padding: EdgeInsets.symmetric(
                                  horizontal: isSelected ? 20 : 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected ? kPrimary : Colors.transparent,
                                  borderRadius: BorderRadius.circular(999),
                                  boxShadow: isSelected
                                      ? [BoxShadow(color: kPrimary.withOpacity(0.25), blurRadius: 14, offset: const Offset(0, 6))]
                                      : [],
                                ),
                                child: Text(
                                  period,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: isSelected ? Colors.white : kOutline,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  Text(
                    'Minhas Startups',
                    style: TextStyle(
                      fontSize: 24,
                      height: 1.3,
                      fontWeight: FontWeight.w700,
                      color: kOnSurface,
                    ),
                  ),

                  const SizedBox(height: 12),

                  if (dashboard!.assets.isEmpty)
                    Text(
                      'Você ainda não possui tokens em nenhuma startup.',
                      style: TextStyle(fontSize: 14, color: kOutline),
                    )
                  else
                    Column(
                      children: dashboard!.assets
                          .map((asset) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: StartupCard(asset: asset),
                              ))
                          .toList(),
                    ),
                ],
              ),
            ),

          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: DashboardTopBar(),
          ),
        ],
      ),
    );
  }
}