import 'package:flutter/material.dart';

/// Fleet Sarthi blue on white: blue app bars and actions, white surfaces, blue-tinted
/// neutrals. Mirrors the admin web's palette (Tailwind blue scale).
abstract final class TaxcyColors {
  static const blue50 = Color(0xFFEFF6FF);
  static const blue100 = Color(0xFFDBEAFE);
  static const blue200 = Color(0xFFBFDBFE);
  static const blue300 = Color(0xFF93C5FD);
  static const blue600 = Color(0xFF2563EB);
  static const blue700 = Color(0xFF1D4ED8);
  static const blue800 = Color(0xFF1E40AF);
  static const blue900 = Color(0xFF1E3A8A);
  static const blue950 = Color(0xFF172554);

  /// App background: white with a hint of blue, so white cards stand out.
  static const background = Color(0xFFF4F8FF);
  static const border = Color(0xFFD9E3F3);
  static const ink = Color(0xFF121B2F);
  static const muted = Color(0xFF637594);
}

/// The palette for the current brightness, read as `context.tc`.
///
/// Light is [TaxcyColors] exactly. Dark flips the blue scale around the brand
/// blues, so code keeps its meaning in both: blue50–300 are tints for
/// backgrounds and borders (pale in light, deep in dark), blue800–950 are
/// strong text (dark in light, pale in dark), and blue600–700 are the brand
/// accent (a little brighter in dark). [TaxcyColors] stay fixed: use them for
/// brand surfaces that look the same in both, like the hero gradients and the
/// white text on them.
@immutable
class TaxcyPalette extends ThemeExtension<TaxcyPalette> {
  const TaxcyPalette({
    required this.brightness,
    required this.blue50,
    required this.blue100,
    required this.blue200,
    required this.blue300,
    required this.blue600,
    required this.blue700,
    required this.blue800,
    required this.blue900,
    required this.blue950,
    required this.background,
    required this.surface,
    required this.border,
    required this.ink,
    required this.muted,
  });

  static const light = TaxcyPalette(
    brightness: Brightness.light,
    blue50: TaxcyColors.blue50,
    blue100: TaxcyColors.blue100,
    blue200: TaxcyColors.blue200,
    blue300: TaxcyColors.blue300,
    blue600: TaxcyColors.blue600,
    blue700: TaxcyColors.blue700,
    blue800: TaxcyColors.blue800,
    blue900: TaxcyColors.blue900,
    blue950: TaxcyColors.blue950,
    background: TaxcyColors.background,
    surface: Colors.white,
    border: TaxcyColors.border,
    ink: TaxcyColors.ink,
    muted: TaxcyColors.muted,
  );

  static const dark = TaxcyPalette(
    brightness: Brightness.dark,
    blue50: Color(0xFF15203A),
    blue100: Color(0xFF1B2A4D),
    blue200: Color(0xFF263B6A),
    blue300: Color(0xFF3B5A99),
    blue600: Color(0xFF5B95F8),
    blue700: Color(0xFF4D8BF7),
    blue800: Color(0xFF8DB4FA),
    blue900: Color(0xFFB4CDFC),
    blue950: Color(0xFFDCE7FE),
    background: Color(0xFF0B1220),
    surface: Color(0xFF131C2E),
    border: Color(0xFF263452),
    ink: Color(0xFFE5EBF5),
    muted: Color(0xFF94A3BD),
  );

  final Brightness brightness;
  final Color blue50;
  final Color blue100;
  final Color blue200;
  final Color blue300;
  final Color blue600;
  final Color blue700;
  final Color blue800;
  final Color blue900;
  final Color blue950;

  /// The page behind cards.
  final Color background;

  /// Cards, sheets, fields and other raised surfaces (white in light).
  final Color surface;
  final Color border;

  /// Body text.
  final Color ink;

  /// Secondary text and icons.
  final Color muted;

  bool get isDark => brightness == Brightness.dark;

  @override
  TaxcyPalette copyWith() => this;

  @override
  TaxcyPalette lerp(TaxcyPalette? other, double t) =>
      other == null || t < 0.5 ? this : other;
}

/// Status colours for dark surfaces. In light mode, code keeps its own
/// Material shades; `context.adaptive(light, TaxcyDark.x)` picks between them.
abstract final class TaxcyDark {
  static const good = Color(0xFF4ADE80);
  static const goodBg = Color(0xFF12301F);
  static const warn = Color(0xFFFBBF24);
  static const warnBg = Color(0xFF3A2A0C);
  static const bad = Color(0xFFF87171);
  static const badBg = Color(0xFF3B1518);
  static const badBorder = Color(0xFF7F2A2E);
}

extension TaxcyThemeContext on BuildContext {
  /// The palette for the current theme (light or dark).
  TaxcyPalette get tc =>
      Theme.of(this).extension<TaxcyPalette>() ?? TaxcyPalette.light;

  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  /// [light] in the light theme, [dark] in the dark one.
  Color adaptive(Color light, Color dark) => isDark ? dark : light;
}

/// The handwritten accent for a hook word or two: Caveat, a little larger than
/// [base] since it runs small. It has no Devanagari, so Hindi falls back to the
/// app's Hindi font at the base size.
TextStyle accentStyle(BuildContext context, TextStyle base) {
  final latin = Localizations.localeOf(context).languageCode != 'hi';
  if (!latin) return base;
  return base.copyWith(
    fontFamily: 'Caveat',
    fontSize: (base.fontSize ?? 14) * 1.3,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
    fontVariations: const [FontVariation('wght', 700)],
  );
}

