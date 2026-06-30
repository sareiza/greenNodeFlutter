import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_colors.dart';
import '../../data/mock_data.dart';

/// Badge de estado reutilizable (Pendiente / En revisión / Aprobado / Rechazado).
class EstadoBadge extends StatelessWidget {
  final EstadoCotizacion estado;
  const EstadoBadge(this.estado, {super.key});

  @override
  Widget build(BuildContext context) {
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

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
          ),
          const SizedBox(width: 7),
          Text(
            label,
            style: GoogleFonts.hankenGrotesk(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}
