import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_colors.dart';
import '../../../data/api_service.dart';

// ─── Colores puntuales ────────────────────────────────────────────────────────
const _cardBorder     = Color(0xFFE0EADF);
const _innerBorder    = Color(0xFFE3EFE6);
const _eyebrowColor   = Color(0xFF8A9C90);
const _labelColor     = Color(0xFF8A9C90);
const _dividerColor   = Color(0xFFEAF4ED);
const _signatureLabel = Color(0xFF3E4F44);
const _signatureMeta  = Color(0xFF9DB0A4);
const _signatureLine  = Color(0xFFCBD8CF);
const _downloadBorder = Color(0xFFBFE2CC);
const _downloadHover  = Color(0xFFF1FAF4);
// ─────────────────────────────────────────────────────────────────────────────

// ─── Modelo local ────────────────────────────────────────────────────────────

DateTime? _parseDate(dynamic v) {
  if (v == null) return null;
  try { return DateTime.parse(v.toString()); } catch (_) { return null; }
}

String _companyFromData(Map<String, dynamic> proj, Map<String, dynamic> cert) {
  // El certificado puede traer el nombre; si no, lo sacamos del proyecto
  final fromCert = cert['companyName']?.toString() ?? cert['company']?.toString();
  if (fromCert != null && fromCert.isNotEmpty) return fromCert;
  final comp = proj['company'];
  if (comp is Map) return comp['name']?.toString() ?? '—';
  return proj['companyName']?.toString() ?? proj['company']?.toString() ?? '—';
}

class _CertData {
  final String projectId;
  final String companyName;
  final String territory;
  final int arboles;
  final DateTime? fechaInicio;
  final DateTime? fechaFin;
  final String codigoCert;
  final String? pdfUrl;
  final String folio;

  const _CertData({
    required this.projectId,
    required this.companyName,
    required this.territory,
    required this.arboles,
    required this.fechaInicio,
    required this.fechaFin,
    required this.codigoCert,
    required this.pdfUrl,
    required this.folio,
  });

  factory _CertData.fromData(
    Map<String, dynamic> proj,
    Map<String, dynamic> cert,
  ) {
    final id = proj['id'].toString();
    return _CertData(
      projectId:   id,
      companyName: _companyFromData(proj, cert),
      territory:   cert['territory']?.toString() ??
                   proj['territory']?.toString() ?? '—',
      arboles:     (cert['trees'] as num?)?.toInt() ??
                   (proj['trees'] as num?)?.toInt() ??
                   (proj['numberOfTrees'] as num?)?.toInt() ?? 0,
      fechaInicio: _parseDate(cert['startDate'] ?? proj['startDate'] ?? proj['createdAt']),
      fechaFin:    _parseDate(cert['endDate'] ?? proj['endDate'] ?? proj['estimatedEndDate']),
      codigoCert:  cert['code']?.toString() ??
                   cert['certificateCode']?.toString() ??
                   cert['verificationCode']?.toString() ??
                   cert['id']?.toString() ?? '—',
      pdfUrl:      cert['pdfUrl']?.toString() ??
                   cert['url']?.toString() ??
                   cert['pdf']?.toString(),
      folio:       cert['folio']?.toString() ??
                   'GN-${DateTime.now().year}-${cert['id']?.toString().padLeft(4,'0') ?? '0000'}',
    );
  }

  double get co2 => arboles * 0.022;
  String get co2Label => '${co2.toStringAsFixed(1)} ton';

  String get periodo {
    if (fechaInicio == null) return '—';
    final ini = fechaInicio!.year.toString();
    final fin = fechaFin != null ? fechaFin!.year.toString() : '—';
    return '$ini – $fin';
  }
}

// ─── Pantalla ─────────────────────────────────────────────────────────────────

class CertificadoScreen extends StatefulWidget {
  const CertificadoScreen({super.key});

  @override
  State<CertificadoScreen> createState() => _CertificadoScreenState();
}

class _CertificadoScreenState extends State<CertificadoScreen> {
  bool _loading     = true;
  String? _error;
  bool _isCompleted = false;
  _CertData? _cert;
  String? _projectId;
  bool _downloading = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final proyectos = await apiService.getProyectos();
      if (proyectos.isEmpty) {
        setState(() { _loading = false; _isCompleted = false; });
        return;
      }

      final proj       = proyectos.first as Map<String, dynamic>;
      final projectId  = proj['id'].toString();
      final status     = (proj['status']?.toString() ?? '').toLowerCase();
      _projectId       = projectId;
      _isCompleted     = status == 'completed';

      if (_isCompleted) {
        final certRaw = await apiService.getCertificado(projectId);
        _cert = _CertData.fromData(proj, certRaw);
      } else {
        _cert = null;
      }

      setState(() { _loading = false; });
    } catch (e) {
      setState(() {
        _error   = e.toString().replaceFirst('Exception: ', '');
        _loading = false;
      });
    }
  }

  Future<void> _download() async {
    if (_projectId == null) return;
    setState(() => _downloading = true);
    try {
      final raw    = await apiService.getCertificado(_projectId!);
      final pdfUrl = raw['pdfUrl']?.toString() ??
                     raw['url']?.toString() ??
                     raw['pdf']?.toString();

      if (pdfUrl != null && pdfUrl.isNotEmpty) {
        await launchUrl(Uri.parse(pdfUrl), mode: LaunchMode.externalApplication);
      } else {
        _snackBar('El certificado está siendo generado');
      }
    } catch (_) {
      _snackBar('El certificado está siendo generado');
    } finally {
      if (mounted) setState(() => _downloading = false);
    }
  }

  void _snackBar(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          msg,
          style: GoogleFonts.hankenGrotesk(fontSize: 14),
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: AppColors.bgPage,
        body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }
    if (_error != null) {
      return Scaffold(
        backgroundColor: AppColors.bgPage,
        body: _ErrorState(error: _error!, onRetry: _load),
      );
    }
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _PageHeader(
              onDownload:  _isCompleted ? _download : null,
              downloading: _downloading,
            ),
            const SizedBox(height: 18),
            if (!_isCompleted || _cert == null)
              const _LockedState()
            else
              _CertificateCard(cert: _cert!),
          ],
        ),
      ),
    );
  }
}

