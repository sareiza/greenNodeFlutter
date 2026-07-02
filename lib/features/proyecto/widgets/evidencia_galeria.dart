import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../data/api_service.dart';

// ─── Colores por estado de evidencia ────────────────────────────────────────
const _aprobadoBg  = Color(0xFFE6F6EC);
const _aprobadoFg  = Color(0xFF15803D);
const _aprobadoDot = Color(0xFF1B9E54);

const _pendienteBg  = Color(0xFFFEF5DC);
const _pendienteFg  = Color(0xFF8A6516);
const _pendienteDot = Color(0xFFE0A82E);

const _rechazadoBg  = Color(0xFFFBEAE6);
const _rechazadoFg  = Color(0xFFB3402A);
const _rechazadoDot = Color(0xFFD9583C);

const _speciesOkBg      = Color(0xFFEFF7F1);
const _speciesOkFg      = Color(0xFF15803D);
const _speciesPendingBg = Color(0xFFFBF3E0);
const _speciesPendingFg = Color(0xFF8A6516);
const _speciesNoneBg    = Color(0xFFF1EEEC);
const _speciesNoneFg    = Color(0xFF8A7C6F);
// ────────────────────────────────────────────────────────────────────────────

// ─── Modelo local ────────────────────────────────────────────────────────────

class _EvidenciaReal {
  final String id;
  final String url;
  final String estadoIa;
  final int? arbolesDetectados;
  final String? especie;
  final String? aiResultado;
  final String fecha;

  const _EvidenciaReal({
    required this.id,
    required this.url,
    required this.estadoIa,
    required this.arbolesDetectados,
    required this.especie,
    required this.aiResultado,
    required this.fecha,
  });

  factory _EvidenciaReal.fromJson(Map<String, dynamic> j) {
    final validated = j['aiValidated'] as bool? ?? false;
    final estado = validated ? 'validated'
        : (j['aiStatus']?.toString() ?? j['status']?.toString() ?? 'pending').toLowerCase();
    return _EvidenciaReal(
      id:               j['id']?.toString() ?? '',
      url:              j['photoUrl']?.toString() ?? j['imageUrl']?.toString() ??
                        j['fileUrl']?.toString()  ?? j['url']?.toString() ?? '',
      estadoIa:         estado,
      arbolesDetectados:(j['aiEstimatedTrees'] as num?)?.toInt() ??
                        (j['treesDetected'] as num?)?.toInt(),
      especie:          j['species']?.toString() ?? j['detectedSpecies']?.toString(),
      aiResultado:      j['aiObservations']?.toString() ?? j['aiResult']?.toString() ??
                        j['aiAnalysis']?.toString(),
      fecha:            j['createdAt']?.toString() ?? '',
    );
  }

  bool get esValidado =>
      estadoIa == 'validated' || estadoIa == 'approved' ||
      estadoIa == 'validado'  || estadoIa == 'aprobado';

  bool get esRechazado =>
      estadoIa == 'rejected' || estadoIa == 'rechazado';

  String get fechaFmt {
    if (fecha.isEmpty) return '—';
    try {
      final d = DateTime.parse(fecha);
      const m = ['ene','feb','mar','abr','may','jun','jul','ago','sep','oct','nov','dic'];
      return '${d.day} ${m[d.month - 1]} ${d.year}';
    } catch (_) {
      return fecha.substring(0, fecha.length.clamp(0, 10));
    }
  }
}

// ─── Widget principal (con carga propia) ─────────────────────────────────────

class EvidenciaGaleria extends StatefulWidget {
  const EvidenciaGaleria({super.key});

  @override
  State<EvidenciaGaleria> createState() => _EvidenciaGaleriaState();
}

class _EvidenciaGaleriaState extends State<EvidenciaGaleria> {
  bool _loading = true;
  String? _error;
  List<_EvidenciaReal> _evidencias = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      // Obtiene el primer proyecto para extraer su ID
      final proyectos = await apiService.getProyectos();
      if (proyectos.isEmpty) {
        setState(() { _evidencias = []; _loading = false; });
        return;
      }
      final projectId = (proyectos.first as Map<String, dynamic>)['id'].toString();

