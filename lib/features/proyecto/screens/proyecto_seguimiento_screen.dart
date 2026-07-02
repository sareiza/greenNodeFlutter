import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../data/mock_data.dart';
import '../providers/proyecto_provider.dart';

// ─── Colores ──────────────────────────────────────────────────────────────────
const _dotDone          = Color(0xFF1B9E54);
const _dotCurrentBg     = Color(0xFFFEF5DC);
const _dotCurrentBorder = Color(0xFFE0A82E);
const _dotCurrentInner  = Color(0xFFE0A82E);
const _dotLockedBg      = Color(0xFFEEF3EF);
const _dotLockedBorder  = Color(0xFFDCE6DD);
const _dotLockedIcon    = Color(0xFF9DB0A4);
const _headCurrent      = Color(0xFF8A6516);
const _headLocked       = Color(0xFF9DB0A4);
const _taskLocked       = Color(0xFFA9B7AD);
const _connectorDone    = Color(0xFF1B9E54);
const _connectorPending = Color(0xFFE3EAE4);
const _eyebrowColor     = Color(0xFF8A9C90);

// ─────────────────────────────────────────────────────────────────────────────

class ProyectoSeguimientoScreen extends StatelessWidget {
  const ProyectoSeguimientoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProyectoProvider()..cargar(),
      child: const _SeguimientoView(),
    );
  }
}

class _SeguimientoView extends StatelessWidget {
  const _SeguimientoView();

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ProyectoProvider>();

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
        child: p.isLoading
            ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
            : p.error != null
                ? _ErrorState(
                    error: p.error!,
                    onRetry: () => context.read<ProyectoProvider>().cargar(),
                  )
                : !p.hasProject
                    ? const _EmptyState()
                    : _Content(p: p),
      ),
    );
  }
}

// ─── Contenido principal ──────────────────────────────────────────────────────

class _Content extends StatelessWidget {
  final ProyectoProvider p;
  const _Content({required this.p});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 38, vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PageHeader(nombre: p.nombre, periodo: p.periodo, area: p.area),
          const SizedBox(height: 26),
          _ProgressCard(avance: p.avance),
          const SizedBox(height: 30),
          _TimelineSection(hitos: p.hitos),
        ],
      ),
    );
  }
}

// ─── Page header ──────────────────────────────────────────────────────────────

class _PageHeader extends StatelessWidget {
  final String nombre;
  final String periodo;
  final String area;
  const _PageHeader({required this.nombre, required this.periodo, required this.area});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Seguimiento',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 26,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.52,
            color: AppColors.ink,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          nombre,
          style: GoogleFonts.hankenGrotesk(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '$periodo · $area',
          style: GoogleFonts.hankenGrotesk(fontSize: 13, color: AppColors.textMuted),
        ),
      ],
    );
  }
}

// ─── Tarjeta de avance ────────────────────────────────────────────────────────

class _ProgressCard extends StatelessWidget {
  final double avance;
  const _ProgressCard({required this.avance});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.line),
        boxShadow: const [
          BoxShadow(color: Color(0x0E102A1C), blurRadius: 20, offset: Offset(0, 6)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Avance global',
                style: GoogleFonts.hankenGrotesk(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF3E4F44),
                ),
              ),
              Text(
                '${(avance * 100).round()}%',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            height: 10,
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF4ED),
              borderRadius: BorderRadius.circular(999),
            ),
            child: TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 700),
              tween: Tween(begin: 0, end: avance),
              builder: (_, value, _) => FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: value,
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
        ],
      ),
    );
  }
}

// ─── Timeline section ─────────────────────────────────────────────────────────

class _TimelineSection extends StatelessWidget {
  final List<HitoTimeline> hitos;
  const _TimelineSection({required this.hitos});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'LÍNEA DE SEGUIMIENTO',
          style: GoogleFonts.hankenGrotesk(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.96,
            color: _eyebrowColor,
          ),
        ),
        const SizedBox(height: 16),
        for (int i = 0; i < hitos.length; i++)
          _TimelineItem(hito: hitos[i], isLast: i == hitos.length - 1),
      ],
    );
  }
}

class _TimelineItem extends StatelessWidget {
  final HitoTimeline hito;
  final bool isLast;
  const _TimelineItem({required this.hito, required this.isLast});

  @override
  Widget build(BuildContext context) {
    final done    = hito.estado == EstadoHitoTimeline.done;
    final current = hito.estado == EstadoHitoTimeline.current;
    final locked  = hito.estado == EstadoHitoTimeline.locked;

    final statusText = done ? 'Completado' : current ? 'Pendiente de evidencia' : 'Bloqueado';
    final headColor  = current ? _headCurrent : locked ? _headLocked : AppColors.ink;
    final taskColor  = locked ? _taskLocked : AppColors.textMuted;
    final connColor  = done ? _connectorDone : _connectorPending;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            _Dot(done: done, current: current),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                margin: const EdgeInsets.symmetric(vertical: 3),
                color: connColor,
              ),
          ],
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 7),
                Text(
                  '${hito.mes} · $statusText',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: headColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  hito.titulo,
                  style: GoogleFonts.hankenGrotesk(fontSize: 13, color: taskColor),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Dot extends StatelessWidget {
  final bool done;
  final bool current;
  const _Dot({required this.done, required this.current});

  @override
  Widget build(BuildContext context) {
    if (done) {
      return Container(
        width: 34, height: 34,
        decoration: const BoxDecoration(color: _dotDone, shape: BoxShape.circle),
        child: const Icon(Icons.check_rounded, size: 17, color: Colors.white),
      );
    }
    if (current) {
      return Container(
        width: 34, height: 34,
        decoration: BoxDecoration(
          color: _dotCurrentBg,
          shape: BoxShape.circle,
          border: Border.all(color: _dotCurrentBorder, width: 2),
        ),
        child: Center(
          child: Container(
            width: 10, height: 10,
            decoration: const BoxDecoration(color: _dotCurrentInner, shape: BoxShape.circle),
          ),
        ),
      );
    }
    return Container(
      width: 34, height: 34,
      decoration: BoxDecoration(
        color: _dotLockedBg,
        shape: BoxShape.circle,
        border: Border.all(color: _dotLockedBorder, width: 2),
      ),
      child: const Icon(Icons.lock_outline, size: 14, color: _dotLockedIcon),
    );
  }
}

// ─── Empty / Error ────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80, height: 80,
              decoration: const BoxDecoration(color: AppColors.surfaceMint, shape: BoxShape.circle),
              child: const Icon(Icons.park_outlined, size: 38, color: AppColors.primary),
            ),
            const SizedBox(height: 20),
            Text(
              'Aún no tienes un proyecto activo',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.ink,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Solicita una cotización para comenzar a sembrar tu bosque corporativo.',
              style: GoogleFonts.hankenGrotesk(fontSize: 14, color: AppColors.textMuted, height: 1.55),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/cotizar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: Text(
                'Solicitar cotización',
                style: GoogleFonts.hankenGrotesk(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;
  const _ErrorState({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 40, color: AppColors.textMuted),
            const SizedBox(height: 16),
            Text(
              error,
              style: GoogleFonts.hankenGrotesk(fontSize: 14, color: AppColors.textMuted),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: onRetry,
              child: Text(
                'Reintentar',
                style: GoogleFonts.hankenGrotesk(
                  fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
