import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/mock_admin_data.dart';
import '../../../shared/badges/estado_badge.dart';

// ─── Colores puntuales del mockup ────────────────────────────────────────────
const _cardShadow = [
  BoxShadow(color: Color(0x12102A1C), blurRadius: 24, offset: Offset(0, 8)),
];
const _hoverBorder = Color(0xFFBFE2CC);
const _hoverShadow = Color(0x0F102A1C);
// ─────────────────────────────────────────────────────────────────────────────

enum _Filtro { todas, pendiente, enRevision }

class CotizacionesPendientesScreen extends StatefulWidget {
  const CotizacionesPendientesScreen({super.key});

  @override
  State<CotizacionesPendientesScreen> createState() => _CotizacionesPendientesScreenState();
}

class _CotizacionesPendientesScreenState extends State<CotizacionesPendientesScreen> {
  _Filtro _filtro = _Filtro.todas;

  List<CotizacionAdminItem> get _items {
    switch (_filtro) {
      case _Filtro.todas:
        return mockCotizacionesAdmin;
      case _Filtro.pendiente:
        return mockCotizacionesAdmin
            .where((c) => c.estado == EstadoCotizacionAdmin.pendiente)
            .toList();
      case _Filtro.enRevision:
        return mockCotizacionesAdmin
            .where((c) => c.estado == EstadoCotizacionAdmin.enRevision)
            .toList();
    }
  }

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
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(38, 32, 38, 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
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
                    IconButton(
                      tooltip: 'Volver al Dashboard',
                      onPressed: () => context.go('/admin/dashboard'),
                      icon: const Icon(Icons.close_rounded, color: AppColors.textMuted),
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
              Expanded(
                child: _items.isEmpty
                    ? Center(
                        child: Text(
                          'No hay cotizaciones para este filtro.',
                          style: GoogleFonts.hankenGrotesk(fontSize: 14, color: AppColors.textMuted),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(38, 0, 38, 32),
                        itemCount: _items.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (context, i) => _CotizacionCard(_items[i]),
                      ),
              ),
            ],
          ),
        ),
      ),
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
  final CotizacionAdminItem cotizacion;
  const _CotizacionCard(this.cotizacion);

  @override
  State<_CotizacionCard> createState() => _CotizacionCardState();
}

class _CotizacionCardState extends State<_CotizacionCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final c = widget.cotizacion;
    final (bg, fg, dot) = c.estado == EstadoCotizacionAdmin.pendiente
        ? (AppColors.pendienteBg, AppColors.pendienteText, AppColors.pendienteDot)
        : (AppColors.enRevisionBg, AppColors.enRevisionText, AppColors.enRevisionDot);
    final label = c.estado == EstadoCotizacionAdmin.pendiente ? 'Pendiente' : 'En revisión';

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
