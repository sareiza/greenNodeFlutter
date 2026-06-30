import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/constants/app_colors.dart';
import '../../../data/mock_data.dart';
import '../../../shared/badges/estado_badge.dart';

// ─── Colores puntuales del mockup ────────────────────────────────────────────
const _progressBg = Color(0xFFEAF4ED);
const _eyebrowColor = Color(0xFF8A9C90);
// ─────────────────────────────────────────────────────────────────────────────

(Color, String) _estadoPin(EstadoCotizacion estado) => switch (estado) {
      EstadoCotizacion.aprobada => (AppColors.aprobadoDot, 'Aprobado'),
      EstadoCotizacion.enRevision => (AppColors.enRevisionDot, 'En revisión'),
      EstadoCotizacion.pendiente => (AppColors.pendienteDot, 'Pendiente'),
      EstadoCotizacion.rechazada => (AppColors.rechazadoDot, 'Rechazado'),
    };

class AreasSiembraScreen extends StatefulWidget {
  const AreasSiembraScreen({super.key});

  @override
  State<AreasSiembraScreen> createState() => _AreasSiembraScreenState();
}

class _AreasSiembraScreenState extends State<AreasSiembraScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final lote = mockLotesSiembra[_selectedIndex];

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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 38, vertical: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _PageHeader(),
                const SizedBox(height: 22),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      if (constraints.maxWidth < 760) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: _MapCard(
                                selectedIndex: _selectedIndex,
                                onSelect: (i) =>
                                    setState(() => _selectedIndex = i),
                              ),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              height: 280,
                              child: _LotePanel(lote: lote),
                            ),
                          ],
                        );
                      }
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: _MapCard(
                              selectedIndex: _selectedIndex,
                              onSelect: (i) =>
                                  setState(() => _selectedIndex = i),
                            ),
                          ),
                          const SizedBox(width: 24),
                          SizedBox(width: 312, child: _LotePanel(lote: lote)),
                        ],
                      );
                    },
                  ),
                ),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Áreas de siembra',
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
          'Mapa de lotes — toca un pin para ver el detalle.',
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

// ─── Mapa + leyenda ───────────────────────────────────────────────────────────

class _MapCard extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  const _MapCard({required this.selectedIndex, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.line, width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12102A1C),
            blurRadius: 24,
            offset: Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        children: [
          FlutterMap(
            options: const MapOptions(
              initialCenter: LatLng(5.5, -75.5),
              initialZoom: 7,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.greennode.empresa',
              ),
              MarkerLayer(
                markers: [
                  for (int i = 0; i < mockLotesSiembra.length; i++)
                    Marker(
                      point: LatLng(
                        mockLotesSiembra[i].lat,
                        mockLotesSiembra[i].lng,
                      ),
                      width: 40,
                      height: 40,
                      alignment: Alignment.topCenter,
                      child: _MapPin(
                        lote: mockLotesSiembra[i],
                        selected: i == selectedIndex,
                        onTap: () => onSelect(i),
                      ),
                    ),
                ],
              ),
            ],
          ),
          const Positioned(left: 14, bottom: 14, child: _MapLegend()),
        ],
      ),
    );
  }
}

class _MapPin extends StatelessWidget {
  final LoteSiembra lote;
  final bool selected;
  final VoidCallback onTap;

  const _MapPin({
    required this.lote,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final (color, _) = _estadoPin(lote.estado);

    return GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Tooltip(
          message: lote.nombre,
          child: AnimatedScale(
            duration: const Duration(milliseconds: 150),
            scale: selected ? 1.15 : 1.0,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color,
                border: Border.all(
                  color: Colors.white,
                  width: selected ? 3 : 2,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x33102A1C),
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: const SizedBox(width: 22, height: 22),
            ),
          ),
        ),
      ),
    );
  }
}

class _MapLegend extends StatelessWidget {
  const _MapLegend();

  @override
  Widget build(BuildContext context) {
    const items = [
      (AppColors.aprobadoDot, 'Aprobado'),
      (AppColors.enRevisionDot, 'En revisión'),
      (AppColors.pendienteDot, 'Pendiente'),
      (AppColors.rechazadoDot, 'Rechazado'),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.line, width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14102A1C),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final (color, label) in items)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 9,
                    height: 9,
                    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 8),
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
            ),
        ],
      ),
    );
  }
}

// ─── Panel del lote seleccionado ──────────────────────────────────────────────

class _LotePanel extends StatelessWidget {
  final LoteSiembra lote;
  const _LotePanel({required this.lote});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.line, width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12102A1C),
            blurRadius: 24,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _Eyebrow('Lote seleccionado'),
          const SizedBox(height: 10),
          Text(
            lote.nombre,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 19,
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            lote.region,
            style: GoogleFonts.hankenGrotesk(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: AppColors.textSubtle,
            ),
          ),
          const SizedBox(height: 12),
          EstadoBadge(lote.estado),
          const SizedBox(height: 22),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                'Árboles plantados',
                style: GoogleFonts.hankenGrotesk(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF3E4F44),
                ),
              ),
              Text(
                '${(lote.porcentaje * 100).round()}%',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            height: 9,
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
              color: _progressBg,
              borderRadius: BorderRadius.circular(999),
            ),
            child: TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 400),
              tween: Tween(begin: 0, end: lote.porcentaje),
              builder: (context, value, _) => FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: value.clamp(0, 1),
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF1B9E54), Color(0xFF168F4C)],
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${lote.plantados} / ${lote.total} árboles',
            style: GoogleFonts.hankenGrotesk(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: AppColors.textMuted,
            ),
          ),
          const Spacer(),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => context.go('/proyecto'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(11),
                ),
                elevation: 4,
                shadowColor: AppColors.primary.withValues(alpha: 0.28),
              ),
              child: Text(
                'Ver detalle del lote',
                style: GoogleFonts.hankenGrotesk(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Eyebrow extends StatelessWidget {
  final String text;
  const _Eyebrow(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: GoogleFonts.hankenGrotesk(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.88,
        color: _eyebrowColor,
      ),
    );
  }
}