      final raw = await apiService.getEvidencias(projectId);
      setState(() {
        _evidencias = raw
            .map((e) => _EvidenciaReal.fromJson(e as Map<String, dynamic>))
            .toList();
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _loading = false;
      });
    }
  }

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
        if (_loading)
          const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 48),
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          )
        else if (_error != null)
          _ErrorState(error: _error!, onRetry: _load)
        else if (_evidencias.isEmpty)
          const _EmptyState()
        else
          LayoutBuilder(
            builder: (context, constraints) {
              const gap = 16.0;
              final colW = (constraints.maxWidth - gap) / 2;
              return Wrap(
                spacing: gap,
                runSpacing: gap,
                children: [
                  for (final e in _evidencias)
                    SizedBox(
                      width: colW,
                      child: _EvidenciaCard(
                        ev: e,
                        onTap: () => _openDetalle(context, e),
                      ),
                    ),
                ],
              );
            },
          ),
      ],
    );
  }

  void _openDetalle(BuildContext context, _EvidenciaReal ev) {
    showDialog(
      context: context,
      builder: (_) => _DetalleDialog(ev: ev),
    );
  }
}

// ─── Pantalla independiente ───────────────────────────────────────────────────

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
  final _EvidenciaReal ev;
  final VoidCallback onTap;
  const _EvidenciaCard({required this.ev, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.line, width: 1),
          boxShadow: const [
            BoxShadow(color: Color(0x0D102A1C), blurRadius: 14, offset: Offset(0, 4)),
          ],
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                _PhotoWidget(url: ev.url),
                Positioned(
                  top: 9,
                  left: 9,
                  child: _BadgeEstado(estadoIa: ev.estadoIa),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ev.fechaFmt,
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
                          especie: ev.especie,
                          esValidado: ev.esValidado,
                          esRechazado: ev.esRechazado,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _AiText(
                        arboles: ev.arbolesDetectados,
                        esValidado: ev.esValidado,
                        esRechazado: ev.esRechazado,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Foto con red + fallback ──────────────────────────────────────────────────

class _PhotoWidget extends StatelessWidget {
  final String url;
  const _PhotoWidget({required this.url});

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) return const _GreenPlaceholder();
    return Image.network(
      url,
      height: 130,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => const _GreenPlaceholder(),
      loadingBuilder: (_, child, progress) {
        if (progress == null) return child;
        return Container(
          height: 130,
          color: AppColors.surfaceMint,
          child: const Center(
            child: CircularProgressIndicator(
              color: AppColors.primary,
              strokeWidth: 2,
            ),
          ),
        );
      },
    );
  }
}

class _GreenPlaceholder extends StatelessWidget {
  const _GreenPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 130,
      color: AppColors.surfaceMint,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.park_outlined, color: AppColors.primary, size: 28),
            const SizedBox(height: 5),
            Text(
              'Sin imagen',
              style: GoogleFonts.hankenGrotesk(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppColors.textMuted,
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
  final String estadoIa;
  const _BadgeEstado({required this.estadoIa});

  (Color bg, Color fg, Color dot, String label) _config() {
    if (estadoIa == 'validated' || estadoIa == 'approved' ||
        estadoIa == 'validado'  || estadoIa == 'aprobado') {
      return (_aprobadoBg, _aprobadoFg, _aprobadoDot, 'Validado IA');
    }
    if (estadoIa == 'rejected' || estadoIa == 'rechazado') {
      return (_rechazadoBg, _rechazadoFg, _rechazadoDot, 'Rechazado');
    }
    return (_pendienteBg, _pendienteFg, _pendienteDot, 'Pendiente');
  }

  @override
  Widget build(BuildContext context) {
    final (bg, fg, dot, label) = _config();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6, height: 6,
            decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.hankenGrotesk(
              fontSize: 11, fontWeight: FontWeight.w600, color: fg,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Chip de especie detectada ───────────────────────────────────────────────

class _SpeciesChip extends StatelessWidget {
  final String? especie;
  final bool esValidado;
  final bool esRechazado;

  const _SpeciesChip({
    required this.especie,
    required this.esValidado,
    required this.esRechazado,
  });

  @override
  Widget build(BuildContext context) {
    final Color bg;
    final Color fg;
    final String label;

    if (especie != null && especie!.isNotEmpty) {
      bg    = _speciesOkBg;
      fg    = _speciesOkFg;
      label = especie!;
    } else if (esRechazado) {
      bg    = _speciesNoneBg;
      fg    = _speciesNoneFg;
      label = 'Sin detección';
    } else if (esValidado) {
      bg    = _speciesOkBg;
      fg    = _speciesOkFg;
      label = 'Especie válida';
    } else {
      bg    = _speciesPendingBg;
      fg    = _speciesPendingFg;
      label = 'Analizando…';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomPaint(size: const Size(13, 13), painter: _LeafPainter(color: fg)),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              style: GoogleFonts.hankenGrotesk(
                fontSize: 12, fontWeight: FontWeight.w600, color: fg,
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
  final int? arboles;
  final bool esValidado;
  final bool esRechazado;

  const _AiText({
    required this.arboles,
    required this.esValidado,
    required this.esRechazado,
  });

  @override
  Widget build(BuildContext context) {
    final Color fg = esValidado
        ? _aprobadoFg
        : esRechazado
            ? _rechazadoFg
            : _pendienteFg;

    final String texto = arboles != null ? '$arboles árb.' : '—';

    return Text(
      texto,
      style: GoogleFonts.hankenGrotesk(
        fontSize: 12, fontWeight: FontWeight.w500, color: fg,
      ),
    );
  }
}

// ─── Vista en pantalla completa ───────────────────────────────────────────────

class _DetalleDialog extends StatelessWidget {
  final _EvidenciaReal ev;
  const _DetalleDialog({required this.ev});

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      child: Scaffold(
        backgroundColor: const Color(0xFF0E1A13),
        appBar: AppBar(
          backgroundColor: const Color(0xFF0E1A13),
          foregroundColor: Colors.white,
          title: Text(
            ev.fechaFmt,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
        body: Column(
          children: [
            // Foto expandida
            Expanded(
              child: ev.url.isEmpty
                  ? const _GreenPlaceholder()
                  : Image.network(
                      ev.url,
                      fit: BoxFit.contain,
                      width: double.infinity,
                      errorBuilder: (_, _, _) => const _GreenPlaceholder(),
                    ),
            ),
            // Panel de análisis IA
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Resultado del análisis IA',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.ink,
                          ),
                        ),
                      ),
                      _BadgeEstado(estadoIa: ev.estadoIa),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _InfoRow(icon: Icons.calendar_today_outlined, label: 'Fecha', value: ev.fechaFmt),
                  const SizedBox(height: 10),
                  _InfoRow(
                    icon: Icons.park_outlined,
                    label: 'Árboles detectados',
                    value: ev.arbolesDetectados != null
                        ? '${ev.arbolesDetectados} árboles'
                        : '—',
                  ),
                  if (ev.especie != null && ev.especie!.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    _InfoRow(
                      icon: Icons.eco_outlined,
                      label: 'Especie detectada',
                      value: ev.especie!,
                    ),
                  ],
                  if (ev.aiResultado != null && ev.aiResultado!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      'Notas del análisis',
                      style: GoogleFonts.hankenGrotesk(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                        color: const Color(0xFF8A9C90),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      ev.aiResultado!,
                      style: GoogleFonts.hankenGrotesk(
                        fontSize: 13,
                        color: AppColors.textMuted,
                        height: 1.55,
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.primary),
        const SizedBox(width: 10),
        Text(
          '$label: ',
          style: GoogleFonts.hankenGrotesk(
            fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textMuted,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.hankenGrotesk(fontSize: 13, color: AppColors.ink),
          ),
        ),
      ],
    );
  }
}

// ─── Estados vacío / error ────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72, height: 72,
              decoration: const BoxDecoration(
                color: AppColors.surfaceMint, shape: BoxShape.circle,
              ),
              child: const Icon(Icons.photo_camera_outlined, size: 32, color: AppColors.primary),
            ),
            const SizedBox(height: 18),
            Text(
              'Aún no hay evidencias de este proyecto',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.ink,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'El administrador irá subiendo el avance',
              style: GoogleFonts.hankenGrotesk(
                fontSize: 13, color: AppColors.textMuted,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;
  const _ErrorState({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: Column(
          children: [
            const Icon(Icons.error_outline, size: 36, color: AppColors.textMuted),
            const SizedBox(height: 14),
            Text(
              error,
              style: GoogleFonts.hankenGrotesk(fontSize: 13, color: AppColors.textMuted),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),
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

// ─── Hoja SVG (CustomPainter) ─────────────────────────────────────────────────

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

    final leaf = Path()
      ..moveTo(11, 20)
      ..arcToPoint(const Offset(4, 13), radius: const Radius.circular(7), clockwise: true)
      ..relativeCubicTo(0, -5, 4, -9, 11, -9)
      ..relativeCubicTo(0, 6, -3, 10, -8, 11);

    final stem = Path()
      ..moveTo(4, 20)
      ..relativeCubicTo(2, -4, 5, -6, 9, -7);

    canvas.drawPath(leaf, paint);
    canvas.drawPath(stem, paint);
  }

  @override
  bool shouldRepaint(_LeafPainter old) => old.color != color;
}
