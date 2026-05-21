// Autor: Alinne Monteiro de Melo
// RA: 24801649

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../utils/app_colors.dart';
import '../service/dashboard_service.dart';

class PortfolioChart extends StatelessWidget {
  final List<TokenPricePoint> points;

  const PortfolioChart({super.key, required this.points});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _PortfolioChartPainter(points: points),
      child: const SizedBox.expand(),
    );
  }
}

class _PortfolioChartPainter extends CustomPainter {
  final List<TokenPricePoint> points;

  _PortfolioChartPainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    const chartLeft = 30.0;
    final chartRight = size.width - 8;
    const chartTop = 10.0;
    final chartBottom = size.height - 34;

    final prices = points.map((p) => p.priceCents.toDouble()).toList();
    final minPrice = prices.reduce((a, b) => a < b ? a : b);
    final maxPrice = prices.reduce((a, b) => a > b ? a : b);
    final priceRange = (maxPrice - minPrice).clamp(1.0, double.infinity);

    final gridPaint = Paint()
      ..color = const Color(0xFFC4C5D7).withOpacity(0.22)
      ..strokeWidth = 1;

    for (int i = 0; i < 5; i++) {
      final y = chartTop + ((chartBottom - chartTop) / 4) * i;
      canvas.drawLine(Offset(chartLeft, y), Offset(chartRight, y), gridPaint);
    }

    final labelStyle = GoogleFonts.manrope(
      fontSize: 10,
      fontWeight: FontWeight.w600,
      color: kOutline.withOpacity(0.70),
    );

    for (int i = 0; i < 5; i++) {
      final value = maxPrice - (priceRange / 4) * i;
      final label = value >= 100000
          ? '${(value / 100000).toStringAsFixed(0)}k'
          : 'R\$${(value / 100).toStringAsFixed(0)}';
      final y = chartTop + ((chartBottom - chartTop) / 4) * i - 7;
      _drawText(canvas, text: label, offset: Offset(0, y), style: labelStyle);
    }

    final xStep = (chartRight - chartLeft) / (points.length - 1).clamp(1, 999);

    double toY(double price) =>
        chartBottom - ((price - minPrice) / priceRange) * (chartBottom - chartTop);

    final path = Path();
    for (int i = 0; i < points.length; i++) {
      final x = chartLeft + xStep * i;
      final y = toY(prices[i]);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        final prevX = chartLeft + xStep * (i - 1);
        final prevY = toY(prices[i - 1]);
        final cpX = (prevX + x) / 2;
        path.cubicTo(cpX, prevY, cpX, y, x, y);
      }
    }

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

    final lastX = chartLeft + xStep * (points.length - 1);
    final lastY = toY(prices.last);
    canvas.drawCircle(Offset(lastX, lastY), 10, Paint()..color = kPrimary.withOpacity(0.25));
    canvas.drawCircle(Offset(lastX, lastY), 5, Paint()..color = kPrimary);

    final indices = {
      0,
      points.length ~/ 3,
      (points.length * 2) ~/ 3,
      points.length - 1,
    };
    for (final i in indices) {
      final x = chartLeft + xStep * i;
      final date = points[i].criadoEm;
      final label = '${date.day}/${date.month}';
      _drawText(canvas, text: label, offset: Offset(x - 10, size.height - 16), style: labelStyle);
    }
  }

  void _drawText(Canvas canvas, {required String text, required Offset offset, required TextStyle style}) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant _PortfolioChartPainter old) => old.points != points;
}