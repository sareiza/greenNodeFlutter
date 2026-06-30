import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_colors.dart';

/// Logo "hoja + GreenNode" reutilizado en el rail y en las pantallas de
/// autenticación (login/registro), antes de "entrar" a la app.
class GreenNodeLogo extends StatelessWidget {
  final double size;
  final Color leafColor;
  final Color textColor;

  const GreenNodeLogo({
    super.key,
    this.size = 26,
    this.leafColor = AppColors.primary,
    this.textColor = AppColors.ink,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomPaint(
          size: Size.square(size),
          painter: _LeafPainter(color: leafColor),
        ),
        const SizedBox(width: 10),
        Text(
          'GreenNode',
          style: GoogleFonts.plusJakartaSans(
            fontSize: size * 0.75,
            fontWeight: FontWeight.w800,
            color: textColor,
          ),
        ),
      ],
    );
  }
}

/// Hoja (viewBox 0 0 32 32) — misma forma que el logo del rail.
class _LeafPainter extends CustomPainter {
  final Color color;
  const _LeafPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 32, size.height / 32);

    final fill = Paint()..color = color;
    final path = Path()
      ..moveTo(16, 3)
      ..cubicTo(9, 9, 6, 14, 6, 20)
      ..arcToPoint(
        const Offset(26, 20),
        radius: const Radius.circular(10),
        clockwise: false,
      )
      ..relativeCubicTo(0, -6, -3, -11, -10, -17)
      ..close();

    canvas.drawPath(path, fill);
  }

  @override
  bool shouldRepaint(covariant _LeafPainter oldDelegate) =>
      oldDelegate.color != color;
}
