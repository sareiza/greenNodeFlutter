import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../data/mock_data.dart';

// ─── Colores por estado de evidencia ────────────────────────────────────────
// Aprobado / Validada por IA
const _aprobadoBg = Color(0xFFE6F6EC);
const _aprobadoFg = Color(0xFF15803D);
const _aprobadoDot = Color(0xFF1B9E54);

// Pendiente
const _pendienteBg = Color(0xFFFEF5DC);
const _pendienteFg = Color(0xFF8A6516);
const _pendienteDot = Color(0xFFE0A82E);

// Rechazado / Rechazada
const _rechazadoBg = Color(0xFFFBEAE6);
const _rechazadoFg = Color(0xFFB3402A);
const _rechazadoDot = Color(0xFFD9583C);

// Chip de especie por estado de detección
const _speciesOkBg = Color(0xFFEFF7F1);
const _speciesOkFg = Color(0xFF15803D);
const _speciesPendingBg = Color(0xFFFBF3E0);
const _speciesPendingFg = Color(0xFF8A6516);
const _speciesNoneBg = Color(0xFFF1EEEC);
const _speciesNoneFg = Color(0xFF8A7C6F);
// ────────────────────────────────────────────────────────────────────────────

/// Widget de galería completo (título + grid). Puede usarse embebido
/// en una shell con rail o de forma independiente via [EvidenciaGaleriaScreen].
class EvidenciaGaleria extends StatelessWidget {
  const EvidenciaGaleria({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Galería de evidencias',
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
          'Cada foto se valida automáticamente por IA, que además detecta la especie.',
          style: GoogleFonts.hankenGrotesk(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: AppColors.textMuted,
          ),
        ),
        const SizedBox(height: 24),
        // Grid 2 columnas
        LayoutBuilder(
          builder: (context, constraints) {
            const gap = 16.0;
            final colW = (constraints.maxWidth - gap) / 2;
            return Wrap(
              spacing: gap,
              runSpacing: gap,
              children: [
                for (final e in mockEvidencias)
                  SizedBox(width: colW, child: _EvidenciaCard(e)),
              ],
            );
          },
        ),
      ],
    );
  }
}

/// Pantalla independiente que envuelve [EvidenciaGaleria] con Scaffold y
/// el degradado estándar de la app, para navegación directa.
class EvidenciaGaleriaScreen extends StatelessWidget {
  const EvidenciaGaleriaScreen({super.key});

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
        child: const SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 40, vertical: 34),
          child: EvidenciaGaleria(),
        ),
      ),
    );
  }
}

// ─── Tarjeta individual ──────────────────────────────────────────────────────

