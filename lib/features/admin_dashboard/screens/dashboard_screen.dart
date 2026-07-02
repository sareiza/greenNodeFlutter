import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/api_service.dart';
import '../../../data/mock_admin_data.dart';
import '../../../shared/badges/estado_badge.dart';

// ─── Colores puntuales del mockup ────────────────────────────────────────────
const _cardShadow = [
  BoxShadow(color: Color(0x12102A1C), blurRadius: 24, offset: Offset(0, 8)),
];
const _hoverBorder = Color(0xFFBFE2CC);
const _hoverShadow = Color(0x0F102A1C);
const _progressBg = Color(0xFFEAF4ED);
// ─────────────────────────────────────────────────────────────────────────────

(Color, Color, Color, String) _estadoProyectoVisual(EstadoProyectoAdmin estado) =>
    switch (estado) {
      EstadoProyectoAdmin.enProgreso => (
          AppColors.enRevisionBg,
          AppColors.enRevisionText,
          AppColors.enRevisionDot,
          'En progreso',
        ),
      EstadoProyectoAdmin.completado => (
          AppColors.aprobadoBg,
          AppColors.aprobadoText,
          AppColors.aprobadoDot,
          'Completado',
        ),
      EstadoProyectoAdmin.cancelado => (
          AppColors.rechazadoBg,
          AppColors.rechazadoText,
          AppColors.rechazadoDot,
          'Cancelado',
        ),
    };

// ─── Datos calculados a partir de la API ─────────────────────────────────────

class _DashboardData {
  final int cotizacionesPendientes;
  final int proyectosEnProgreso;
  final int proyectosCompletados;
  final int proyectosCancelados;
  final List<ProyectoAdminItem> proyectos;
  final List<({String title, String trailing})> cotizacionesPrioritarias;
  final List<({String title, String trailing})> proyectosSinEvidencia;

  const _DashboardData({
    required this.cotizacionesPendientes,
    required this.proyectosEnProgreso,
    required this.proyectosCompletados,
    required this.proyectosCancelados,
    required this.proyectos,
    required this.cotizacionesPrioritarias,
    required this.proyectosSinEvidencia,
  });
}

EstadoProyectoAdmin _mapEstado(String status) {
  return switch (status.toLowerCase()) {
    'completed' || 'completado' || 'finalizado' => EstadoProyectoAdmin.completado,
    'cancelled' || 'canceled' || 'cancelado' => EstadoProyectoAdmin.cancelado,
    _ => EstadoProyectoAdmin.enProgreso,
  };
}

String _formatDate(String? iso) {
  if (iso == null || iso.isEmpty) return '—';
  try {
    final dt = DateTime.parse(iso);
    const meses = ['ene','feb','mar','abr','may','jun','jul','ago','sep','oct','nov','dic'];
    return '${dt.day} ${meses[dt.month - 1]} ${dt.year}';
  } catch (_) {
    return iso.split('T').first;
  }
}

