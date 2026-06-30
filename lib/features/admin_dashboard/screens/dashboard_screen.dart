import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/mock_admin_data.dart';
import '../../../features/auth/providers/auth_provider.dart';
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

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

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
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 38, vertical: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _PageHeader(),
                const SizedBox(height: 26),
                const _MetricsRow(),
                const SizedBox(height: 28),
                const _EvolucionChartCard(),
                const SizedBox(height: 28),
                const _ProyectosRecientesSection(),
                const SizedBox(height: 28),
                const _AccionesPrioritariasSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Page header ─────────────────────────────────────────────────────────────

class _PageHeader extends StatelessWidget {
  const _PageHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
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
          ),
        ),
        OutlinedButton.icon(
          onPressed: () {
            context.read<AuthProvider>().logout();
            context.go('/login');
          },
          icon: const Icon(Icons.logout_rounded, size: 16),
          label: Text(
            'Cerrar sesión',
            style: GoogleFonts.hankenGrotesk(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            backgroundColor: Colors.white,
            side: const BorderSide(color: Color(0xFFBFE2CC), width: 1.5),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ],
    );
  }
}

// ─── Fila de métricas ─────────────────────────────────────────────────────────

class _MetricsRow extends StatelessWidget {
  const _MetricsRow();

  @override
  Widget build(BuildContext context) {
    final m = mockMetricas;
    final cards = [
      _MetricCard(
        value: '${m.cotizacionesPendientes}',
        label: 'Cotizaciones pendientes',
        icon: Icons.description_outlined,
        fg: AppColors.pendienteDot,
        bg: AppColors.pendienteBg,
      ),
      _MetricCard(
        value: '${m.proyectosEnProgreso}',
        label: 'Proyectos en progreso',
        icon: Icons.park_outlined,
        fg: AppColors.primary,
        bg: AppColors.surfaceMint,
      ),
      _MetricCard(
        value: '${m.proyectosCompletados}',
        label: 'Proyectos completados',
        icon: Icons.check_circle_outline,
        fg: AppColors.aprobadoDot,
        bg: AppColors.aprobadoBg,
      ),
      _MetricCard(
        value: '${m.proyectosCancelados}',
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

// ─── Gráfica de barras: proyectos por estado ─────────────────────────────────

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
  const _ProyectosRecientesSection();

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
        for (int i = 0; i < mockProyectosRecientes.length; i++) ...[
          _ProyectoCard(mockProyectosRecientes[i]),
          if (i < mockProyectosRecientes.length - 1) const SizedBox(height: 10),
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
  const _AccionesPrioritariasSection();

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
            final cotizaciones = _AccionesCard(
              title: 'Cotizaciones pendientes de revisión',
              icon: Icons.description_outlined,
              accent: AppColors.pendienteDot,
              accentBg: AppColors.pendienteBg,
              rows: [
                for (final c in mockAccionesPrioritarias.cotizacionesPendientes)
                  _AccionRow(title: c.empresa, trailing: c.fecha),
              ],
            );
            final evidencia = _AccionesCard(
              title: 'Proyectos sin evidencia reciente',
              icon: Icons.photo_library_outlined,
              accent: AppColors.rechazadoDot,
              accentBg: AppColors.rechazadoBg,
              rows: [
                for (final p in mockAccionesPrioritarias.proyectosSinEvidencia)
                  _AccionRow(title: p.nombre, trailing: '${p.diasSinEvidencia} días'),
              ],
            );

            if (constraints.maxWidth < 760) {
              return Column(children: [cotizaciones, const SizedBox(height: 16), evidencia]);
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: cotizaciones),
                const SizedBox(width: 20),
                Expanded(child: evidencia),
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