class _EvidenciaCard extends StatelessWidget {
  final EvidenciaItem evidencia;
  const _EvidenciaCard(this.evidencia);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.line, width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D102A1C),
            blurRadius: 14,
            offset: Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Foto con badge superpuesto
          Stack(
            children: [
              _PhotoPlaceholder(estado: evidencia.estado),
              Positioned(
                top: 9,
                left: 9,
                child: _BadgeEstado(evidencia.estado),
              ),
            ],
          ),
          // Caption + chip + texto IA
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  evidencia.caption,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 9),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: _SpeciesChip(
                        especie: evidencia.especie,
                        estadoEspecie: evidencia.estadoEspecie,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _AiText(
                      texto: evidencia.aiTexto,
                      estado: evidencia.estado,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Foto placeholder ────────────────────────────────────────────────────────

class _PhotoPlaceholder extends StatelessWidget {
  final EstadoEvidencia estado;
  const _PhotoPlaceholder({required this.estado});

  @override
  Widget build(BuildContext context) {
    // Tinte sutil según estado para diferenciar las fotos visualmente
    final Color tint = switch (estado) {
      EstadoEvidencia.aprobado => const Color(0xFFEBF5EE),
      EstadoEvidencia.pendiente => const Color(0xFFF8F3E6),
      EstadoEvidencia.rechazado => const Color(0xFFF8EDEB),
    };

    return Container(
      height: 130,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [tint, AppColors.line],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.photo_camera_outlined,
              color: AppColors.placeholder,
              size: 28,
            ),
            const SizedBox(height: 5),
            Text(
              'Foto de evidencia',
              style: GoogleFonts.hankenGrotesk(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppColors.placeholder,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Badge de estado superpuesto ─────────────────────────────────────────────

class _BadgeEstado extends StatelessWidget {
  final EstadoEvidencia estado;
  const _BadgeEstado(this.estado);

  @override
  Widget build(BuildContext context) {
    final (Color bg, Color fg, Color dot, String label) = switch (estado) {
      EstadoEvidencia.aprobado => (
          _aprobadoBg,
          _aprobadoFg,
          _aprobadoDot,
          'Validada por IA',
        ),
      EstadoEvidencia.pendiente => (
          _pendienteBg,
          _pendienteFg,
          _pendienteDot,
          'Pendiente',
        ),
      EstadoEvidencia.rechazado => (
          _rechazadoBg,
          _rechazadoFg,
          _rechazadoDot,
          'Rechazada',
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.hankenGrotesk(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Chip de especie detectada ───────────────────────────────────────────────

class _SpeciesChip extends StatelessWidget {
  final String especie;
  final EstadoEspecieDeteccion estadoEspecie;

  const _SpeciesChip({required this.especie, required this.estadoEspecie});

  @override
  Widget build(BuildContext context) {
    final (Color bg, Color fg) = switch (estadoEspecie) {
      EstadoEspecieDeteccion.ok => (_speciesOkBg, _speciesOkFg),
      EstadoEspecieDeteccion.pending => (_speciesPendingBg, _speciesPendingFg),
      EstadoEspecieDeteccion.none => (_speciesNoneBg, _speciesNoneFg),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomPaint(
            size: const Size(13, 13),
            painter: _LeafPainter(color: fg),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              especie,
              style: GoogleFonts.hankenGrotesk(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: fg,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Texto de validación IA ───────────────────────────────────────────────────

class _AiText extends StatelessWidget {
  final String texto;
  final EstadoEvidencia estado;

  const _AiText({required this.texto, required this.estado});

  @override
  Widget build(BuildContext context) {
    final Color fg = switch (estado) {
      EstadoEvidencia.aprobado => _aprobadoFg,
      EstadoEvidencia.pendiente => _pendienteFg,
      EstadoEvidencia.rechazado => _rechazadoFg,
    };

    return Text(
      texto,
      style: GoogleFonts.hankenGrotesk(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: fg,
      ),
    );
  }
}

// ─── Hoja SVG (CustomPainter) ─────────────────────────────────────────────────
//
// SVG original del diseño (viewBox 0 0 24 24):
//   path d="M11 20A7 7 0 0 1 4 13c0-5 4-9 11-9 0 6-3 10-8 11"
//   path d="M4 20c2-4 5-6 9-7"

class _LeafPainter extends CustomPainter {
  final Color color;
  const _LeafPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 24, size.height / 24);

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Hoja principal: M11 20 A7 7 0 0 1 4 13 c0-5 4-9 11-9 0 6-3 10-8 11
    final leaf = Path()
      ..moveTo(11, 20)
      ..arcToPoint(
        const Offset(4, 13),
        radius: const Radius.circular(7),
        clockwise: true,
      )
      ..relativeCubicTo(0, -5, 4, -9, 11, -9)
      ..relativeCubicTo(0, 6, -3, 10, -8, 11);

    // Tallo: M4 20 c2-4 5-6 9-7
    final stem = Path()
      ..moveTo(4, 20)
      ..relativeCubicTo(2, -4, 5, -6, 9, -7);

    canvas.drawPath(leaf, paint);
    canvas.drawPath(stem, paint);
  }

  @override
  bool shouldRepaint(_LeafPainter old) => old.color != color;
}
