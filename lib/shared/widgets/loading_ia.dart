import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_colors.dart';

/// Diálogo de carga que se muestra mientras la IA procesa la cotización.
/// Uso: showDialog(context: ctx, barrierDismissible: false,
///                 builder: (_) => const LoadingIADialog());
class LoadingIADialog extends StatefulWidget {
  const LoadingIADialog({super.key});

  @override
  State<LoadingIADialog> createState() => _LoadingIADialogState();
}

class _LoadingIADialogState extends State<LoadingIADialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _pulse;
  int _dots = 1;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _pulse = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);

    // Actualiza los puntos suspensivos de forma independiente
    _ctrl.addListener(() {
      final next = (_ctrl.value * 3).ceil().clamp(1, 3);
      if (next != _dots) setState(() => _dots = next);
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        width: 320,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 36),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(color: Color(0x22102A1C), blurRadius: 48, offset: Offset(0, 16)),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Ícono pulsante
            ScaleTransition(
              scale: Tween<double>(begin: 0.88, end: 1.06).animate(_pulse),
              child: Container(
                width: 76, height: 76,
                decoration: BoxDecoration(
                  color: AppColors.surfaceMint,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.18),
                      blurRadius: 24,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Icon(Icons.eco_outlined, size: 38, color: AppColors.primary),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Generando propuesta${'.' * _dots}',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.ink,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'La IA está analizando tu solicitud y calculando\nel impacto ambiental óptimo.',
              style: GoogleFonts.hankenGrotesk(
                fontSize: 13, color: AppColors.textMuted, height: 1.55,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: const LinearProgressIndicator(
                minHeight: 4,
                backgroundColor: AppColors.line,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
