import 'package:material_ui/material_ui.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const primary = Color(0xFF0B4B50);
  static const mist = Color(0xFFB9D4D6);
  static const breeze = Color(0xFFC4E8D9);
  static const background = Color(0xFFF3F6F5);
  static const surface = Color(0xFFFFFFFF);
  static const text = Color(0xFF15383C);
  static const textSecondary = Color(0xFF607477);
  static const border = Color(0xFFD7E2E0);
  static const info = Color(0xFF376F8A);
  static const infoBackground = Color(0xFFE2EDF3);
  static const good = Color(0xFF23654D);
  static const moderate = Color(0xFF946012);
  static const poor = Color(0xFFB4522E);
  static const veryPoor = Color(0xFFA53443);
  static const severe = Color(0xFF704A78);
}

class AppDarkColors {
  static const primary = Color(0xFF94DDCE);
  static const mist = Color(0xFF779FA1);
  static const breeze = Color(0xFFC4E8D9);
  static const background = Color(0xFF101C20);
  static const surface = Color(0xFF1B2B30);
  static const text = Color(0xFFE6F2EF);
  static const textSecondary = Color(0xFFA8BFC0);
  static const border = Color(0xFF324D51);
  static const info = Color(0xFF87C6E4);
  static const infoBackground = Color(0xFF203747);
  static const good = Color(0xFF76D6A7);
  static const moderate = Color(0xFFE8BA68);
  static const poor = Color(0xFFF4A57A);
  static const veryPoor = Color(0xFFFF8592);
  static const severe = Color(0xFFCDA8E8);
}

class AppThemePalette {
  final Color primary;
  final Color onPrimary;
  final Color mist;
  final Color breeze;
  final Color background;
  final Color surface;
  final Color text;
  final Color textSecondary;
  final Color border;
  final Color info;
  final Color infoBackground;
  final Color good;
  final Color moderate;
  final Color poor;
  final Color veryPoor;
  final Color severe;

  const AppThemePalette({
    required this.primary,
    required this.onPrimary,
    required this.mist,
    required this.breeze,
    required this.background,
    required this.surface,
    required this.text,
    required this.textSecondary,
    required this.border,
    required this.info,
    required this.infoBackground,
    required this.good,
    required this.moderate,
    required this.poor,
    required this.veryPoor,
    required this.severe,
  });

  static const light = AppThemePalette(
    primary: AppColors.primary,
    onPrimary: Colors.white,
    mist: AppColors.mist,
    breeze: AppColors.breeze,
    background: AppColors.background,
    surface: AppColors.surface,
    text: AppColors.text,
    textSecondary: AppColors.textSecondary,
    border: AppColors.border,
    info: AppColors.info,
    infoBackground: AppColors.infoBackground,
    good: AppColors.good,
    moderate: AppColors.moderate,
    poor: AppColors.poor,
    veryPoor: AppColors.veryPoor,
    severe: AppColors.severe,
  );

  static const dark = AppThemePalette(
    primary: AppDarkColors.primary,
    onPrimary: Color(0xFF062B2D),
    mist: AppDarkColors.mist,
    breeze: AppDarkColors.breeze,
    background: AppDarkColors.background,
    surface: AppDarkColors.surface,
    text: AppDarkColors.text,
    textSecondary: AppDarkColors.textSecondary,
    border: AppDarkColors.border,
    info: AppDarkColors.info,
    infoBackground: AppDarkColors.infoBackground,
    good: AppDarkColors.good,
    moderate: AppDarkColors.moderate,
    poor: AppDarkColors.poor,
    veryPoor: AppDarkColors.veryPoor,
    severe: AppDarkColors.severe,
  );
}

class AppTheme {
  static ThemeData get light {
    return _createTheme(
      palette: AppThemePalette.light,
      brightness: Brightness.light,
    );
  }

  static ThemeData get dark {
    return _createTheme(
      palette: AppThemePalette.dark,
      brightness: Brightness.dark,
    );
  }

  static AppThemePalette paletteOf(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return brightness == Brightness.dark
        ? AppThemePalette.dark
        : AppThemePalette.light;
  }

  static ThemeData _createTheme({
    required AppThemePalette palette,
    required Brightness brightness,
  }) {
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: palette.background,
      dividerColor: palette.border,
      colorScheme:
          ColorScheme.fromSeed(
            seedColor: palette.primary,
            brightness: brightness,
          ).copyWith(
            primary: palette.primary,
            onPrimary: palette.onPrimary,
            secondary: palette.breeze,
            surface: palette.surface,
            onSurface: palette.text,
            outline: palette.border,
          ),
      textTheme: GoogleFonts.interTextTheme().apply(
        bodyColor: palette.text,
        displayColor: palette.text,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: palette.background,
        foregroundColor: palette.text,
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 0,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: palette.primary,
          foregroundColor: palette.onPrimary,
          minimumSize: const Size(0, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: palette.surface,
        labelStyle: TextStyle(color: palette.textSecondary),
        hintStyle: TextStyle(color: palette.textSecondary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: palette.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: palette.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: palette.primary, width: 2),
        ),
      ),
    );
  }
}