_DashboardData _buildData(
  Map<String, dynamic> summary,
  List<dynamic> proyectosRaw,
  List<dynamic> cotizacionesRaw,
) {
  // Métricas: usar summary si el back lo devuelve, si no computar desde las listas
  final hasSummary = summary.isNotEmpty;

  int cotPend, enProg, completados, cancelados;

  if (hasSummary) {
    cotPend      = (summary['pendingQuotes'] ?? summary['cotizacionesPendientes'] ?? 0) as int;
    enProg       = (summary['activeProjects'] ?? summary['proyectosEnProgreso'] ?? 0) as int;
    completados  = (summary['completedProjects'] ?? summary['proyectosCompletados'] ?? 0) as int;
    cancelados   = (summary['cancelledProjects'] ?? summary['proyectosCancelados'] ?? 0) as int;
  } else {
    bool isPend(dynamic c) {
      final s = ((c as Map)['status'] as String? ?? '').toLowerCase();
      return s == 'pending' || s == 'reviewed' || s == 'pendiente' || s == 'enrevision';
    }
    bool isActive(dynamic p) {
      final s = ((p as Map)['status'] as String? ?? '').toLowerCase();
      return s != 'completed' && s != 'cancelled' && s != 'canceled';
    }
    bool isDone(dynamic p)      => ((p as Map)['status'] as String? ?? '').toLowerCase() == 'completed';
    bool isCancelled(dynamic p) {
      final s = ((p as Map)['status'] as String? ?? '').toLowerCase();
      return s == 'cancelled' || s == 'canceled';
    }

    cotPend     = cotizacionesRaw.where(isPend).length;
    enProg      = proyectosRaw.where(isActive).length;
    completados = proyectosRaw.where(isDone).length;
    cancelados  = proyectosRaw.where(isCancelled).length;
  }

  // Proyectos recientes (máx 8)
  final proyectos = proyectosRaw.take(8).map((raw) {
    final p = raw as Map<String, dynamic>;
    return ProyectoAdminItem(
      id:      p['id']?.toString() ?? '',
      nombre:  p['name']?.toString() ?? p['nombre']?.toString() ?? 'Proyecto sin nombre',
      empresa: p['companyName']?.toString() ?? p['empresa']?.toString() ?? '—',
      estado:  _mapEstado(p['status']?.toString() ?? ''),
      avance:  (p['progress'] as num?)?.toDouble() ?? 0.0,
    );
  }).toList();

  // Acciones: cotizaciones pendientes/en revisión
  final cotPrioritarias = cotizacionesRaw
      .where((c) {
        final s = ((c as Map)['status'] as String? ?? '').toLowerCase();
        return s == 'pending' || s == 'reviewed' || s == 'pendiente' || s == 'enrevision';
      })
      .take(5)
      .map((c) {
        final m = c as Map<String, dynamic>;
        return (
          title: m['companyName']?.toString() ?? m['empresa']?.toString() ?? 'Empresa',
          trailing: _formatDate(m['createdAt']?.toString() ?? m['fecha']?.toString()),
        );
      })
      .toList();

  // Acciones: proyectos en progreso como "sin evidencia reciente" (evidencias endpoint aún no disponible)
  final sinEvidencia = proyectos
      .where((p) => p.estado == EstadoProyectoAdmin.enProgreso)
      .take(4)
      .map((p) => (title: p.nombre, trailing: '—'))
      .toList();

  return _DashboardData(
    cotizacionesPendientes: cotPend,
    proyectosEnProgreso:    enProg,
    proyectosCompletados:   completados,
    proyectosCancelados:    cancelados,
    proyectos:              proyectos,
    cotizacionesPrioritarias: cotPrioritarias,
    proyectosSinEvidencia:  sinEvidencia,
  );
}

// ─── Pantalla principal ───────────────────────────────────────────────────────

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _loading = true;
  String? _error;
  _DashboardData? _data;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() { _loading = true; _error = null; });
    try {
      // Las tres llamadas en paralelo; summary puede fallar (404) sin romper todo
      final results = await Future.wait([
        apiService.getDashboardSummary().catchError((_) => <String, dynamic>{}),
        apiService.getProyectos(),
        apiService.getCotizaciones(),
      ]);

      final summary      = results[0] as Map<String, dynamic>;
      final proyectosRaw = results[1] as List<dynamic>;
      final cotizRaw     = results[2] as List<dynamic>;

      if (!mounted) return;
      setState(() {
        _data    = _buildData(summary, proyectosRaw, cotizRaw);
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
            colors: [
              AppColors.bgGradientStart,
              AppColors.bgGradientMid,
              AppColors.bgGradientEnd,
            ],
          ),
        ),
        child: SafeArea(child: _buildBody()),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_outlined, size: 48, color: AppColors.textSubtle),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: GoogleFonts.hankenGrotesk(fontSize: 14, color: AppColors.textMuted),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
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

    final d = _data!;
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 38, vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _PageHeader(),
          const SizedBox(height: 26),
          _MetricsRow(
            cotizacionesPendientes: d.cotizacionesPendientes,
            proyectosEnProgreso:    d.proyectosEnProgreso,
            proyectosCompletados:   d.proyectosCompletados,
            proyectosCancelados:    d.proyectosCancelados,
          ),
          const SizedBox(height: 28),
          const _EvolucionChartCard(),
          const SizedBox(height: 28),
          _ProyectosRecientesSection(proyectos: d.proyectos),
          const SizedBox(height: 28),
          _AccionesPrioritariasSection(
            cotizaciones: d.cotizacionesPrioritarias,
            sinEvidencia: d.proyectosSinEvidencia,
          ),
        ],
      ),
    );
  }
}

// ─── Page header ─────────────────────────────────────────────────────────────

class _PageHeader extends StatelessWidget {
  const _PageHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Dashboard', style: AppTextStyles.tituloVista),
        const SizedBox(height: 6),
        Text(
          'Resumen general de GreenNode',
          style: GoogleFonts.hankenGrotesk(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: AppColors.textMuted,
          ),
        ),
      ],
    );
  }
}

// ─── Fila de métricas ─────────────────────────────────────────────────────────

class _MetricsRow extends StatelessWidget {
  final int cotizacionesPendientes;
  final int proyectosEnProgreso;
  final int proyectosCompletados;
  final int proyectosCancelados;

  const _MetricsRow({
    required this.cotizacionesPendientes,
    required this.proyectosEnProgreso,
    required this.proyectosCompletados,
    required this.proyectosCancelados,
  });

