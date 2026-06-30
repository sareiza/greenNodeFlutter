import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';

// ─── Colores puntuales ────────────────────────────────────────────────────────
const _cardBorder = Color(0xFFE0EADF);
const _innerBorder = Color(0xFFE3EFE6);
const _eyebrowColor = Color(0xFF8A9C90);
const _labelColor = Color(0xFF8A9C90);
const _dividerColor = Color(0xFFEAF4ED);
const _signatureLabel = Color(0xFF3E4F44);
const _signatureMeta = Color(0xFF9DB0A4);
const _signatureLine = Color(0xFFCBD8CF);
const _downloadBorder = Color(0xFFBFE2CC);
const _downloadHover = Color(0xFFF1FAF4);
// ─────────────────────────────────────────────────────────────────────────────

class CertificadoScreen extends StatelessWidget {
  const CertificadoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            _PageHeader(),
            SizedBox(height: 18),
            _CertificateCard(),
          ],
        ),
      ),
    );
  }
}

// ─── Cabecera de página ───────────────────────────────────────────────────────

class _PageHeader extends StatelessWidget {
  const _PageHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Certificado',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  height: 1.1,
                  letterSpacing: -0.52,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Vista previa — se emite al completar el Mes 24.',
                style: GoogleFonts.hankenGrotesk(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        const _DownloadButton(),
      ],
    );
  }
}

class _DownloadButton extends StatefulWidget {
  const _DownloadButton();

  @override
  State<_DownloadButton> createState() => _DownloadButtonState();
}

