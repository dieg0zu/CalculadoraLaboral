import 'package:flutter/material.dart';

/// Tema Material Design 3 — Calculadora Laboral Peruana.
///
/// Fondo gris medio, cajas de contenido blancas.
/// Azul para elementos interactivos (foco, selección, botones).
abstract final class AppTheme {
  static const Color kBlue = Color(0xFF007AFF); // Azul claro, llamativo (estilo iOS)
  static const Color kBackground = Color(0xFFE2E4E8); // gris medio-claro
  static const Color kSurface = Colors.white;
  static const Color kBorder = Color(0xFFCFD3DC);
  static const Color kTextPrimary = Color(0xFF1A1A2E);
  static const Color kTextSecondary = Color(0xFF6B7280);
  static const Color kTextHint = Color(0xFFB0B7C3);

  static ThemeData get light {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: kBlue,
      brightness: Brightness.light,
      primary: kBlue,
      surface: kSurface,
      surfaceContainerLowest: kSurface,
      surfaceContainerLow: const Color(0xFFF8F9FB),
      surfaceContainer: const Color(0xFFF0F2F5),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      fontFamily: 'Roboto',
      scaffoldBackgroundColor: kBackground,

      // ── AppBar — blanco ─────────────────────────────────────────
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        backgroundColor: kSurface,
        foregroundColor: kTextPrimary,
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: kTextPrimary,
          fontFamily: 'Roboto',
        ),
        iconTheme: IconThemeData(color: kTextPrimary),
        shape: Border(
          bottom: BorderSide(color: Color(0xFFDDE1E9), width: 1),
        ),
      ),

      // ── Cards — blanco con sombra sutil ──────────────────────────
      cardTheme: CardThemeData(
        color: kSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFE4E7ED), width: 1),
        ),
        shadowColor: const Color(0x14000000),
        clipBehavior: Clip.antiAlias,
      ),

      // ── Inputs — fondo blanco, borde gris, foco AZUL ────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: kSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: kBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: kBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: kBlue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE53935)),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        labelStyle: const TextStyle(color: kTextSecondary, fontSize: 14),
        hintStyle: const TextStyle(color: kTextHint, fontSize: 14),
        floatingLabelStyle: const TextStyle(color: kBlue, fontSize: 13),
        prefixIconColor: kTextSecondary,
        helperStyle: const TextStyle(color: kTextHint, fontSize: 11),
      ),

      // ── Botones elevados — AZUL ──────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: kBlue,
          foregroundColor: kSurface,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
          ),
        ),
      ),

      // ── TextButton ──────────────────────────────────────────────
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: kBlue,
          textStyle: const TextStyle(fontWeight: FontWeight.w500),
        ),
      ),

      // ── Divisores ───────────────────────────────────────────────
      dividerTheme: const DividerThemeData(
        color: Color(0xFFEAECF0),
        thickness: 1,
      ),

      // ── NavigationBar — blanco, selección azul ───────────────────
      navigationBarTheme: NavigationBarThemeData(
        elevation: 0,
        backgroundColor: kSurface,
        indicatorColor: kBlue.withValues(alpha: 0.12),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: kBlue,
            );
          }
          return const TextStyle(fontSize: 11, color: kTextSecondary);
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: kBlue);
          }
          return const IconThemeData(color: kTextHint);
        }),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
      ),

      // ── Chip ────────────────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFFEEF2FB),
        labelStyle: const TextStyle(
          color: kBlue,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: kBlue.withValues(alpha: 0.3)),
        ),
        padding: EdgeInsets.zero,
      ),

      // ── Switch — azul al activar ─────────────────────────────────
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return kSurface;
          return const Color(0xFFBBBFC8);
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return kBlue;
          return const Color(0xFFDDE1E9);
        }),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),
    );
  }

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: kBlue,
          brightness: Brightness.dark,
        ),
      );
}
