import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../data/api_service.dart';

// ─── Colores de estado ────────────────────────────────────────────────────────
const _aprobadoBg  = Color(0xFFE6F6EC);
const _aprobadoFg  = Color(0xFF15803D);
const _aprobadoDot = Color(0xFF1B9E54);

const _revisionBg  = Color(0xFFE4F0F5);
const _revisionFg  = Color(0xFF1F6075);
const _revisionDot = Color(0xFF2E86AB);

const _rechazadoBg  = Color(0xFFFBEAE6);
const _rechazadoFg  = Color(0xFFB3402A);
const _rechazadoDot = Color(0xFFD9583C);

const _hoverBorder = Color(0xFFBFE2CC);
const _hoverShadow = Color(0x0F102A1C);

// ─── Modelo local ─────────────────────────────────────────────────────────────

class _CotizacionItem {
  final String id;
  final String territorio;
  final int arboles;
  final String fecha;
  final String status;
  final double monto;

  const _CotizacionItem({
    required this.id,
    required this.territorio,
    required this.arboles,
    required this.fecha,
    required this.status,
    required this.monto,
  });

  factory _CotizacionItem.fromJson(Map<String, dynamic> j) => _CotizacionItem(
        id:          j['id']?.toString() ?? '',
        territorio:  j['territoryName']?.toString() ??
                     j['territory']?.toString() ??
                     j['zona']?.toString() ?? '—',
        arboles:     (j['numberOfTrees'] as num?)?.toInt() ??
                     (j['trees'] as num?)?.toInt() ??
                     (j['quantity'] as num?)?.toInt() ?? 0,
        fecha:       _fmt(j['createdAt']?.toString()),
        status:      (j['status']?.toString() ?? 'pending').toLowerCase(),
        monto:       (j['price'] as num?)?.toDouble() ??
                     (j['totalPrice'] as num?)?.toDouble() ??
                     (j['totalAmount'] as num?)?.toDouble() ??
                     (j['amount'] as num?)?.toDouble() ??
                     (j['total'] as num?)?.toDouble() ?? 0.0,
      );

  String get meta => '$fecha · $territorio · $arboles árboles';

  String get montoDisplay {
    final cents = monto.round();
    if (cents >= 1000) {
      final miles = cents ~/ 1000;
      final resto = (cents % 1000).toString().padLeft(3, '0');
      return '\$$miles,$resto';
    }
    return monto == 0 ? '—' : '\$$cents';
  }
}

String _fmt(String? iso) {
  if (iso == null || iso.isEmpty) return '—';
  try {
    final dt = DateTime.parse(iso);
    const m = ['ene','feb','mar','abr','may','jun','jul','ago','sep','oct','nov','dic'];
    return '${dt.day} ${m[dt.month - 1]} ${dt.year}';
  } catch (_) {
    return iso.split('T').first;
  }
}

(Color bg, Color fg, Color dot, String label) _estadoVis(String status) =>
    switch (status) {
      'approved' || 'aprobada' || 'aprobado'     => (_aprobadoBg, _aprobadoFg, _aprobadoDot, 'Aprobado'),
      'rejected' || 'rechazada' || 'rechazado'   => (_rechazadoBg, _rechazadoFg, _rechazadoDot, 'Rechazado'),
      'sent'                                      => (_revisionBg, _revisionFg, _revisionDot, 'Enviado'),
      'reviewed'                                  => (_revisionBg, _revisionFg, _revisionDot, 'En revisión'),
      _                                           => (
                                                       AppColors.pendienteBg,
                                                       AppColors.pendienteText,
                                                       AppColors.pendienteDot,
                                                       'Pendiente',
                                                     ),
    };

// ─── Screen ───────────────────────────────────────────────────────────────────

class CotizacionListaScreen extends StatefulWidget {
  const CotizacionListaScreen({super.key});

  @override
  State<CotizacionListaScreen> createState() => _CotizacionListaScreenState();
}

