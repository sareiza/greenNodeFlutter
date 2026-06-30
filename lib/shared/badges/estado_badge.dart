import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_colors.dart';
import '../../data/mock_data.dart';

/// Badge de estado reutilizable (Pendiente / En revisión / Aprobado / Rechazado).
///
/// Para estados que no son [EstadoCotizacion] (p. ej. los estados de
/// proyecto del panel admin) usa [EstadoBadge.custom] entregando los
/// colores y la etiqueta directamente.
class EstadoBadge extends StatelessWidget {
  final Color _bg;
  final Color _fg;
  final Color _dot;
  final String _label;

  factory EstadoBadge(EstadoCotizacion estado, {Key? key}) {
    final (Color bg, Color fg, Color dot, String label) = switch (estado) {
      EstadoCotizacion.aprobada => (
          AppColors.aprobadoBg,
          AppColors.aprobadoText,
          AppColors.aprobadoDot,
          'Aprobado',
        ),
      EstadoCotizacion.enRevision => (
          AppColors.enRevisionBg,
          AppColors.enRevisionText,
          AppColors.enRevisionDot,
          'En revisión',
        ),
      EstadoCotizacion.rechazada => (
          AppColors.rechazadoBg,
          AppColors.rechazadoText,
          AppColors.rechazadoDot,
          'Rechazado',
        ),
      EstadoCotizacion.pendiente => (
          AppColors.pendienteBg,
          AppColors.pendienteText,
          AppColors.pendienteDot,
          'Pendiente',
        ),
    };
    return EstadoBadge.custom(bg: bg, fg: fg, dot: dot, label: label, key: key);
  }

  const EstadoBadge.custom({
    required Color bg,
    required Color fg,
    required Color dot,
    required String label,
    super.key,
  })  : _bg = bg,
        _fg = fg,
        _dot = dot,
        _label = label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: _dot, shape: BoxShape.circle),
          ),
          const SizedBox(width: 7),
          Text(
            _label,
            style: GoogleFonts.hankenGrotesk(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _fg,
            ),
          ),
        ],
      ),
    );
  }
}
