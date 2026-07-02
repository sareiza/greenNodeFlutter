import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../data/api_service.dart';

const _cardShadow = [
  BoxShadow(color: Color(0x12102A1C), blurRadius: 24, offset: Offset(0, 8)),
];

// ─── Helpers ──────────────────────────────────────────────────────────────────

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

String _montoDisplay(double monto) {
  final cents = monto.round();
  if (cents <= 0) return '—';
  if (cents >= 1000) {
    final miles = cents ~/ 1000;
    final resto = (cents % 1000).toString().padLeft(3, '0');
    return '\$$miles,$resto';
  }
  return '\$$cents';
}

(Color bg, Color fg, Color dot, String label) _estadoVis(String status) =>
    switch (status.toLowerCase()) {
      'approved' || 'aprobada' || 'aprobado'   => (AppColors.aprobadoBg, AppColors.aprobadoText, AppColors.aprobadoDot, 'Aprobado'),
      'rejected' || 'rechazada' || 'rechazado' => (AppColors.rechazadoBg, AppColors.rechazadoText, AppColors.rechazadoDot, 'Rechazado'),
      'sent'                                    => (AppColors.enRevisionBg, AppColors.enRevisionText, AppColors.enRevisionDot, 'Enviado'),
      'reviewed'                                => (AppColors.enRevisionBg, AppColors.enRevisionText, AppColors.enRevisionDot, 'En revisión'),
      _                                         => (AppColors.pendienteBg, AppColors.pendienteText, AppColors.pendienteDot, 'Pendiente'),
    };

String _extractPropuesta(Map<String, dynamic> data) =>
    data['aiDraftText']?.toString().trim() ??
    data['ai_draft_text']?.toString().trim() ??
    data['aiProposal']?.toString().trim() ??
    data['proposal']?.toString().trim() ??
    data['description']?.toString().trim() ?? '';

// ─── Screen ───────────────────────────────────────────────────────────────────

class CotizacionDetalleScreen extends StatefulWidget {
  final String id;
  const CotizacionDetalleScreen({super.key, required this.id});

  @override
  State<CotizacionDetalleScreen> createState() => _CotizacionDetalleScreenState();
}

