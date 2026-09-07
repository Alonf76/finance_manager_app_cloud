import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Warm & friendly design tokens, shared by [AppTheme.light] and [AppTheme.dark].
class AppColors {
  AppColors._();

  static const Color _lightBg = Color(0xFFFBF6F1);
  static const Color _lightSurface = Color(0xFFFEFCFA);
  static const Color _lightSurfaceTint = Color(0xFFF7E3D2);
  static const Color _lightInk = Color(0xFF3A2E27);
  static const Color _lightInkSoft = Color(0xFF73635A);
  static const Color _lightInkFaint = Color(0xFFA79A8F);
  static const Color _lightAccent = Color(0xFFE2793D);
  static const Color _lightAccentDeep = Color(0xFFC05F26);
  static const Color _lightAccentInk = Color(0xFFFFFDF9);
  static const Color _lightPositive = Color(0xFF4F9169);
  static const Color _lightPositiveBg = Color(0xFFDCEEE1);
  static const Color _lightNegative = Color(0xFFC24A3A);
  static const Color _lightNegativeBg = Color(0xFFF4DCD7);
  static const Color _lightLine = Color(0xFFE7DDD3);

  static const Color _darkBg = Color(0xFF201B17);
  static const Color _darkSurface = Color(0xFF2A2420);
  static const Color _darkSurfaceTint = Color(0xFF3B2B21);
  static const Color _darkInk = Color(0xFFF3ECE4);
  static const Color _darkInkSoft = Color(0xFFB8AA9E);
  static const Color _darkInkFaint = Color(0xFF8C7F73);
  static const Color _darkAccent = Color(0xFFEF9257);
  static const Color _darkAccentDeep = Color(0xFFF3A671);
  static const Color _darkAccentInk = Color(0xFF241A12);
  static const Color _darkPositive = Color(0xFF74B78D);
  static const Color _darkPositiveBg = Color(0xFF23352A);
  static const Color _darkNegative = Color(0xFFE08072);
  static const Color _darkNegativeBg = Color(0xFF3A2420);
  static const Color _darkLine = Color(0xFF3C352D);

  static AppPalette of(BuildContext context) =>
      Theme.of(context).extension<AppPalette>() ?? AppPalette.light;
}

/// Theme-extension bundle of the warm palette's non-Material tokens
/// (positive/negative amount colors, tinted surfaces, hairlines).
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.surfaceTint,
    required this.inkSoft,
    required this.inkFaint,
    required this.accentDeep,
    required this.positive,
    required this.positiveBg,
    required this.negative,
    required this.negativeBg,
    required this.line,
  });

  final Color surfaceTint;
  final Color inkSoft;
  final Color inkFaint;
  final Color accentDeep;
  final Color positive;
  final Color positiveBg;
  final Color negative;
  final Color negativeBg;
  final Color line;

  static const light = AppPalette(
    surfaceTint: AppColors._lightSurfaceTint,
    inkSoft: AppColors._lightInkSoft,
    inkFaint: AppColors._lightInkFaint,
    accentDeep: AppColors._lightAccentDeep,
    positive: AppColors._lightPositive,
    positiveBg: AppColors._lightPositiveBg,
    negative: AppColors._lightNegative,
    negativeBg: AppColors._lightNegativeBg,
    line: AppColors._lightLine,
  );

  static const dark = AppPalette(
    surfaceTint: AppColors._darkSurfaceTint,
    inkSoft: AppColors._darkInkSoft,
    inkFaint: AppColors._darkInkFaint,
    accentDeep: AppColors._darkAccentDeep,
    positive: AppColors._darkPositive,
    positiveBg: AppColors._darkPositiveBg,
    negative: AppColors._darkNegative,
    negativeBg: AppColors._darkNegativeBg,
    line: AppColors._darkLine,
  );

  @override
  AppPalette copyWith({
    Color? surfaceTint,
    Color? inkSoft,
    Color? inkFaint,
    Color? accentDeep,
    Color? positive,
    Color? positiveBg,
    Color? negative,
    Color? negativeBg,
    Color? line,
  }) {
    return AppPalette(
      surfaceTint: surfaceTint ?? this.surfaceTint,
      inkSoft: inkSoft ?? this.inkSoft,
      inkFaint: inkFaint ?? this.inkFaint,
      accentDeep: accentDeep ?? this.accentDeep,
      positive: positive ?? this.positive,
      positiveBg: positiveBg ?? this.positiveBg,
      negative: negative ?? this.negative,
      negativeBg: negativeBg ?? this.negativeBg,
      line: line ?? this.line,
    );
  }

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) return this;
    return AppPalette(
      surfaceTint: Color.lerp(surfaceTint, other.surfaceTint, t)!,
      inkSoft: Color.lerp(inkSoft, other.inkSoft, t)!,
      inkFaint: Color.lerp(inkFaint, other.inkFaint, t)!,
      accentDeep: Color.lerp(accentDeep, other.accentDeep, t)!,
      positive: Color.lerp(positive, other.positive, t)!,
      positiveBg: Color.lerp(positiveBg, other.positiveBg, t)!,
      negative: Color.lerp(negative, other.negative, t)!,
      negativeBg: Color.lerp(negativeBg, other.negativeBg, t)!,
      line: Color.lerp(line, other.line, t)!,
    );
  }
}