class _DownloadButtonState extends State<_DownloadButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: () {},
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
          decoration: BoxDecoration(
            color: _hovered ? _downloadHover : Colors.white,
            border: Border.all(color: _downloadBorder, width: 1.5),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomPaint(
                size: const Size(16, 16),
                painter: const _DownloadIconPainter(),
              ),
              const SizedBox(width: 8),
              Text(
                'Descargar PDF',
                style: GoogleFonts.hankenGrotesk(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Tarjeta certificado ──────────────────────────────────────────────────────

class _CertificateCard extends StatelessWidget {
  const _CertificateCard();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: _cardBorder, width: 1),
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1F102A1C),
                blurRadius: 40,
                offset: Offset(0, 16),
              ),
            ],
          ),
          clipBehavior: Clip.hardEdge,
          child: Stack(
            children: [
              // Marco interior decorativo
              Positioned.fill(
                child: IgnorePointer(
                  child: Container(
                    margin: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      border: Border.all(color: _innerBorder, width: 1.5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              // Marca de agua diagonal
              Positioned.fill(
                child: IgnorePointer(
                  child: Center(
                    child: Transform.rotate(
                      angle: -24 * math.pi / 180,
                      child: Opacity(
                        opacity: 0.06,
                        child: Text(
                          'VISTA PREVIA',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 58,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                            letterSpacing: 58 * 0.04,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // Contenido
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 38,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Logo GreenNode
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomPaint(
                          size: const Size(26, 26),
                          painter: const _LeafLogoPainter(size: 32),
                        ),
                        const SizedBox(width: 9),
                        Text(
                          'GreenNode',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.ink,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    // Eyebrow
                    Text(
                      'CERTIFICADO DE REFORESTACIÓN',
                      style: GoogleFonts.hankenGrotesk(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 12 * 0.16,
                        color: _eyebrowColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Empresa
                    Text(
                      'Constructora Verde S.A.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.24,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Descripción
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 400),
                      child: Text(
                        'ha contribuido a la restauración ecológica del territorio '
                        'mediante la siembra y el monitoreo verificado de su bosque '
                        'corporativo.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.hankenGrotesk(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          height: 1.6,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Grid de datos
                    const _DataGrid(),
                    const SizedBox(height: 26),
                    // Pie: firma + sello
                    const _CertificateFooter(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Grid de datos ────────────────────────────────────────────────────────────

class _DataGrid extends StatelessWidget {
  const _DataGrid();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: _dividerColor, width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        children: [
          _GridRow(
            left: const _DataCell(label: 'Empleados', value: '50'),
            right: const _DataCell(label: 'Árboles plantados', value: '100'),
          ),
          Container(height: 1, color: _dividerColor),
          const _DataCell(
            label: 'Territorio',
            value: 'Área de Vida Medellín Norte',
          ),
          Container(height: 1, color: _dividerColor),
          _GridRow(
            left: const _DataCell(
              label: 'CO₂ estimado',
              value: '2.5 ton',
              valueColor: AppColors.primary,
            ),
            right: const _DataCell(label: 'Período', value: '2024 – 2026'),
          ),
        ],
      ),
    );
  }
}

/// Fila de 2 celdas con divisor vertical. Usa un Stack en lugar de
/// IntrinsicHeight para evitar el overflow de 1 px por redondeo.
class _GridRow extends StatelessWidget {
  final Widget left;
  final Widget right;

  const _GridRow({required this.left, required this.right});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: left),
        // Divisor que se estira usando un Stack con Positioned.fill
        SizedBox(
          width: 1,
          height: 62, // altura fija = padding(13×2) + label(12) + gap(3) + value(21)
          child: ColoredBox(color: _dividerColor),
        ),
        Expanded(child: right),
      ],
    );
  }
}

class _DataCell extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _DataCell({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: GoogleFonts.hankenGrotesk(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              letterSpacing: 10 * 0.06,
              color: _labelColor,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: valueColor ?? AppColors.ink,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Pie del certificado ──────────────────────────────────────────────────────

class _CertificateFooter extends StatelessWidget {
  const _CertificateFooter();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Firma
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 140,
              height: 1.5,
              color: _signatureLine,
              margin: const EdgeInsets.only(bottom: 7),
            ),
            Text(
              'Dirección GreenNode',
              style: GoogleFonts.hankenGrotesk(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _signatureLabel,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Folio GN-2026-0142',
              style: GoogleFonts.hankenGrotesk(
                fontSize: 11,
                fontWeight: FontWeight.w400,
                color: _signatureMeta,
              ),
            ),
          ],
        ),
        const Spacer(),
        // Sello circular con hoja
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.leaf, width: 2),
          ),
          child: Center(
            child: CustomPaint(
              size: const Size(26, 26),
              painter: const _LeafLogoPainter(size: 32, sealVariant: true),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── CustomPainters ───────────────────────────────────────────────────────────

/// Hoja del logo/sello GreenNode (viewBox 0 0 32 32).
/// [size] = lado del viewBox (32).
/// [sealVariant] usa la variante más pequeña del sello.
class _LeafLogoPainter extends CustomPainter {
  final double size;
  final bool sealVariant;

  const _LeafLogoPainter({required this.size, this.sealVariant = false});

  @override
  void paint(Canvas canvas, Size canvasSize) {
    canvas.scale(canvasSize.width / size, canvasSize.height / size);

    final fill = Paint()..color = AppColors.leaf;

    final path = Path();
    if (sealVariant) {
      // "M16 5C10 10 8 14 8 19a8 8 0 0 0 16 0c0-5-2-9-8-14Z"
      path
        ..moveTo(16, 5)
        ..cubicTo(10, 10, 8, 14, 8, 19)
        ..arcToPoint(
          const Offset(24, 19),
          radius: const Radius.circular(8),
          clockwise: false,
        )
        ..relativeCubicTo(0, -5, -2, -9, -8, -14)
        ..close();
    } else {
      // "M16 3C9 9 6 14 6 20a10 10 0 0 0 20 0c0-6-3-11-10-17Z"
      path
        ..moveTo(16, 3)
        ..cubicTo(9, 9, 6, 14, 6, 20)
        ..arcToPoint(
          const Offset(26, 20),
          radius: const Radius.circular(10),
          clockwise: false,
        )
        ..relativeCubicTo(0, -6, -3, -11, -10, -17)
        ..close();
    }

    canvas.drawPath(path, fill);
  }

  @override
  bool shouldRepaint(_LeafLogoPainter old) =>
      old.sealVariant != sealVariant || old.size != size;
}

/// Ícono de descarga (viewBox 0 0 24 24, stroke).
/// Paths: "M12 3v12", "M7 11l5 4 5-4", "M5 21h14"
class _DownloadIconPainter extends CustomPainter {
  const _DownloadIconPainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 24, size.height / 24);

    final paint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Línea vertical
    canvas.drawLine(const Offset(12, 3), const Offset(12, 15), paint);
    // Flecha ↓
    final arrow = Path()
      ..moveTo(7, 11)
      ..lineTo(12, 15)
      ..lineTo(17, 11);
    canvas.drawPath(arrow, paint);
    // Base
    canvas.drawLine(const Offset(5, 21), const Offset(19, 21), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