class _CotizacionDetalleScreenState extends State<CotizacionDetalleScreen> {
  bool _loading = true;
  String? _error;
  Map<String, dynamic>? _data;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() { _loading = true; _error = null; });
    try {
      final data = await apiService.getCotizacionById(widget.id);
      if (!mounted) return;
      setState(() { _data = data; _loading = false; });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error   = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  void _showSnackBar(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg,
            style: GoogleFonts.hankenGrotesk(fontWeight: FontWeight.w500, color: Colors.white)),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(20),
        duration: const Duration(seconds: 3),
      ),
    );
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
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.wifi_off_outlined, size: 40, color: AppColors.textSubtle),
              const SizedBox(height: 14),
              Text(_error!,
                  style: GoogleFonts.hankenGrotesk(fontSize: 14, color: AppColors.textMuted),
                  textAlign: TextAlign.center),
              const SizedBox(height: 18),
              ElevatedButton.icon(
                onPressed: _loadData,
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

    final data       = _data!;
    final status     = (data['status']?.toString() ?? 'pending').toLowerCase();
    final territorio = data['territoryName']?.toString() ??
                       data['territory']?.toString() ??
                       data['zona']?.toString() ?? '—';
    final arboles    = (data['numberOfTrees'] as num?)?.toInt() ??
                       (data['trees'] as num?)?.toInt() ??
                       (data['quantity'] as num?)?.toInt() ?? 0;
    final fecha      = _fmt(data['createdAt']?.toString());
    final monto      = (data['price'] as num?)?.toDouble() ??
                       (data['totalPrice'] as num?)?.toDouble() ??
                       (data['totalAmount'] as num?)?.toDouble() ??
                       (data['amount'] as num?)?.toDouble() ??
                       (data['total'] as num?)?.toDouble() ?? 0.0;
    final propuesta  = _extractPropuesta(data);
    final isSent     = status == 'sent';

    final (badgeBg, badgeFg, badgeDot, badgeLabel) = _estadoVis(status);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(40, 32, 40, 60),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Volver ───────────────────────────────────────────────────────
          GestureDetector(
            onTap: () => context.go('/cotizaciones'),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.arrow_back_ios_new_rounded, size: 14, color: AppColors.textSubtle),
                const SizedBox(width: 4),
                Text('Mis cotizaciones',
                    style: GoogleFonts.hankenGrotesk(
                        fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textSubtle)),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ── Header ───────────────────────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  'Cotización ${widget.id}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.ink, height: 1.15,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              _Badge(bg: badgeBg, fg: badgeFg, dot: badgeDot, label: badgeLabel),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '$fecha · $territorio',
            style: GoogleFonts.hankenGrotesk(fontSize: 14, color: AppColors.textSubtle),
          ),
          const SizedBox(height: 28),

          // ── Información ───────────────────────────────────────────────────
          _SectionCard(
            title: 'Información',
            child: Column(
              children: [
                _InfoRow(icon: Icons.location_on_outlined,  label: 'Territorio', value: territorio),
                _InfoRow(icon: Icons.park_outlined,          label: 'Árboles',    value: '$arboles árboles'),
                _InfoRow(icon: Icons.calendar_today_outlined, label: 'Fecha',     value: fecha),
                _InfoRow(
                  icon: Icons.attach_money_outlined,
                  label: 'Monto estimado',
                  value: _montoDisplay(monto),
                  isLast: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── Propuesta IA ──────────────────────────────────────────────────
          _SectionCard(
            title: 'Propuesta GreenNode',
            child: propuesta.isEmpty
                ? Text('La propuesta está siendo preparada.',
                    style: GoogleFonts.hankenGrotesk(
                        fontSize: 14, color: AppColors.textMuted, height: 1.6))
                : _PropuestaText(propuesta),
          ),

          // ── Acciones (solo si status == sent) ────────────────────────────
          if (isSent) ...[
            const SizedBox(height: 24),
            _ActionButtons(
              onAceptar: () => _showSnackBar(
                'Funcionalidad de aceptar en desarrollo.', AppColors.primary),
              onRechazar: () => _showSnackBar(
                'Funcionalidad de rechazar en desarrollo.', AppColors.rechazadoDot),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Sección tarjeta ──────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.line, width: 1),
        boxShadow: _cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.ink)),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

// ─── Fila de información ──────────────────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isLast;
  const _InfoRow({required this.icon, required this.label, required this.value, this.isLast = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              Icon(icon, size: 18, color: AppColors.primary),
              const SizedBox(width: 12),
              Text(label,
                  style: GoogleFonts.hankenGrotesk(
                      fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textSubtle)),
              const Spacer(),
              Text(value,
                  style: GoogleFonts.hankenGrotesk(
                      fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.ink)),
            ],
          ),
        ),
        if (!isLast) Divider(color: AppColors.line, height: 1),
      ],
    );
  }
}

// ─── Texto de propuesta IA ────────────────────────────────────────────────────

class _PropuestaText extends StatelessWidget {
  final String text;
  const _PropuestaText(this.text);

  @override
  Widget build(BuildContext context) {
    // Divide el texto por doble salto de línea para mostrar párrafos
    final parrafos = text.split(RegExp(r'\n{2,}')).where((p) => p.trim().isNotEmpty).toList();

    if (parrafos.length <= 1) {
      return Text(text,
          style: GoogleFonts.hankenGrotesk(
              fontSize: 14, color: AppColors.textMuted, height: 1.7));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < parrafos.length; i++) ...[
          Text(parrafos[i].trim(),
              style: GoogleFonts.hankenGrotesk(
                  fontSize: 14, color: AppColors.textMuted, height: 1.7)),
          if (i < parrafos.length - 1) const SizedBox(height: 12),
        ],
      ],
    );
  }
}

// ─── Botones de acción ────────────────────────────────────────────────────────

class _ActionButtons extends StatelessWidget {
  final VoidCallback onAceptar;
  final VoidCallback onRechazar;
  const _ActionButtons({required this.onAceptar, required this.onRechazar});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: onRechazar,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.rechazadoText,
              side: const BorderSide(color: AppColors.rechazadoDot, width: 1.5),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
            ),
            child: Text('Rechazar',
                style: GoogleFonts.hankenGrotesk(
                    fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.rechazadoText)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(11),
              boxShadow: [
                BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.26),
                    blurRadius: 14, offset: const Offset(0, 5)),
              ],
            ),
            child: FilledButton(
              onPressed: onAceptar,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
              ),
              child: Text('Aceptar',
                  style: GoogleFonts.hankenGrotesk(
                      fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Badge ────────────────────────────────────────────────────────────────────

class _Badge extends StatelessWidget {
  final Color bg, fg, dot;
  final String label;
  const _Badge({required this.bg, required this.fg, required this.dot, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
