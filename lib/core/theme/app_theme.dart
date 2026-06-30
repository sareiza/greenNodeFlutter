import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/app_colors.dart';

/// Escala tipográfica de GreenNode.
/// Fuente: design_handoff_greennode/README.md → Design Tokens → Tipografía.
class AppTextStyles {
  AppTextStyles._();

  static TextStyle get _titulo => GoogleFonts.plusJakartaSans();
  static TextStyle get _cuerpo => GoogleFonts.hankenGrotesk();

  /// Título de vista — Plus Jakarta Sans 26/700.
  static TextStyle get tituloVista => _titulo.copyWith(
        fontSize: 26,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        color: AppColors.ink,
      );

  /// Título de tarjeta — Plus Jakarta Sans 20–21/700.
  static TextStyle get tituloTarjeta => _titulo.copyWith(
        fontSize: 21,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
        color: AppColors.ink,
      );

  /// Número grande — Plus Jakarta Sans 26–34/800.
  static TextStyle get numeroGrande => _titulo.copyWith(
        fontSize: 34,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.5,
        color: AppColors.ink,
      );

  /// Subtítulo/label — Hanken Grotesk 13/600.
  static TextStyle get subtituloLabel => _cuerpo.copyWith(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.ink,
      );

  /// Cuerpo — Hanken Grotesk 14–15/400.
  static TextStyle get cuerpo => _cuerpo.copyWith(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: AppColors.textMuted,
      );

  /// Metadato/caption — Hanken Grotesk 11–13/500.
  static TextStyle get metadato => _cuerpo.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.textSubtle,
      );

  /// Eyebrow (uppercase) — Hanken Grotesk 11–12/600, letterSpacing 0.08em.
  static TextStyle get eyebrow => _cuerpo.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.96, // ≈ 0.08em sobre 12px
        color: AppColors.textMuted,
      );

  /// Botón — Hanken Grotesk 15/600.
  static TextStyle get boton => _cuerpo.copyWith(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      );
}

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        surface: AppColors.surfaceTint,
      ),
      scaffoldBackgroundColor: AppColors.bgPage,
    );

    return base.copyWith(
      textTheme: base.textTheme.copyWith(
        headlineSmall: AppTextStyles.tituloVista,
        titleLarge: AppTextStyles.tituloTarjeta,
        displaySmall: AppTextStyles.numeroGrande,
        labelLarge: AppTextStyles.subtituloLabel,
        bodyMedium: AppTextStyles.cuerpo,
        bodySmall: AppTextStyles.metadato,
        labelSmall: AppTextStyles.eyebrow,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceTint,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11),
          borderSide: const BorderSide(color: AppColors.inputBorder, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11),
          borderSide: const BorderSide(color: AppColors.inputBorder, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        hintStyle: AppTextStyles.cuerpo.copyWith(color: AppColors.placeholder),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          textStyle: AppTextStyles.boton,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
          padding: const EdgeInsets.symmetric(vertical: 16),
          elevation: 0,
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected) ? AppColors.primary : null,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) =>
              states.contains(WidgetState.selected) ? AppColors.primary.withValues(alpha: 0.5) : null,
        ),
      ),
      sliderTheme: const SliderThemeData(
        activeTrackColor: AppColors.primary,
        thumbColor: AppColors.primary,
      ),
      dividerTheme: const DividerThemeData(color: AppColors.line, thickness: 1),
    );
  }
}
