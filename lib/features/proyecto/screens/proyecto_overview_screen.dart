import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../data/mock_data.dart';
import '../providers/proyecto_provider.dart';

// ─── Colores puntuales del mockup ────────────────────────────────────────────
const _labelDark = Color(0xFF3E4F44);
const _progressBg = Color(0xFFEAF4ED);
const _miniCardBorder = Color(0xFFEAF4ED);
const _amberBg = Color(0xFFFBF6E8);
const _amberBorder = Color(0xFFF0E4C4);
const _amberLabel = Color(0xFFA98A3E);
const _amberValue = Color(0xFF8A6516);
const _eyebrowColor = Color(0xFF8A9C90);
const _speciesBg = Color(0xFFF1F7F3);
const _dotDone = Color(0xFF1B9E54);
const _dotCurrentBg = Color(0xFFFEF5DC);
const _dotCurrentBorder = Color(0xFFE0A82E);
const _dotCurrentInner = Color(0xFFE0A82E);
const _dotLockedBg = Color(0xFFEEF3EF);
const _dotLockedBorder = Color(0xFFDCE6DD);
const _dotLockedIcon = Color(0xFF9DB0A4);
const _headCurrent = Color(0xFF8A6516);
const _headLocked = Color(0xFF9DB0A4);
const _taskLocked = Color(0xFFA9B7AD);
const _connectorDone = Color(0xFF1B9E54);
const _connectorPending = Color(0xFFE3EAE4);
const _trunkColor = Color(0xFF8A6A48);
const _broadMain = Color(0xFF1B9E54);
const _broadLeft = Color(0xFF22AC5E);
const _broadRight = Color(0xFF15803D);
// ─────────────────────────────────────────────────────────────────────────────

class ProyectoOverviewScreen extends StatelessWidget {
  const ProyectoOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProyectoProvider()..cargar(),
      child: const _ProyectoView(),
    );
  }
}

class _ProyectoView extends StatelessWidget {
  const _ProyectoView();

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
                    : SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 38, vertical: 32),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            _PageHeader(),
                            SizedBox(height: 22),
                            _HeroCard(),
                            SizedBox(height: 26),
                            _SpeciesSection(),
                            SizedBox(height: 30),
                            _TimelineSection(),
                          ],
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
          'Mi proyecto',
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
          'Seguimiento de tu bosque corporativo en tiempo real.',
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

// ─── Hero card ───────────────────────────────────────────────────────────────

class _HeroCard extends StatelessWidget {
  const _HeroCard();

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
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _HeroHeader(),
          _HeroBody(),
        ],
      ),
    );
  }
}

class _HeroHeader extends StatelessWidget {
  const _HeroHeader();

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ProyectoProvider>();

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment(-0.5, -1),
          end: Alignment(0.5, 1),
          colors: [Color(0xFF15462F), Color(0xFF0E2C1E)],
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PROYECTO ACTIVO',
                  style: GoogleFonts.hankenGrotesk(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.96,
                    color: Colors.white.withValues(alpha: 0.55),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  p.nombre,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${p.periodo} · ${p.area}',
                  style: GoogleFonts.hankenGrotesk(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.mint,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          _StatusBadge(p.status),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge(this.status);

  (Color bg, Color dot, Color text, String label) _config() => switch (status) {
        'completed' || 'completado' => (
            Colors.white,
            const Color(0xFF1B9E54),
            const Color(0xFF15462F),
            'Completado',
          ),
        'cancelled' || 'cancelado' => (
            const Color(0xFFFEF2F2),
            const Color(0xFFDC2626),
            const Color(0xFF991B1B),
            'Cancelado',
          ),
        _ => (
            AppColors.mint,
            const Color(0xFF06301C),
            const Color(0xFF06301C),
            'En curso',
          ),
      };

  @override
  Widget build(BuildContext context) {
    final (bg, dot, text, label) = _config();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 7, height: 7, decoration: BoxDecoration(color: dot, shape: BoxShape.circle)),
          const SizedBox(width: 7),
          Text(
            label,
            style: GoogleFonts.hankenGrotesk(fontSize: 12, fontWeight: FontWeight.w600, color: text),
          ),
        ],
      ),
    );
  }
}

