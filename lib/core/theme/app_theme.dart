import 'package:flutter/material.dart';

class AppColors {
  static const navy = Color(0xFF0D2137);
  static const sand = Color(0xFFF5EFE6);
  static const gold = Color(0xFFC5A059);
  static const darkCard = Color(0xFF16304A);
}

ThemeData buildTheme({required bool dark}) {
  final bg = dark ? AppColors.navy : AppColors.sand;
  final scheme = ColorScheme.fromSeed(
    seedColor: AppColors.navy,
    brightness: dark ? Brightness.dark : Brightness.light,
  ).copyWith(
    primary: dark ? AppColors.gold : AppColors.navy,
    onPrimary: dark ? AppColors.navy : Colors.white,
    secondary: AppColors.gold,
    surface: dark ? AppColors.darkCard : Colors.white,
    onSurface: dark ? AppColors.sand : AppColors.navy,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: bg,
    cardColor: scheme.surface,
    dialogTheme: DialogThemeData(backgroundColor: scheme.surface),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
    ),
  );
}
