import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../data/mock_data.dart';

// ─── Colores de estado (badge) ────────────────────────────────────────────────
const _aprobadoBg = Color(0xFFE6F6EC);
const _aprobadoFg = Color(0xFF15803D);
const _aprobadoDot = Color(0xFF1B9E54);

const _revisionBg = Color(0xFFE4F0F5);
const _revisionFg = Color(0xFF1F6075);
const _revisionDot = Color(0xFF2E86AB);

const _rechazadoBg = Color(0xFFFBEAE6);
const _rechazadoFg = Color(0xFFB3402A);
const _rechazadoDot = Color(0xFFD9583C);

// Hover
const _hoverBorder = Color(0xFFBFE2CC);
const _hoverShadow = Color(0x0F102A1C);

// ─────────────────────────────────────────────────────────────────────────────

class CotizacionListaScreen extends StatelessWidget {
  const CotizacionListaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            radius: 1.2,
            colors: [
              AppColors.bgGradientStart,
              AppColors.bgGradientMid,
              AppColors.bgGradientEnd,
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 34),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Mis cotizaciones',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  height: 1.1,
                  letterSpacing: -0.52,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Historial de solicitudes y su estado de aprobación.',
                style: GoogleFonts.hankenGrotesk(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 26),
              for (int i = 0; i < mockCotizacionesLista.length; i++) ...[
                _CotizacionCard(mockCotizacionesLista[i]),
                if (i < mockCotizacionesLista.length - 1)
                  const SizedBox(height: 12),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Card con hover ───────────────────────────────────────────────────────────

class _CotizacionCard extends StatefulWidget {
  final CotizacionListaItem cotizacion;
  const _CotizacionCard(this.cotizacion);

  @override
  State<_CotizacionCard> createState() => _CotizacionCardState();
}

class _CotizacionCardState extends State<_CotizacionCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final c = widget.cotizacion;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _hovered ? _hoverBorder : AppColors.line,
            width: 1,
          ),
          boxShadow: _hovered
              ? const [
                  BoxShadow(
                    color: _hoverShadow,
                    blurRadius: 14,
                    offset: Offset(0, 4),
                  ),
                ]
              : const [],
        ),
        child: Row(
          children: [
            // Ícono documento
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.surfaceMint,
                borderRadius: BorderRadius.circular(11),
              ),
              child: Center(
                child: CustomPaint(
                  size: const Size(20, 20),
                  painter: const _DocIconPainter(),
                ),
              ),
            ),
            const SizedBox(width: 16),
            // ID + metadatos
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    c.id,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    c.meta,
                    style: GoogleFonts.hankenGrotesk(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textSubtle,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // Monto + badge
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  c.montoDisplay,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 7),
                _EstadoBadge(c.estado),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Badge de estado ──────────────────────────────────────────────────────────

class _EstadoBadge extends StatelessWidget {
  final EstadoCotizacion estado;
  const _EstadoBadge(this.estado);

  @override
  Widget build(BuildContext context) {
    final (Color bg, Color fg, Color dot, String label) = switch (estado) {
      EstadoCotizacion.aprobada => (_aprobadoBg, _aprobadoFg, _aprobadoDot, 'Aprobado'),
      EstadoCotizacion.enRevision => (_revisionBg, _revisionFg, _revisionDot, 'En revisión'),
      EstadoCotizacion.rechazada => (_rechazadoBg, _rechazadoFg, _rechazadoDot, 'Rechazado'),
      EstadoCotizacion.pendiente => (
          AppColors.pendienteBg,
          AppColors.pendienteText,
          AppColors.pendienteDot,
          'Pendiente',
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
          ),
          const SizedBox(width: 7),
          Text(
            label,
            style: GoogleFonts.hankenGrotesk(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Ícono documento (CustomPainter) ─────────────────────────────────────────

class _DocIconPainter extends CustomPainter {
  const _DocIconPainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 24, size.height / 24);

    final paint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.7
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Cuerpo del documento
    final doc = Path()
      ..moveTo(7, 3)
      ..lineTo(14, 3)
      ..lineTo(18, 7)
      ..lineTo(18, 20)
      ..arcToPoint(const Offset(17, 21), radius: const Radius.circular(1))
      ..lineTo(7, 21)
      ..arcToPoint(const Offset(6, 20), radius: const Radius.circular(1))
      ..lineTo(6, 4)
      ..arcToPoint(const Offset(7, 3), radius: const Radius.circular(1))
      ..close();

    // Doblez esquina superior derecha
    final fold = Path()
      ..moveTo(13, 3)
      ..lineTo(13, 8)
      ..lineTo(18, 8);

    canvas.drawPath(doc, paint);
    canvas.drawPath(fold, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
