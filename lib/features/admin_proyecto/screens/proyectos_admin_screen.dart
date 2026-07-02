import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/api_service.dart';
import '../../../shared/badges/estado_badge.dart';

const _cardShadow = [
  BoxShadow(color: Color(0x12102A1C), blurRadius: 24, offset: Offset(0, 8)),
];
const _hoverBorder = Color(0xFFBFE2CC);

// ─── Modelo ───────────────────────────────────────────────────────────────────

class _ProyectoItem {
  final String id;
  final String nombre;
  final String empresa;
  final String status;
  final double avance;
  final String fechaInicio;

  const _ProyectoItem({
    required this.id,
    required this.nombre,
    required this.empresa,
    required this.status,
    required this.avance,
    required this.fechaInicio,
  });

  factory _ProyectoItem.fromJson(Map<String, dynamic> j) => _ProyectoItem(
        id:          j['id']?.toString() ?? '',
        nombre:      j['name']?.toString() ?? j['nombre']?.toString() ?? 'Proyecto sin nombre',
        empresa:     j['companyName']?.toString() ?? j['empresa']?.toString() ?? '—',
        status:      (j['status']?.toString() ?? 'active').toLowerCase(),
        avance:      (j['progress'] as num?)?.toDouble() ?? 0.0,
        fechaInicio: _fmt(j['startDate']?.toString() ?? j['createdAt']?.toString()),
      );

  bool get esCompletado => status == 'completed' || status == 'completado';
  bool get esCancelado  => status == 'cancelled' || status == 'canceled' || status == 'cancelado';
  bool get esEnProgreso => !esCompletado && !esCancelado;
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

(Color bg, Color fg, Color dot, String label) _estadoVis(_ProyectoItem p) {
  if (p.esCompletado) return (AppColors.aprobadoBg, AppColors.aprobadoText, AppColors.aprobadoDot, 'Completado');
  if (p.esCancelado)  return (AppColors.rechazadoBg, AppColors.rechazadoText, AppColors.rechazadoDot, 'Cancelado');
  return (AppColors.enRevisionBg, AppColors.enRevisionText, AppColors.enRevisionDot, 'En progreso');
}

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
  bool _loading = true;
  String? _error;
  List<_ProyectoItem> _all = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() { _loading = true; _error = null; });
    try {
      final raw = await apiService.getProyectos();
      if (!mounted) return;
      setState(() {
        _all     = raw.map((e) => _ProyectoItem.fromJson(e as Map<String, dynamic>)).toList();
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

  List<_ProyectoItem> get _items => switch (_filtro) {
        _FiltroP.todos      => _all,
        _FiltroP.enProgreso => _all.where((p) => p.esEnProgreso).toList(),
        _FiltroP.completado => _all.where((p) => p.esCompletado).toList(),
        _FiltroP.cancelado  => _all.where((p) => p.esCancelado).toList(),
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
                    Text('Proyectos', style: AppTextStyles.tituloVista),
                    const SizedBox(height: 6),
                    Text(
                      'Gestión de proyectos activos',
                      style: GoogleFonts.hankenGrotesk(
                        fontSize: 15, fontWeight: FontWeight.w400, color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 38),
                child: _FiltroBar(selected: _filtro, onChanged: (f) => setState(() => _filtro = f)),
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
    final items = _items;
    if (items.isEmpty) {
      return Center(
        child: Text(
          'No hay proyectos para este filtro.',
          style: GoogleFonts.hankenGrotesk(fontSize: 14, color: AppColors.textMuted),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(38, 0, 38, 32),
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, i) => _ProyectoCard(items[i]),
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
          border: Border.all(color: selected ? AppColors.primary : AppColors.line, width: 1.5),
          boxShadow: selected
              ? const [BoxShadow(color: Color(0x33168F4C), blurRadius: 10, offset: Offset(0, 3))]
              : const [],
        ),
        child: Text(
          label,
          style: GoogleFonts.hankenGrotesk(
            fontSize: 13, fontWeight: FontWeight.w600,
            color: selected ? Colors.white : AppColors.textMuted,
          ),
        ),
      ),
    );
  }
}

// ─── Tarjeta de proyecto ──────────────────────────────────────────────────────

class _ProyectoCard extends StatefulWidget {
  final _ProyectoItem proyecto;
  const _ProyectoCard(this.proyecto);

  @override
  State<_ProyectoCard> createState() => _ProyectoCardState();
}

class _ProyectoCardState extends State<_ProyectoCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final p = widget.proyecto;
    final (bg, fg, dot, label) = _estadoVis(p);
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
            border: Border.all(color: _hovered ? _hoverBorder : AppColors.line, width: 1),
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
                        Text(p.nombre,
                            style: GoogleFonts.plusJakartaSans(
                                fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.ink)),
                        const SizedBox(height: 3),
                        Text(p.empresa,
                            style: GoogleFonts.hankenGrotesk(
                                fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textSubtle)),
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
                  Text('Avance',
                      style: GoogleFonts.hankenGrotesk(
                          fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textSubtle)),
                  const Spacer(),
                  Text('$pct%',
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.ink)),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: p.avance.clamp(0.0, 1.0),
                  minHeight: 7,
                  backgroundColor: AppColors.line,
                  valueColor: AlwaysStoppedAnimation<Color>(dot),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.calendar_today_outlined, size: 13, color: AppColors.placeholder),
                  const SizedBox(width: 5),
                  Text(p.fechaInicio,
                      style: GoogleFonts.hankenGrotesk(
                          fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textSubtle)),
                  const Spacer(),
                  Text('Ver detalle →',
                      style: GoogleFonts.hankenGrotesk(
                          fontSize: 12, fontWeight: FontWeight.w600,
                          color: _hovered ? AppColors.primary : AppColors.placeholder)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