// ─── Cabecera de página ───────────────────────────────────────────────────────

class _PageHeader extends StatelessWidget {
  final VoidCallback? onDownload;
  final bool downloading;
  const _PageHeader({this.onDownload, required this.downloading});

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
        if (onDownload != null) ...[
          const SizedBox(width: 16),
          _DownloadButton(onTap: onDownload!, downloading: downloading),
        ],
      ],
    );
  }
}

class _DownloadButton extends StatefulWidget {
  final VoidCallback onTap;
  final bool downloading;
  const _DownloadButton({required this.onTap, required this.downloading});

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
      onExit:  (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.downloading ? null : widget.onTap,
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
              widget.downloading
                  ? const SizedBox(
                      width: 16, height: 16,
                      child: CircularProgressIndicator(
                        color: AppColors.primary, strokeWidth: 2,
                      ),
                    )
                  : CustomPaint(
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

// ─── Estado bloqueado ─────────────────────────────────────────────────────────

class _LockedState extends StatelessWidget {
  const _LockedState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 80),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80, height: 80,
              decoration: const BoxDecoration(
                color: AppColors.surfaceMint,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.lock_outline, size: 36, color: AppColors.primary),
            ),
            const SizedBox(height: 20),
            Text(
              'Certificado no disponible',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'El certificado estará disponible cuando\ntu proyecto esté completado',
              style: GoogleFonts.hankenGrotesk(
                fontSize: 14,
                color: AppColors.textMuted,
                height: 1.55,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Tarjeta certificado ──────────────────────────────────────────────────────

class _CertificateCard extends StatelessWidget {
  final _CertData cert;
  const _CertificateCard({required this.cert});

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
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 38),
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
                    Text(
                      cert.companyName,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.24,
                        color: AppColors.ink,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
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
                    _DataGrid(cert: cert),
                    const SizedBox(height: 26),
                    _CertificateFooter(
                      folio: cert.folio,
                      codigoCert: cert.codigoCert,
                    ),
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
  final _CertData cert;
  const _DataGrid({required this.cert});

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
            left: _DataCell(
              label: 'Árboles sembrados',
              value: '${cert.arboles}',
            ),
            right: _DataCell(
              label: 'CO₂ estimado',
              value: cert.co2Label,
              valueColor: AppColors.primary,
            ),
          ),
          Container(height: 1, color: _dividerColor),
          _DataCell(
            label: 'Territorio',
            value: cert.territory,
          ),
          Container(height: 1, color: _dividerColor),
          _GridRow(
            left: _DataCell(
              label: 'Período',
              value: cert.periodo,
            ),
            right: _DataCell(
              label: 'Código de verificación',
              value: cert.codigoCert,
            ),
          ),
        ],
      ),
    );
  }
}

/// Fila de 2 celdas con divisor vertical.
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
        SizedBox(
          width: 1,
          height: 62,
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
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ─── Pie del certificado ──────────────────────────────────────────────────────

class _CertificateFooter extends StatelessWidget {
  final String folio;
  final String codigoCert;
  const _CertificateFooter({required this.folio, required this.codigoCert});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
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
              folio,
              style: GoogleFonts.hankenGrotesk(
                fontSize: 11,
                fontWeight: FontWeight.w400,
                color: _signatureMeta,
              ),
            ),
          ],
        ),
        const Spacer(),
        // Sello circular
        Container(
          width: 60, height: 60,
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

// ─── Estado de error ──────────────────────────────────────────────────────────

class _ErrorState extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;
  const _ErrorState({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 40, color: AppColors.textMuted),
            const SizedBox(height: 16),
            Text(
              error,
              style: GoogleFonts.hankenGrotesk(fontSize: 14, color: AppColors.textMuted),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: onRetry,
              child: Text(
                'Reintentar',
                style: GoogleFonts.hankenGrotesk(
                  fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── CustomPainters ───────────────────────────────────────────────────────────

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
      path
        ..moveTo(16, 5)
        ..cubicTo(10, 10, 8, 14, 8, 19)
        ..arcToPoint(const Offset(24, 19), radius: const Radius.circular(8), clockwise: false)
        ..relativeCubicTo(0, -5, -2, -9, -8, -14)
        ..close();
    } else {
      path
        ..moveTo(16, 3)
        ..cubicTo(9, 9, 6, 14, 6, 20)
        ..arcToPoint(const Offset(26, 20), radius: const Radius.circular(10), clockwise: false)
        ..relativeCubicTo(0, -6, -3, -11, -10, -17)
        ..close();
    }

    canvas.drawPath(path, fill);
  }

  @override
  bool shouldRepaint(_LeafLogoPainter old) =>
      old.sealVariant != sealVariant || old.size != size;
}

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

    canvas.drawLine(const Offset(12, 3), const Offset(12, 15), paint);
    final arrow = Path()
      ..moveTo(7, 11)
      ..lineTo(12, 15)
      ..lineTo(17, 11);
    canvas.drawPath(arrow, paint);
    canvas.drawLine(const Offset(5, 21), const Offset(19, 21), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
