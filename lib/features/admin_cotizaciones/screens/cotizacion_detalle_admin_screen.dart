import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/api_service.dart';
import '../../../shared/badges/estado_badge.dart';

// ─── Colores puntuales del mockup ────────────────────────────────────────────
const _cardShadow = [
  BoxShadow(color: Color(0x12102A1C), blurRadius: 24, offset: Offset(0, 8)),
];
// ─────────────────────────────────────────────────────────────────────────────

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

class CotizacionDetalleAdminScreen extends StatefulWidget {
  final String id;
  const CotizacionDetalleAdminScreen({required this.id, super.key});

  @override
  State<CotizacionDetalleAdminScreen> createState() => _CotizacionDetalleAdminScreenState();
}

class _CotizacionDetalleAdminScreenState extends State<CotizacionDetalleAdminScreen> {
  bool _loading = true;
  String? _error;
  Map<String, dynamic>? _data;
  bool _actionLoading = false;

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
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Future<void> _confirmarAccion(bool aprobar) async {
    final empresa = _data?['companyName']?.toString() ?? _data?['empresa']?.toString() ?? 'Empresa';

    final confirmado = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          aprobar ? '¿Aprobar cotización?' : '¿Rechazar cotización?',
          style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.ink),
        ),
        content: Text(
          aprobar
              ? 'Se notificará a $empresa y se iniciará la generación del contrato.'
              : 'Se notificará a $empresa que su solicitud fue rechazada.',
          style: GoogleFonts.hankenGrotesk(fontSize: 14, color: AppColors.textMuted, height: 1.4),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.line, width: 1.5),
              foregroundColor: AppColors.textMuted,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text('Cancelar', style: GoogleFonts.hankenGrotesk(fontSize: 14, fontWeight: FontWeight.w600)),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: aprobar ? AppColors.primary : AppColors.rechazadoDot,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(
              aprobar ? 'Sí, aprobar' : 'Sí, rechazar',
              style: GoogleFonts.hankenGrotesk(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirmado != true || !mounted) return;

    setState(() => _actionLoading = true);
    try {
      if (aprobar) {
        await apiService.aprobarCotizacion(widget.id);
      } else {
        await apiService.rechazarCotizacion(widget.id);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            aprobar ? 'Cotización de $empresa aprobada.' : 'Cotización de $empresa rechazada.',
            style: GoogleFonts.hankenGrotesk(fontWeight: FontWeight.w500, color: Colors.white),
          ),
          backgroundColor: aprobar ? AppColors.primary : AppColors.rechazadoDot,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(20),
          duration: const Duration(seconds: 3),
        ),
      );
      context.go('/admin/cotizaciones');
    } catch (e) {
      if (!mounted) return;
      setState(() => _actionLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst('Exception: ', ''),
            style: GoogleFonts.hankenGrotesk(fontWeight: FontWeight.w500, color: Colors.white),
          ),
          backgroundColor: AppColors.rechazadoDot,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(20),
        ),
      );
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
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_outlined, size: 40, color: AppColors.textSubtle),
            const SizedBox(height: 14),
            Text(_error!, style: GoogleFonts.hankenGrotesk(fontSize: 14, color: AppColors.textMuted)),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: _loadData,
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Reintentar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
      );
    }
    if (_data == null) return const _NoEncontrada();

    return _Detalle(
      data: _data!,
      actionLoading: _actionLoading,
      onAccion: _confirmarAccion,
    );
  }
}

