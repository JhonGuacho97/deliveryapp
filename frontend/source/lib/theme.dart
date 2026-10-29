import 'package:flutter/material.dart';
import 'package:delivery_app/constants/constants.dart';

ThemeData lightThemeData(BuildContext context) => _theme(Brightness.light);
ThemeData darkThemeData(BuildContext context) => _theme(Brightness.dark);

ThemeData _theme(Brightness brightness) {
  final dark = brightness == Brightness.dark;
  final background = dark ? const Color(0xFF171D1A) : const Color(0xFFF7F7F2);
  final surface = dark ? const Color(0xFF222B25) : Colors.white;
  final text = dark ? kContentColorDarkTheme : kContentColorLightTheme;
  final muted = dark ? const Color(0xFFB5C3BA) : const Color(0xFF596660);
  final border = dark ? const Color(0xFF415047) : const Color(0xFFDFE5DF);
  final primary = dark ? const Color(0xFFA1C8B4) : kPrimaryColor;
  final tint = dark ? const Color(0xFF2B4034) : const Color(0xFFEAF2ED);
  final scheme =
      ColorScheme.fromSeed(
        seedColor: kPrimaryColor,
        brightness: brightness,
      ).copyWith(
        primary: primary,
        onPrimary: dark ? const Color(0xFF152D22) : Colors.white,
        primaryContainer: tint,
        onPrimaryContainer: dark ? const Color(0xFFD2E8DB) : kPrimaryColor,
        secondary: primary,
        onSecondary: dark ? const Color(0xFF152D22) : Colors.white,
        surface: surface,
        onSurface: text,
        onSurfaceVariant: muted,
        surfaceContainerLowest: surface,
        surfaceContainerLow: background,
        surfaceContainer: background,
        surfaceContainerHigh: tint,
        outline: muted,
        outlineVariant: border,
        error: dark ? const Color(0xFFFFB4AB) : kErrorColor,
      );
  final base = ThemeData(
    useMaterial3: true,
    brightness: brightness,
    fontFamily: 'Inter',
    colorScheme: scheme,
    scaffoldBackgroundColor: background,
  );
  final shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(18));
  final inputBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(20),
    borderSide: BorderSide(color: border),
  );
  return base.copyWith(
    primaryColor: primary,
    textTheme: base.textTheme
        .copyWith(
          headlineSmall: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w600,
            color: text,
          ),
          titleLarge: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: text,
          ),
          titleMedium: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: text,
          ),
          titleSmall: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: text,
          ),
          bodyLarge: TextStyle(fontSize: 16, height: 1.5, color: text),
          bodyMedium: TextStyle(fontSize: 16, height: 1.45, color: text),
          bodySmall: TextStyle(fontSize: 13, height: 1.45, color: muted),
        )
        .apply(fontFamily: 'Inter'),
    appBarTheme: AppBarTheme(
      centerTitle: false,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: background,
      foregroundColor: text,
      titleTextStyle: base.textTheme.titleLarge?.copyWith(
        color: text,
        fontWeight: FontWeight.w600,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: surface,
      margin: EdgeInsets.zero,
      shape: shape.copyWith(side: BorderSide(color: border)),
    ),
    dividerTheme: DividerThemeData(color: border, thickness: 1, space: 24),
    iconTheme: IconThemeData(color: muted, size: 24),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(0, 52),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: shape,
        textStyle: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(0, 52),
        foregroundColor: primary,
        side: BorderSide(color: border),
        shape: shape,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      border: inputBorder,
      enabledBorder: inputBorder,
      focusedBorder: inputBorder.copyWith(
        borderSide: BorderSide(color: primary, width: 1.5),
      ),
      disabledBorder: inputBorder,
      errorBorder: inputBorder.copyWith(
        borderSide: BorderSide(color: scheme.error),
      ),
      focusedErrorBorder: inputBorder.copyWith(
        borderSide: BorderSide(color: scheme.error, width: 1.5),
      ),
      errorMaxLines: 3,
      hintStyle: TextStyle(color: muted, fontSize: 16),
      prefixIconColor: muted,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: surface,
      surfaceTintColor: Colors.transparent,
      indicatorColor: tint,
      height: 76,
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => TextStyle(
          fontFamily: 'Inter',
          fontSize: 12,
          fontWeight: states.contains(WidgetState.selected)
              ? FontWeight.w600
              : FontWeight.w400,
          color: states.contains(WidgetState.selected) ? primary : muted,
        ),
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      elevation: 0,
      backgroundColor: surface,
      selectedItemColor: primary,
      unselectedItemColor: muted,
      showUnselectedLabels: true,
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: primary,
      linearTrackColor: tint,
    ),
  );
}