class _HeroBody extends StatelessWidget {
  const _HeroBody();

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ProyectoProvider>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                'Avance global del proyecto',
                style: GoogleFonts.hankenGrotesk(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: _labelDark,
                ),
              ),
              Text(
                '${(p.avance * 100).round()}%',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          _ProgressBar(progress: p.avance),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _MiniCard(
                  label: 'Hito actual',
                  value: p.hitoActualValor,
                  detail: p.hitoActualDetalle,
                  isAmber: false,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MiniCard(
                  label: 'Próximo hito',
                  value: p.proximoHitoValor,
                  detail: p.proximoHitoDetalle,
                  isAmber: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MiniCard(
                  label: 'Árboles vivos',
                  value: p.arbolesVivosValor,
                  detail: p.arbolesVivosDetalle,
                  isAmber: false,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final double progress;
  const _ProgressBar({required this.progress});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 10,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: _progressBg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 600),
        tween: Tween(begin: 0, end: progress),
        builder: (context, value, _) => FractionallySizedBox(
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
    );
  }
}

class _MiniCard extends StatelessWidget {
  final String label;
  final String value;
  final String detail;
  final bool isAmber;

  const _MiniCard({
    required this.label,
    required this.value,
    required this.detail,
    required this.isAmber,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: isAmber ? _amberBg : AppColors.surfaceTint,
        border: Border.all(
          color: isAmber ? _amberBorder : _miniCardBorder,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: GoogleFonts.hankenGrotesk(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.55,
              color: isAmber ? _amberLabel : _eyebrowColor,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: isAmber ? _amberValue : AppColors.ink,
            ),
          ),
          Text(
            detail,
            style: GoogleFonts.hankenGrotesk(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: isAmber ? _amberLabel : AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Species section ──────────────────────────────────────────────────────────

class _SpeciesSection extends StatelessWidget {
  const _SpeciesSection();

  @override
  Widget build(BuildContext context) {
    final especies = context.select<ProyectoProvider, List<EspecieSembrada>>(
      (p) => p.especies,
    );
    final total = especies.fold(0, (sum, e) => sum + e.cantidad);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Eyebrow('Especies sembradas · $total árboles'),
        const SizedBox(height: 14),
        for (int i = 0; i < especies.length; i += 2)
          Padding(
            padding: EdgeInsets.only(bottom: i + 2 < especies.length ? 10 : 0),
            child: Row(
              children: [
                Expanded(child: _SpeciesItem(especies[i])),
                const SizedBox(width: 10),
                Expanded(
                  child: i + 1 < especies.length
                      ? _SpeciesItem(especies[i + 1])
                      : const SizedBox(),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _SpeciesItem extends StatelessWidget {
  final EspecieSembrada especie;
  const _SpeciesItem(this.especie);

  @override
  Widget build(BuildContext context) {
    final barFraction = especie.cantidad / especie.totalProyecto;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.line, width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: _speciesBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: CustomPaint(
                size: const Size(22, 22),
                painter: _TreePainter(especie.tipoArbol),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Flexible(
                      child: Text(
                        especie.nombre,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      '${especie.cantidad}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                Text(
                  especie.nombreCientifico,
                  style: GoogleFonts.hankenGrotesk(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    fontStyle: FontStyle.italic,
                    color: AppColors.textSubtle,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  height: 5,
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(
                    color: _progressBg,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: barFraction,
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF1B9E54), Color(0xFF168F4C)],
                        ),
                      ),
                    ),
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

// ─── Timeline section ─────────────────────────────────────────────────────────

class _TimelineSection extends StatelessWidget {
  const _TimelineSection();

  @override
  Widget build(BuildContext context) {
    final hitos = context.select<ProyectoProvider, List<HitoTimeline>>(
      (p) => p.hitos,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _Eyebrow('Línea de seguimiento'),
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
    final done = hito.estado == EstadoHitoTimeline.done;
    final current = hito.estado == EstadoHitoTimeline.current;
    final locked = hito.estado == EstadoHitoTimeline.locked;

    final statusText =
        done ? 'Completado' : current ? 'Pendiente de evidencia' : 'Bloqueado';
    final headColor =
        current ? _headCurrent : locked ? _headLocked : AppColors.ink;
    final taskColor = locked ? _taskLocked : AppColors.textMuted;
    final connectorColor = done ? _connectorDone : _connectorPending;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            _Dot(done: done, current: current, locked: locked),
            if (!isLast)
              Container(
                width: 2,
                height: 36,
                margin: const EdgeInsets.symmetric(vertical: 3),
                color: connectorColor,
              ),
          ],
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16),
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
                  style: GoogleFonts.hankenGrotesk(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: taskColor,
                  ),
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
  final bool locked;

  const _Dot({required this.done, required this.current, required this.locked});

  @override
  Widget build(BuildContext context) {
    final Color bg;
    final Color? borderColor;
    final Widget child;

    if (done) {
      bg = _dotDone;
      borderColor = null;
      child = const Icon(Icons.check_rounded, size: 17, color: Colors.white);
    } else if (current) {
      bg = _dotCurrentBg;
      borderColor = _dotCurrentBorder;
      child = Container(
        width: 10,
        height: 10,
        decoration: const BoxDecoration(
          color: _dotCurrentInner,
          shape: BoxShape.circle,
        ),
      );
    } else {
      bg = _dotLockedBg;
      borderColor = _dotLockedBorder;
      child = const Icon(Icons.lock_outline, size: 14, color: _dotLockedIcon);
    }

    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
        border: borderColor != null
            ? Border.all(color: borderColor, width: 2)
            : null,
      ),
      child: Center(child: child),
    );
  }
}

// ─── Shared widgets ───────────────────────────────────────────────────────────

class _Eyebrow extends StatelessWidget {
  final String text;
  const _Eyebrow(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.hankenGrotesk(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.96,
        color: _eyebrowColor,
      ),
    );
  }
}

// ─── Empty / Error states ─────────────────────────────────────────────────────

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
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: AppColors.surfaceMint,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.park_outlined, size: 38, color: AppColors.primary),
            ),
            const SizedBox(height: 20),
            Text(
              'Aún no tienes un proyecto activo',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Solicita una cotización para comenzar a sembrar tu bosque corporativo.',
              style: GoogleFonts.hankenGrotesk(
                fontSize: 14,
                color: AppColors.textMuted,
                height: 1.55,
              ),
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
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Tree icon CustomPainter ──────────────────────────────────────────────────

class _TreePainter extends CustomPainter {
  final TipoArbol tipo;
  const _TreePainter(this.tipo);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 24, size.height / 24);

    final trunkPaint = Paint()
      ..color = _trunkColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;

    switch (tipo) {
      case TipoArbol.broad:
        canvas.drawLine(const Offset(12, 17), const Offset(12, 21), trunkPaint);
        canvas.drawCircle(const Offset(12, 10), 5.5, Paint()..color = _broadMain);
        canvas.drawCircle(const Offset(8.5, 12), 3, Paint()..color = _broadLeft);
        canvas.drawCircle(const Offset(15.5, 12), 2.6, Paint()..color = _broadRight);

      case TipoArbol.conical:
        canvas.drawLine(const Offset(12, 18), const Offset(12, 21), trunkPaint);
        final fill = Paint()..color = _broadMain;
        canvas.drawPath(
          Path()..moveTo(12, 3)..lineTo(16.5, 10)..lineTo(7.5, 10)..close(),
          fill,
        );
        canvas.drawPath(
          Path()..moveTo(12, 8)..lineTo(17, 16)..lineTo(7, 16)..close(),
          fill,
        );

      case TipoArbol.palm:
        canvas.drawLine(const Offset(12, 10), const Offset(12, 21), trunkPaint);
        final frond = Paint()
          ..color = _broadMain
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..strokeCap = StrokeCap.round;

        Path f(double cx1, double cy1, double cx2, double cy2, double ex, double ey) =>
            Path()..moveTo(12, 10)..cubicTo(cx1, cy1, cx2, cy2, ex, ey);

        canvas.drawPath(f(9.5, 7, 6, 6.5, 4.5, 8.5), frond);
        canvas.drawPath(f(14.5, 7, 18, 6.5, 19.5, 8.5), frond);
        canvas.drawPath(f(11, 6.5, 12, 3.5, 13.8, 2.2), frond);
        canvas.drawPath(f(13, 7, 15.8, 5.8, 18, 6.6), frond);
    }
  }

  @override
  bool shouldRepaint(_TreePainter old) => old.tipo != tipo;
}