class AppTheme {
  AppTheme._();

  static ThemeData get light => _build(
        brightness: Brightness.light,
        bg: AppColors._lightBg,
        surface: AppColors._lightSurface,
        ink: AppColors._lightInk,
        accent: AppColors._lightAccent,
        accentInk: AppColors._lightAccentInk,
        palette: AppPalette.light,
      );

  static ThemeData get dark => _build(
        brightness: Brightness.dark,
        bg: AppColors._darkBg,
        surface: AppColors._darkSurface,
        ink: AppColors._darkInk,
        accent: AppColors._darkAccent,
        accentInk: AppColors._darkAccentInk,
        palette: AppPalette.dark,
      );

  static ThemeData _build({
    required Brightness brightness,
    required Color bg,
    required Color surface,
    required Color ink,
    required Color accent,
    required Color accentInk,
    required AppPalette palette,
  }) {
    final base = TextTheme(
      headlineMedium: TextStyle(fontWeight: FontWeight.w800, color: ink, letterSpacing: -0.015),
      headlineSmall: TextStyle(fontWeight: FontWeight.w800, color: ink, letterSpacing: -0.01),
      titleLarge: TextStyle(fontWeight: FontWeight.w800, color: ink),
      titleMedium: TextStyle(fontWeight: FontWeight.w700, color: ink),
      titleSmall: TextStyle(fontWeight: FontWeight.w700, color: palette.inkSoft),
      bodyLarge: TextStyle(fontWeight: FontWeight.w500, color: ink),
      bodyMedium: TextStyle(fontWeight: FontWeight.w500, color: ink),
      bodySmall: TextStyle(fontWeight: FontWeight.w600, color: palette.inkSoft),
      labelLarge: TextStyle(fontWeight: FontWeight.w700, color: ink),
    );
    final textTheme = GoogleFonts.plusJakartaSansTextTheme(base);

    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: accent,
      onPrimary: accentInk,
      secondary: palette.positive,
      onSecondary: accentInk,
      error: palette.negative,
      onError: accentInk,
      surface: surface,
      onSurface: ink,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: bg,
      colorScheme: colorScheme,
      textTheme: textTheme,
      fontFamily: GoogleFonts.plusJakartaSans().fontFamily,
      extensions: [palette],
      appBarTheme: AppBarTheme(
        backgroundColor: bg,
        foregroundColor: ink,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: textTheme.headlineSmall?.copyWith(fontSize: 20),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: palette.line, width: 1.5),
        ),
        margin: EdgeInsets.zero,
      ),
      dividerTheme: DividerThemeData(color: palette.line, thickness: 1, space: 1),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: palette.line, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: palette.line, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: accent, width: 1.75),
        ),
        labelStyle: TextStyle(color: palette.inkSoft, fontWeight: FontWeight.w600),
        hintStyle: TextStyle(color: palette.inkFaint, fontWeight: FontWeight.w500),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: accentInk,
          minimumSize: const Size.fromHeight(54),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w700),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: ink,
          minimumSize: const Size.fromHeight(54),
          side: BorderSide(color: palette.line, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w700),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: accent,
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: accent,
        foregroundColor: accentInk,
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        showDragHandle: false,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected) ? accentInk : surface,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected) ? accent : palette.line,
        ),
        trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: palette.inkSoft,
        textColor: ink,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: ink,
        contentTextStyle: TextStyle(color: bg, fontWeight: FontWeight.w600),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: accent,
        circularTrackColor: palette.line,
        linearTrackColor: palette.negativeBg,
      ),
      dividerColor: palette.line,
      iconTheme: IconThemeData(color: palette.inkSoft),
    );
  }
}