  @override
  Widget build(BuildContext context) {
    final cards = [
      _MetricCard(
        value: '$cotizacionesPendientes',
        label: 'Cotizaciones pendientes',
        icon: Icons.description_outlined,
        fg: AppColors.pendienteDot,
        bg: AppColors.pendienteBg,
      ),
      _MetricCard(
        value: '$proyectosEnProgreso',
        label: 'Proyectos en progreso',
        icon: Icons.park_outlined,
        fg: AppColors.primary,
        bg: AppColors.surfaceMint,
      ),
      _MetricCard(
        value: '$proyectosCompletados',
        label: 'Proyectos completados',
        icon: Icons.check_circle_outline,
        fg: AppColors.aprobadoDot,
        bg: AppColors.aprobadoBg,
      ),
      _MetricCard(
        value: '$proyectosCancelados',
        label: 'Proyectos cancelados',
        icon: Icons.cancel_outlined,
        fg: AppColors.rechazadoDot,
        bg: AppColors.rechazadoBg,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 880) {
          return Row(
            children: [
              for (int i = 0; i < cards.length; i++) ...[
                Expanded(child: cards[i]),
                if (i < cards.length - 1) const SizedBox(width: 16),
              ],
            ],
          );
        }
        final cardWidth = (constraints.maxWidth - 16) / 2;
        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            for (final c in cards) SizedBox(width: cardWidth, child: c),
          ],
        );
      },
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color fg;
  final Color bg;

  const _MetricCard({
    required this.value,
    required this.label,
    required this.icon,
    required this.fg,
    required this.bg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.line, width: 1),
        boxShadow: _cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(11)),
            child: Icon(icon, size: 20, color: fg),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 30,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.hankenGrotesk(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Gráfica de barras (datos históricos — mantenida con mock mientras el back no expone el endpoint) ──

class _EvolucionChartCard extends StatelessWidget {
  const _EvolucionChartCard();

  @override
  Widget build(BuildContext context) {
    final data = mockEvolucionMensual;
    final maxValue = data.fold<int>(
      0,
      (acc, e) => [acc, e.enProgreso, e.completado, e.cancelado].reduce((a, b) => a > b ? a : b),
    );
    final maxY = (maxValue * 1.25).ceilToDouble();
    final interval = (maxY / 4).clamp(1.0, double.infinity);

    return Container(
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.line, width: 1),
        boxShadow: _cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 14,
            runSpacing: 8,
            children: [
              Text(
                'Proyectos por estado',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                ),
              ),
              const _ChartLegend(),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Últimos 6 meses',
            style: GoogleFonts.hankenGrotesk(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: AppColors.textSubtle,
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 220,
            child: BarChart(
              BarChartData(
                maxY: maxY,
                alignment: BarChartAlignment.spaceAround,
                barTouchData: BarTouchData(enabled: false),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: interval,
                  getDrawingHorizontalLine: (_) => const FlLine(color: AppColors.line, strokeWidth: 1),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      interval: interval,
                      getTitlesWidget: (value, meta) => Text(
                        value.toInt().toString(),
                        style: GoogleFonts.hankenGrotesk(fontSize: 11, color: AppColors.textSubtle),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final i = value.toInt();
                        if (i < 0 || i >= data.length) return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            data[i].mes,
                            style: GoogleFonts.hankenGrotesk(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textMuted,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                barGroups: [
                  for (int i = 0; i < data.length; i++)
                    BarChartGroupData(
                      x: i,
                      barsSpace: 4,
                      barRods: [
                        BarChartRodData(
                          toY: data[i].enProgreso.toDouble(),
                          color: AppColors.enRevisionDot,
                          width: 9,
                          borderRadius: BorderRadius.circular(3),
                        ),
                        BarChartRodData(
                          toY: data[i].completado.toDouble(),
                          color: AppColors.aprobadoDot,
                          width: 9,
                          borderRadius: BorderRadius.circular(3),
                        ),
                        BarChartRodData(
                          toY: data[i].cancelado.toDouble(),
                          color: AppColors.rechazadoDot,
                          width: 9,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChartLegend extends StatelessWidget {
  const _ChartLegend();

  @override
  Widget build(BuildContext context) {
    const items = [
      (AppColors.enRevisionDot, 'En progreso'),
      (AppColors.aprobadoDot, 'Completado'),
      (AppColors.rechazadoDot, 'Cancelado'),
    ];
    return Wrap(
      spacing: 14,
      runSpacing: 6,
      children: [
        for (final (color, label) in items)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.hankenGrotesk(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
      ],
    );
  }
}

// ─── Últimos proyectos ─────────────────────────────────────────────────────────

class _ProyectosRecientesSection extends StatelessWidget {
  final List<ProyectoAdminItem> proyectos;
  const _ProyectosRecientesSection({required this.proyectos});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Últimos proyectos',
          style: GoogleFonts.plusJakartaSans(fontSize: 19, fontWeight: FontWeight.w700, color: AppColors.ink),
        ),
        const SizedBox(height: 14),
        if (proyectos.isEmpty)
          _EmptyState(
            icon: Icons.forest_outlined,
            message: 'No hay proyectos registrados aún.',
          )
        else
          for (int i = 0; i < proyectos.length; i++) ...[
            _ProyectoCard(proyectos[i]),
            if (i < proyectos.length - 1) const SizedBox(height: 10),
          ],
      ],
    );
  }
}

class _ProyectoCard extends StatefulWidget {
  final ProyectoAdminItem proyecto;
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

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: () => context.go('/admin/proyecto/${p.id}'),
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
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p.nombre,
                      style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.ink),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      p.empresa,
                      style: GoogleFonts.hankenGrotesk(fontSize: 13, fontWeight: FontWeight.w400, color: AppColors.textSubtle),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              EstadoBadge.custom(bg: bg, fg: fg, dot: dot, label: label),
              const SizedBox(width: 20),
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${(p.avance * 100).round()}%',
                      style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.ink),
                    ),
                    const SizedBox(height: 6),
                    SizedBox(
                      width: double.infinity,
                      child: Container(
                        height: 7,
                        clipBehavior: Clip.hardEdge,
                        decoration: BoxDecoration(color: _progressBg, borderRadius: BorderRadius.circular(999)),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: p.avance.clamp(0, 1),
                          child: Container(color: dot),
                        ),
                      ),
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

// ─── Acciones prioritarias ──────────────────────────────────────────────────────

class _AccionesPrioritariasSection extends StatelessWidget {
  final List<({String title, String trailing})> cotizaciones;
  final List<({String title, String trailing})> sinEvidencia;

  const _AccionesPrioritariasSection({
    required this.cotizaciones,
    required this.sinEvidencia,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Acciones prioritarias',
          style: GoogleFonts.plusJakartaSans(fontSize: 19, fontWeight: FontWeight.w700, color: AppColors.ink),
        ),
        const SizedBox(height: 14),
        LayoutBuilder(
          builder: (context, constraints) {
            final cotCard = _AccionesCard(
              title: 'Cotizaciones pendientes de revisión',
              icon: Icons.description_outlined,
              accent: AppColors.pendienteDot,
              accentBg: AppColors.pendienteBg,
              rows: cotizaciones.isEmpty
                  ? [const _EmptyAccionRow()]
                  : [for (final c in cotizaciones) _AccionRow(title: c.title, trailing: c.trailing)],
            );
            final evCard = _AccionesCard(
              title: 'Proyectos sin evidencia reciente',
              icon: Icons.photo_library_outlined,
              accent: AppColors.rechazadoDot,
              accentBg: AppColors.rechazadoBg,
              rows: sinEvidencia.isEmpty
                  ? [const _EmptyAccionRow()]
                  : [for (final p in sinEvidencia) _AccionRow(title: p.title, trailing: p.trailing)],
            );

            if (constraints.maxWidth < 760) {
              return Column(children: [cotCard, const SizedBox(height: 16), evCard]);
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: cotCard),
                const SizedBox(width: 20),
                Expanded(child: evCard),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _AccionesCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color accent;
  final Color accentBg;
  final List<Widget> rows;

  const _AccionesCard({
    required this.title,
    required this.icon,
    required this.accent,
    required this.accentBg,
    required this.rows,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
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
                decoration: BoxDecoration(color: accentBg, borderRadius: BorderRadius.circular(9)),
                child: Icon(icon, size: 16, color: accent),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.hankenGrotesk(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.ink),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          for (int i = 0; i < rows.length; i++) ...[
            rows[i],
            if (i < rows.length - 1) const Divider(height: 18, color: AppColors.line),
          ],
        ],
      ),
    );
  }
}

class _AccionRow extends StatelessWidget {
  final String title;
  final String trailing;

  const _AccionRow({required this.title, required this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: GoogleFonts.hankenGrotesk(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.ink),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          trailing,
          style: GoogleFonts.hankenGrotesk(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textSubtle),
        ),
      ],
    );
  }
}

class _EmptyAccionRow extends StatelessWidget {
  const _EmptyAccionRow();

  @override
  Widget build(BuildContext context) {
    return Text(
      'Sin elementos pendientes',
      style: GoogleFonts.hankenGrotesk(fontSize: 13, color: AppColors.textSubtle),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  const _EmptyState({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.line, width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 36, color: AppColors.line),
          const SizedBox(height: 12),
          Text(
            message,
            style: GoogleFonts.hankenGrotesk(fontSize: 14, color: AppColors.textSubtle),
          ),
        ],
      ),
    );
  }
}