class _NoEncontrada extends StatelessWidget {
  const _NoEncontrada();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Cotización no encontrada.', style: AppTextStyles.cuerpo),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => context.go('/admin/cotizaciones'),
            child: Text(
              'Volver a cotizaciones',
              style: GoogleFonts.hankenGrotesk(fontWeight: FontWeight.w600, color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}

class _Detalle extends StatelessWidget {
  final Map<String, dynamic> data;
  final bool actionLoading;
  final void Function(bool aprobar) onAccion;

  const _Detalle({
    required this.data,
    required this.actionLoading,
    required this.onAccion,
  });

  @override
  Widget build(BuildContext context) {
    final id       = data['id']?.toString() ?? '';
    final empresa  = data['companyName']?.toString() ?? data['empresa']?.toString() ?? 'Empresa';
    final status   = (data['status']?.toString() ?? 'pending').toLowerCase();
    final isPend   = status == 'pending';
    final (bg, fg, dot) = isPend
        ? (AppColors.pendienteBg, AppColors.pendienteText, AppColors.pendienteDot)
        : (AppColors.enRevisionBg, AppColors.enRevisionText, AppColors.enRevisionDot);
    final estadoLabel = isPend ? 'Pendiente' : 'En revisión';

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 38, vertical: 32),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () => context.go('/admin/cotizaciones'),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.arrow_back_rounded, size: 18, color: AppColors.primary),
                  const SizedBox(width: 6),
                  Text(
                    'Volver a cotizaciones',
                    style: GoogleFonts.hankenGrotesk(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(empresa, style: AppTextStyles.tituloVista),
                      const SizedBox(height: 6),
                      Text(
                        'ID: $id',
                        style: GoogleFonts.hankenGrotesk(fontSize: 13, color: AppColors.textSubtle),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                EstadoBadge.custom(bg: bg, fg: fg, dot: dot, label: estadoLabel),
              ],
            ),
            const SizedBox(height: 24),
            _InfoCard(data: data),
            const SizedBox(height: 20),
            _PropuestaIACard(propuesta: _extractPropuesta(data)),
            const SizedBox(height: 28),
            if (actionLoading)
              const Center(child: CircularProgressIndicator(color: AppColors.primary))
            else
              Row(
                children: [
                  Expanded(
                    child: _ActionButton(
                      label: 'Rechazar',
                      icon: Icons.close_rounded,
                      bgColor: AppColors.rechazadoDot,
                      onTap: () => onAccion(false),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _ActionButton(
                      label: 'Aprobar',
                      icon: Icons.check_rounded,
                      bgColor: AppColors.primary,
                      onTap: () => onAccion(true),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  String _extractPropuesta(Map<String, dynamic> d) =>
      d['aiProposal']?.toString() ??
      d['proposal']?.toString() ??
      d['propuestaIA']?.toString() ??
      d['description']?.toString() ??
      'Sin propuesta generada aún.';
}

class _InfoCard extends StatelessWidget {
  final Map<String, dynamic> data;
  const _InfoCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final empresa   = data['companyName']?.toString() ?? data['empresa']?.toString() ?? '—';
    final territorio = data['territory']?.toString() ?? data['territoryName']?.toString() ?? '—';
    final arboles   = (data['trees'] as num?)?.toInt() ??
                      (data['numberOfTrees'] as num?)?.toInt() ??
                      (data['quantity'] as num?)?.toInt() ?? 0;
    final fecha     = _fmt(data['createdAt']?.toString() ?? data['fecha']?.toString());

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.line, width: 1),
        boxShadow: _cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Datos de la solicitud',
            style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.ink),
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: AppColors.line),
          const SizedBox(height: 16),
          _InfoRow(icon: Icons.business_outlined,        label: 'Empresa',            value: empresa),
          const SizedBox(height: 14),
          _InfoRow(icon: Icons.location_on_outlined,     label: 'Territorio',         value: territorio),
          const SizedBox(height: 14),
          _InfoRow(icon: Icons.park_outlined,            label: 'Árboles',            value: '$arboles árboles'),
          const SizedBox(height: 14),
          _InfoRow(icon: Icons.calendar_today_outlined,  label: 'Fecha de solicitud', value: fecha),
        ],
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(color: AppColors.surfaceMint, borderRadius: BorderRadius.circular(9)),
          child: Icon(icon, size: 15, color: AppColors.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.hankenGrotesk(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSubtle),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: GoogleFonts.hankenGrotesk(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.ink),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PropuestaIACard extends StatelessWidget {
  final String propuesta;
  const _PropuestaIACard({required this.propuesta});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.line, width: 1),
        boxShadow: _cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(color: AppColors.surfaceMint, borderRadius: BorderRadius.circular(9)),
                child: const Icon(Icons.auto_awesome_outlined, size: 16, color: AppColors.primary),
              ),
              const SizedBox(width: 10),
              Text(
                'Propuesta generada por IA',
                style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.ink),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: AppColors.line),
          const SizedBox(height: 16),
          Text(
            propuesta,
            style: GoogleFonts.hankenGrotesk(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppColors.textMuted,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color bgColor;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.bgColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: bgColor.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.hankenGrotesk(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