class _CotizacionListaScreenState extends State<CotizacionListaScreen> {
  bool _loading = true;
  String? _error;
  List<_CotizacionItem> _items = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() { _loading = true; _error = null; });
    try {
      final raw = await apiService.getCotizaciones();
      if (!mounted) return;
      setState(() {
        _items   = raw.map((e) => _CotizacionItem.fromJson(e as Map<String, dynamic>)).toList();
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error   = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            radius: 1.2,
            colors: [AppColors.bgGradientStart, AppColors.bgGradientMid, AppColors.bgGradientEnd],
          ),
        ),
        child: SafeArea(child: _buildBody()),
      ),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 34),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ───────────────────────────────────────────────────────
          Text(
            'Mis cotizaciones',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 26, fontWeight: FontWeight.w700,
              height: 1.1, letterSpacing: -0.52, color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Historial de solicitudes y su estado de aprobación.',
            style: GoogleFonts.hankenGrotesk(
              fontSize: 15, fontWeight: FontWeight.w400, color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 26),

          // ── Estados ───────────────────────────────────────────────────────
          if (_loading)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 60),
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            )
          else if (_error != null)
            _ErrorState(message: _error!, onRetry: _loadData)
          else if (_items.isEmpty)
            _EmptyState(onNueva: () => context.go('/cotizar'))
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _items.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (_, i) => _CotizacionCard(_items[i]),
            ),
        ],
      ),
    );
  }
}

// ─── Estado vacío ─────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final VoidCallback onNueva;
  const _EmptyState({required this.onNueva});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: Column(
          children: [
            Container(
              width: 72, height: 72,
              decoration: BoxDecoration(
                color: AppColors.surfaceMint,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: CustomPaint(
                  size: const Size(32, 32),
                  painter: const _DocIconPainter(),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Aún no tienes cotizaciones',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Solicita tu primera cotización y plantemos juntos.',
              style: GoogleFonts.hankenGrotesk(
                fontSize: 14, color: AppColors.textMuted, height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 22),
            FilledButton(
              onPressed: onNueva,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 13),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
              ),
              child: Text(
                'Solicitar mi primera cotización',
                style: GoogleFonts.hankenGrotesk(
                  fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Estado de error ──────────────────────────────────────────────────────────

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: Column(
          children: [
            const Icon(Icons.wifi_off_outlined, size: 40, color: AppColors.textSubtle),
            const SizedBox(height: 14),
            Text(
              message,
              style: GoogleFonts.hankenGrotesk(fontSize: 14, color: AppColors.textMuted),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Reintentar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary, foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Tarjeta de cotización ────────────────────────────────────────────────────

class _CotizacionCard extends StatefulWidget {
  final _CotizacionItem cotizacion;
  const _CotizacionCard(this.cotizacion);

  @override
  State<_CotizacionCard> createState() => _CotizacionCardState();
}

class _CotizacionCardState extends State<_CotizacionCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final c = widget.cotizacion;
    final (bg, fg, dot, label) = _estadoVis(c.status);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit:  (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: () => context.go('/cotizaciones/${c.id}'),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _hovered ? _hoverBorder : AppColors.line, width: 1),
            boxShadow: _hovered
                ? const [BoxShadow(color: _hoverShadow, blurRadius: 14, offset: Offset(0, 4))]
                : const [],
          ),
          child: Row(
            children: [
              // Ícono documento
              Container(
                width: 42, height: 42,
                decoration: BoxDecoration(
                  color: AppColors.surfaceMint,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Center(
                  child: CustomPaint(size: const Size(20, 20), painter: const _DocIconPainter()),
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
                        fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.ink,
                      ),
                      maxLines: 1, overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      c.meta,
                      style: GoogleFonts.hankenGrotesk(
                        fontSize: 13, fontWeight: FontWeight.w400, color: AppColors.textSubtle,
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
                      fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 7),
                  _EstadoBadge(bg: bg, fg: fg, dot: dot, label: label),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Badge de estado ──────────────────────────────────────────────────────────

class _EstadoBadge extends StatelessWidget {
  final Color bg, fg, dot;
  final String label;
  const _EstadoBadge({required this.bg, required this.fg, required this.dot, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 7, height: 7, decoration: BoxDecoration(color: dot, shape: BoxShape.circle)),
          const SizedBox(width: 7),
          Text(label,
              style: GoogleFonts.hankenGrotesk(fontSize: 12, fontWeight: FontWeight.w600, color: fg)),
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
