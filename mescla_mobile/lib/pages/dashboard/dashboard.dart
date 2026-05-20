import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_functions/cloud_functions.dart';
import '../../widgets/bottom_navBar.dart';
import '../../utils/app_colors.dart';
import '../../pages/dashboard/service/dashboard_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String selectedPeriod = '6M';
  final List<String> periods = ['1D', '7D', '1M', '6M', 'YTD'];

  bool carregando = true;
  String? erro;
  DashboardData? dashboard;

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
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.5,
                      color: kOutline,
                    ),
                  ),
                  const SizedBox(height: 24),

                  _ValuationCard(dashboard: dashboard!),

                  const SizedBox(height: 24),

                  _GlassContainer(
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
                        const SizedBox(height: 20),
                        const SizedBox(
                          height: 230,
                          width: double.infinity,
                          child: _PortfolioChart(),
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
                                      ? [
                                          BoxShadow(
                                            color: kPrimary.withOpacity(0.25),
                                            blurRadius: 14,
                                            offset: const Offset(0, 6),
                                          ),
                                        ]
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
                                child: _StartupCard(asset: asset),
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
            child: _DashboardTopBar(),
          ),
        ],
      ),
    );
  }
}

// ─── TopBar ────────────────────────────────────────────────────────────────

class _DashboardTopBar extends StatelessWidget {
  const _DashboardTopBar();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.72),
            border: Border(
              bottom: BorderSide(color: Colors.white.withOpacity(0.45)),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
              child: Row(
                children: [
                  const SizedBox(width: 12),
                  Text(
                    'MesclaInvest',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: kPrimary,
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── ValuationCard ─────────────────────────────────────────────────────────

class _ValuationCard extends StatelessWidget {
  final DashboardData dashboard;

  const _ValuationCard({required this.dashboard});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: kGradient,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Valor total estimado',
            style: GoogleFonts.workSans(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.white.withOpacity(0.82),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            dashboard.totalFormatado,
            style: GoogleFonts.manrope(
              fontSize: 40,
              height: 1.15,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.8,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  children: [
                    Icon(
                      dashboard.positivo
                          ? Icons.trending_up_rounded
                          : Icons.trending_down_rounded,
                      size: 16,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      dashboard.variacaoFormatada,
                      style: GoogleFonts.workSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  'no período ${dashboard.period}',
                  style: GoogleFonts.workSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withOpacity(0.72),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── StartupCard ───────────────────────────────────────────────────────────

class _StartupCard extends StatelessWidget {
  final DashboardAsset asset;

  const _StartupCard({required this.asset});

  @override
  Widget build(BuildContext context) {
    return _GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0xFFD3E4FE),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.eco_outlined, color: kPrimary, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  asset.startupName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.manrope(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: kOnSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${asset.quantity} tokens',
                  style: GoogleFonts.workSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: kOutline,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                asset.valorFormatado,
                style: GoogleFonts.manrope(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: kOnSurface,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Icon(
                    asset.positivo
                        ? Icons.trending_up_rounded
                        : Icons.trending_down_rounded,
                    size: 14,
                    color: asset.positivo ? Colors.green : Colors.red,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    asset.variacaoFormatada,
                    style: GoogleFonts.workSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: asset.positivo
                          ? Colors.green.shade700
                          : Colors.red.shade700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── GlassContainer ────────────────────────────────────────────────────────

class _GlassContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const _GlassContainer({required this.child, this.padding = const EdgeInsets.all(16)});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          width: double.infinity,
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.70),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.45)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.035),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

// ─── Chart (estático por enquanto) ─────────────────────────────────────────

class _PortfolioChart extends StatelessWidget {
  const _PortfolioChart();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _PortfolioChartPainter(),
      child: const SizedBox.expand(),
    );
  }
}

class _PortfolioChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = const Color(0xFFC4C5D7).withOpacity(0.22)
      ..strokeWidth = 1;

    const chartLeft = 30.0;
    final chartRight = size.width - 8;
    const chartTop = 10.0;
    final chartBottom = size.height - 34;

    for (int i = 0; i < 5; i++) {
      final y = chartTop + ((chartBottom - chartTop) / 4) * i;
      canvas.drawLine(Offset(chartLeft, y), Offset(chartRight, y), gridPaint);
    }

    final labelStyle = GoogleFonts.manrope(
      fontSize: 10,
      fontWeight: FontWeight.w600,
      color: kOutline.withOpacity(0.70),
    );

    final yLabels = ['50k', '37k', '25k', '12k', '0'];
    for (int i = 0; i < yLabels.length; i++) {
      final y = chartTop + ((chartBottom - chartTop) / 4) * i - 7;
      _drawText(canvas, text: yLabels[i], offset: Offset(0, y), style: labelStyle);
    }

    final path = Path()
      ..moveTo(chartLeft, chartBottom)
      ..cubicTo(chartLeft + 45, chartBottom - 5, chartLeft + 90, chartBottom - 22, chartLeft + 130, chartBottom - 72)
      ..cubicTo(chartLeft + 175, chartBottom - 124, chartLeft + 210, chartBottom - 92, chartLeft + 250, chartBottom - 132)
      ..cubicTo(chartLeft + 290, chartTop - 4, chartLeft + 330, chartTop + 20, chartRight, chartTop + 10);

    final areaPath = Path.from(path)
      ..lineTo(chartRight, chartBottom)
      ..lineTo(chartLeft, chartBottom)
      ..close();

    canvas.drawPath(
      areaPath,
      Paint()
        ..shader = LinearGradient(
          colors: [kPrimary.withOpacity(0.16), kPrimary.withOpacity(0.00)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(Rect.fromLTRB(chartLeft, chartTop, chartRight, chartBottom)),
    );

    canvas.drawPath(
      path,
      Paint()
        ..color = kPrimary
        ..strokeWidth = 4
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    final marker = Offset(chartRight, chartTop + 10);
    canvas.drawCircle(marker, 10, Paint()..color = kPrimary.withOpacity(0.25));
    canvas.drawCircle(marker, 5, Paint()..color = kPrimary);

    final xLabels = {
      'Jan': chartLeft,
      'Mar': chartLeft + ((chartRight - chartLeft) * 0.33),
      'Mai': chartLeft + ((chartRight - chartLeft) * 0.66),
      'Jul': chartRight - 18,
    };

    xLabels.forEach((label, x) {
      _drawText(canvas, text: label, offset: Offset(x, size.height - 16), style: labelStyle);
    });
  }

  void _drawText(Canvas canvas, {required String text, required Offset offset, required TextStyle style}) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}