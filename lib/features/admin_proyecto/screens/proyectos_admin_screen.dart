import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/mock_admin_data.dart';
import '../../../shared/badges/estado_badge.dart';

const _cardShadow = [
  BoxShadow(color: Color(0x12102A1C), blurRadius: 24, offset: Offset(0, 8)),
];
const _hoverBorder = Color(0xFFBFE2CC);

// ─── Filtro ───────────────────────────────────────────────────────────────────

enum _FiltroP { todos, enProgreso, completado, cancelado }

// ─── Screen ───────────────────────────────────────────────────────────────────

class ProyectosAdminScreen extends StatefulWidget {
  const ProyectosAdminScreen({super.key});

  @override
  State<ProyectosAdminScreen> createState() => _ProyectosAdminScreenState();
}

class _ProyectosAdminScreenState extends State<ProyectosAdminScreen> {
  _FiltroP _filtro = _FiltroP.todos;

  List<ProyectoAdminDetalle> get _items {
    switch (_filtro) {
      case _FiltroP.todos:
        return mockProyectosAdmin;
      case _FiltroP.enProgreso:
        return mockProyectosAdmin
            .where((p) => p.estado == EstadoProyectoAdmin.enProgreso)
            .toList();
      case _FiltroP.completado:
        return mockProyectosAdmin
            .where((p) => p.estado == EstadoProyectoAdmin.completado)
            .toList();
      case _FiltroP.cancelado:
        return mockProyectosAdmin
            .where((p) => p.estado == EstadoProyectoAdmin.cancelado)
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Proyectos', style: AppTextStyles.tituloVista),
                    const SizedBox(height: 6),
                    Text(
                      'Gestión de proyectos activos',
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
              Expanded(
                child: _items.isEmpty
                    ? Center(
                        child: Text(
                          'No hay proyectos para este filtro.',
                          style: GoogleFonts.hankenGrotesk(
                            fontSize: 14,
                            color: AppColors.textMuted,
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(38, 0, 38, 32),
                        itemCount: _items.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (context, i) => _ProyectoCard(_items[i]),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Filtro chips ─────────────────────────────────────────────────────────────

class _FiltroBar extends StatelessWidget {
  final _FiltroP selected;
  final ValueChanged<_FiltroP> onChanged;
  const _FiltroBar({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    const chips = [
      (_FiltroP.todos, 'Todos'),
      (_FiltroP.enProgreso, 'En progreso'),
      (_FiltroP.completado, 'Completados'),
      (_FiltroP.cancelado, 'Cancelados'),
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

// ─── Tarjeta de proyecto ──────────────────────────────────────────────────────

(Color bg, Color fg, Color dot, String label) _estadoProyectoVisual(
    EstadoProyectoAdmin e) =>
    switch (e) {
      EstadoProyectoAdmin.enProgreso =>
        (AppColors.enRevisionBg, AppColors.enRevisionText, AppColors.enRevisionDot, 'En progreso'),
      EstadoProyectoAdmin.completado =>
        (AppColors.aprobadoBg, AppColors.aprobadoText, AppColors.aprobadoDot, 'Completado'),
      EstadoProyectoAdmin.cancelado =>
        (AppColors.rechazadoBg, AppColors.rechazadoText, AppColors.rechazadoDot, 'Cancelado'),
    };

class _ProyectoCard extends StatefulWidget {
  final ProyectoAdminDetalle proyecto;
  const _ProyectoCard(this.proyecto);

  @override
  State<_ProyectoCard> createState() => _ProyectoCardState();
}

class _ProyectoCardState extends State<_ProyectoCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final p = widget.proyecto;
    final (bg, fg, dot, label) = _estadoProyectoVisual(p.estado);
    final pct = (p.avance * 100).round();

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: () => context.go('/admin/proyecto/${p.id}'),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: _hovered ? _hoverBorder : AppColors.line,
              width: 1,
            ),
            boxShadow: _cardShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          p.nombre,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.ink,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          p.empresa,
                          style: GoogleFonts.hankenGrotesk(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSubtle,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  EstadoBadge.custom(bg: bg, fg: fg, dot: dot, label: label),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Text(
                    'Avance',
                    style: GoogleFonts.hankenGrotesk(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSubtle,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '$pct%',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: p.avance,
                  minHeight: 7,
                  backgroundColor: AppColors.line,
                  valueColor: AlwaysStoppedAnimation<Color>(dot),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.calendar_today_outlined,
                      size: 13, color: AppColors.placeholder),
                  const SizedBox(width: 5),
                  Text(
                    p.fechaInicio,
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
