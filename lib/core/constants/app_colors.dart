import 'package:flutter/material.dart';

/// Design tokens de color de GreenNode.
/// Fuente: design_handoff_greennode/README.md → Design Tokens.
class AppColors {
  AppColors._();

  // Colores de marca
  static const Color ink = Color(0xFF102A1C);
  static const Color forest = Color(0xFF15462F);
  static const Color forestDeep = Color(0xFF0E2C1E);
  static const Color primary = Color(0xFF168F4C);
  static const Color primaryHover = Color(0xFF117A3F);
  static const Color leaf = Color(0xFF1B9E54);
  static const Color mint = Color(0xFF6FE39A);
  static const Color textMuted = Color(0xFF5E7368);
  static const Color textSubtle = Color(0xFF7C8F83);
  static const Color placeholder = Color(0xFF9DB0A4);
  static const Color line = Color(0xFFE4EFE8);
  static const Color inputBorder = Color(0xFFDDEAE1);
  static const Color surfaceTint = Color(0xFFF6FBF8);
  static const Color surfaceMint = Color(0xFFF1F7F3);
  static const Color bgPage = Color(0xFFF4F8F5);

  // Fondo general de la app (degradado radial)
  static const Color bgGradientStart = Color(0xFFEDF7F0);
  static const Color bgGradientMid = Color(0xFFDCEEE2);
  static const Color bgGradientEnd = Color(0xFFCFE6D7);

  // Estado: Pendiente
  static const Color pendienteDot = Color(0xFFE0A82E);
  static const Color pendienteBg = Color(0xFFFEF5DC);
  static const Color pendienteText = Color(0xFF8A6516);

  // Estado: En revisión
  static const Color enRevisionDot = Color(0xFF2E86AB);
  static const Color enRevisionBg = Color(0xFFE4F0F5);
  static const Color enRevisionText = Color(0xFF1F6075);

  // Estado: Aprobado / Validado
  static const Color aprobadoDot = Color(0xFF1B9E54);
  static const Color aprobadoBg = Color(0xFFE6F6EC);
  static const Color aprobadoText = Color(0xFF15803D);

  // Estado: Rechazado
  static const Color rechazadoDot = Color(0xFFD9583C);
  static const Color rechazadoBg = Color(0xFFFBEAE6);
  static const Color rechazadoText = Color(0xFFB3402A);
}
