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
const _hoverBorder = Color(0xFFBFE2CC);
const _hoverShadow = Color(0x0F102A1C);
// ─────────────────────────────────────────────────────────────────────────────

enum _Filtro { todas, pendiente, enRevision }

// ─── Modelo local mapeado desde la API ───────────────────────────────────────

class _QuoteItem {
  final String id;
  final String empresa;
  final String territorio;
  final int arboles;
  final String fecha;
  final String status;

  const _QuoteItem({
    required this.id,
    required this.empresa,
    required this.territorio,
    required this.arboles,
    required this.fecha,
    required this.status,
  });

  factory _QuoteItem.fromJson(Map<String, dynamic> j) => _QuoteItem(
        id:         j['id']?.toString() ?? '',
        empresa:    j['companyName']?.toString() ?? j['empresa']?.toString() ?? 'Empresa',
        territorio: j['territory']?.toString() ?? j['territoryName']?.toString() ?? '—',
        arboles:    (j['trees'] as num?)?.toInt() ??
                    (j['numberOfTrees'] as num?)?.toInt() ??
                    (j['quantity'] as num?)?.toInt() ?? 0,
        fecha:      _fmt(j['createdAt']?.toString() ?? j['fecha']?.toString()),
        status:     (j['status']?.toString() ?? 'pending').toLowerCase(),
      );
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

// ─── Pantalla ─────────────────────────────────────────────────────────────────

class CotizacionesPendientesScreen extends StatefulWidget {
  const CotizacionesPendientesScreen({super.key});

  @override
  State<CotizacionesPendientesScreen> createState() => _CotizacionesPendientesScreenState();
}

class _CotizacionesPendientesScreenState extends State<CotizacionesPendientesScreen> {
  _Filtro _filtro = _Filtro.todas;
  bool _loading = true;
  String? _error;
  List<_QuoteItem> _all = [];

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
        _all = raw.map((e) => _QuoteItem.fromJson(e as Map<String, dynamic>)).toList();
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  List<_QuoteItem> get _items => switch (_filtro) {
        _Filtro.todas      => _all,
        _Filtro.pendiente  => _all.where((c) => c.status == 'pending').toList(),
        _Filtro.enRevision => _all.where((c) => c.status == 'reviewed').toList(),
      };

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
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(38, 32, 38, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Cotizaciones pendientes', style: AppTextStyles.tituloVista),
                    const SizedBox(height: 6),
                    Text(
                      'Revisa y gestiona las solicitudes de las empresas',
                      style: GoogleFonts.hankenGrotesk(
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 38),
                child: _FiltroBar(
                  selected: _filtro,
                  onChanged: (f) => setState(() => _filtro = f),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(child: _buildBody()),
            ],
          ),
        ),
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
    if (_items.isEmpty) {
      return Center(
        child: Text(
          'No hay cotizaciones para este filtro.',
          style: GoogleFonts.hankenGrotesk(fontSize: 14, color: AppColors.textMuted),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(38, 0, 38, 32),
      itemCount: _items.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, i) => _CotizacionCard(_items[i]),
    );
  }
}

// ─── Filtro ─────────────────────────────────────────────────────────────────

class _FiltroBar extends StatelessWidget {
  final _Filtro selected;
  final ValueChanged<_Filtro> onChanged;
  const _FiltroBar({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    const chips = [
      (_Filtro.todas, 'Todas'),
      (_Filtro.pendiente, 'Pendientes'),
      (_Filtro.enRevision, 'En revisión'),
    ];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final (filtro, label) in chips)
          _FiltroChip(
            label: label,
            selected: selected == filtro,
            onTap: () => onChanged(filtro),
          ),
      ],
    );
  }
}

class _FiltroChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _FiltroChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.line,
            width: 1.5,
          ),
          boxShadow: selected
              ? const [BoxShadow(color: Color(0x33168F4C), blurRadius: 10, offset: Offset(0, 3))]
              : const [],
        ),
        child: Text(
          label,
          style: GoogleFonts.hankenGrotesk(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : AppColors.textMuted,
          ),
        ),
      ),
    );
  }
}

// ─── Tarjeta de cotización ──────────────────────────────────────────────────

class _CotizacionCard extends StatefulWidget {
  final _QuoteItem cotizacion;
  const _CotizacionCard(this.cotizacion);

  @override
  State<_CotizacionCard> createState() => _CotizacionCardState();
}

class _CotizacionCardState extends State<_CotizacionCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final c = widget.cotizacion;
    final isPend = c.status == 'pending';
    final (bg, fg, dot) = isPend
        ? (AppColors.pendienteBg, AppColors.pendienteText, AppColors.pendienteDot)
        : (AppColors.enRevisionBg, AppColors.enRevisionText, AppColors.enRevisionDot);
    final label = isPend ? 'Pendiente' : 'En revisión';

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: () => context.go('/admin/cotizaciones/${c.id}'),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _hovered ? _hoverBorder : AppColors.line, width: 1),
            boxShadow: _hovered
                ? const [BoxShadow(color: _hoverShadow, blurRadius: 14, offset: Offset(0, 4))]
                : _cardShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      c.empresa,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  EstadoBadge.custom(bg: bg, fg: fg, dot: dot, label: label),
                ],
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 20,
                runSpacing: 6,
                children: [
                  _MetaItem(icon: Icons.location_on_outlined, text: c.territorio),
                  _MetaItem(icon: Icons.park_outlined, text: '${c.arboles} árboles'),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.calendar_today_outlined, size: 13, color: AppColors.placeholder),
                  const SizedBox(width: 5),
                  Text(
                    c.fecha,
                    style: GoogleFonts.hankenGrotesk(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSubtle,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Ver detalle →',
                    style: GoogleFonts.hankenGrotesk(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _hovered ? AppColors.primary : AppColors.placeholder,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetaItem extends StatelessWidget {
  final IconData icon;
  final String text;
  const _MetaItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.textSubtle),
        const SizedBox(width: 5),
        Text(
          text,
          style: GoogleFonts.hankenGrotesk(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textMuted),
        ),
      ],
    );
  }
}