/// The app's theme; [brightness] picks the light or dark [TaxcyPalette].
ThemeData buildTheme([Brightness brightness = Brightness.light]) {
  final dark = brightness == Brightness.dark;
  final p = dark ? TaxcyPalette.dark : TaxcyPalette.light;
  final scheme =
      ColorScheme.fromSeed(
        seedColor: TaxcyColors.blue700,
        brightness: brightness,
      ).copyWith(
        primary: p.blue700,
        onPrimary: Colors.white,
        primaryContainer: p.blue100,
        onPrimaryContainer: p.blue950,
        secondary: p.blue600,
        onSecondary: Colors.white,
        secondaryContainer: p.blue100,
        onSecondaryContainer: p.blue900,
        surface: p.surface,
        onSurface: p.ink,
        onSurfaceVariant: p.muted,
        surfaceContainerLowest: p.surface,
        surfaceContainerLow: p.blue50,
        surfaceContainer: p.blue50,
        surfaceContainerHigh: p.blue100,
        surfaceContainerHighest: dark ? p.blue200 : null,
        outline: p.blue300,
        outlineVariant: p.border,
        error: dark ? TaxcyDark.bad : null,
        onError: dark ? const Color(0xFF2B0B0D) : null,
        errorContainer: dark ? TaxcyDark.badBg : null,
        onErrorContainer: dark ? TaxcyDark.bad : null,
      );

  final rounded = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12),
  );
  OutlineInputBorder field(Color color, [double width = 1]) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: color, width: width),
      );

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    fontFamily: 'Inter',
    // Bundled for the web build (Hindi and Marathi, then Kannada); phones use
    // their own fonts for these scripts first.
    fontFamilyFallback: const ['NotoSansDevanagari', 'NotoSansKannada'],
    colorScheme: scheme,
    extensions: [p],
    scaffoldBackgroundColor: p.background,
    // The brand bar: Fleet Sarthi blue, deeper in the dark theme.
    appBarTheme: AppBarTheme(
      backgroundColor: dark ? TaxcyColors.blue950 : TaxcyColors.blue800,
      foregroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 2,
      titleTextStyle: const TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),
    cardTheme: CardThemeData(
      color: p.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: dark ? p.border : p.blue100),
      ),
    ),
    // Light keeps Material's defaults; dark sets its own surfaces.
    dialogTheme: dark
        ? DialogThemeData(
            backgroundColor: p.blue50,
            surfaceTintColor: Colors.transparent,
          )
        : null,
    popupMenuTheme: dark
        ? PopupMenuThemeData(
            color: p.blue50,
            surfaceTintColor: Colors.transparent,
          )
        : null,
    menuTheme: dark
        ? MenuThemeData(
            style: MenuStyle(
              backgroundColor: WidgetStatePropertyAll(p.blue50),
              surfaceTintColor: const WidgetStatePropertyAll(
                Colors.transparent,
              ),
            ),
          )
        : null,
    datePickerTheme: dark
        ? DatePickerThemeData(
            backgroundColor: p.blue50,
            surfaceTintColor: Colors.transparent,
            headerBackgroundColor: p.blue100,
            headerForegroundColor: p.ink,
          )
        : null,
    timePickerTheme: dark
        ? TimePickerThemeData(backgroundColor: p.blue50)
        : null,
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: p.surface,
      border: field(p.border),
      enabledBorder: field(p.border),
      focusedBorder: field(p.blue600, 2),
      errorBorder: field(scheme.error),
      focusedErrorBorder: field(scheme.error, 2),
      labelStyle: TextStyle(color: p.muted),
      floatingLabelStyle: TextStyle(color: p.blue700),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        // Solid brand blue with white text in both themes.
        backgroundColor: TaxcyColors.blue700,
        foregroundColor: Colors.white,
        disabledBackgroundColor: dark ? p.blue100 : null,
        disabledForegroundColor: dark ? p.muted : null,
        minimumSize: const Size(64, 48),
        shape: rounded,
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: dark ? p.blue100 : null,
        foregroundColor: dark ? p.blue900 : null,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: p.blue700,
        side: BorderSide(color: p.blue300),
        minimumSize: const Size(64, 44),
        shape: rounded,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: p.blue700),
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: SegmentedButton.styleFrom(
        selectedBackgroundColor: p.blue100,
        selectedForegroundColor: p.blue900,
        side: BorderSide(color: p.blue200),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: TaxcyColors.blue700,
      foregroundColor: Colors.white,
    ),
    listTileTheme: ListTileThemeData(iconColor: p.blue700),
    dividerTheme: DividerThemeData(color: p.border),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: dark ? p.blue100 : TaxcyColors.blue900,
      contentTextStyle: TextStyle(color: dark ? p.ink : Colors.white),
      actionTextColor: dark ? p.blue800 : null,
      behavior: SnackBarBehavior.floating,
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: p.surface,
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    ),
    navigationBarTheme: dark
        ? NavigationBarThemeData(
            backgroundColor: p.surface,
            indicatorColor: p.blue100,
            surfaceTintColor: Colors.transparent,
          )
        : null,
    navigationRailTheme: dark
        ? NavigationRailThemeData(
            backgroundColor: p.surface,
            indicatorColor: p.blue100,
          )
        : null,
    chipTheme: ChipThemeData(
      backgroundColor: p.blue50,
      side: BorderSide(color: p.blue100),
      labelStyle: TextStyle(color: p.blue900),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(color: p.blue700),
    textTheme: TextTheme(
      titleLarge: TextStyle(color: p.blue950, fontWeight: FontWeight.w600),
      titleMedium: TextStyle(color: p.ink, fontWeight: FontWeight.w600),
      titleSmall: TextStyle(
        color: p.blue800,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
      ),
    ),
  );
}
