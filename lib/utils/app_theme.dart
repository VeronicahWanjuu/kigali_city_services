import 'package:flutter/material.dart';
import 'constants.dart';


// I set the whole app's dark navy look in one place here.


class AppTheme {
  static ThemeData get darkTheme => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: kPrimaryDark,
    primaryColor: kAccentGold,
    colorScheme: const ColorScheme.dark(
      primary: kAccentGold, secondary: kAccentGold, surface: kCardDark,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: kPrimaryDark, elevation: 0,
      titleTextStyle: kHeadingMedium,
      iconTheme: IconThemeData(color: kTextPrimary),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: kPrimaryDark,
      selectedItemColor: kAccentGold,
      unselectedItemColor: kTextSecondary,
      type: BottomNavigationBarType.fixed,
    ),
    cardTheme: CardThemeData(
      color: kCardDark,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: kAccentGold, foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 16),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true, fillColor: kCardDark,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none,
      ),
      hintStyle: const TextStyle(color: kTextSecondary),
      labelStyle: const TextStyle(color: kTextSecondary),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: kCardDark, selectedColor: kAccentGold,
      labelStyle: const TextStyle(color: kTextPrimary),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    // I use WidgetStateProperty here because MaterialStateProperty no longer exists
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected) ? kAccentGold : kTextSecondary,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected)
            ? kAccentGold.withValues(alpha: 0.5)
            : kTextSecondary.withValues(alpha: 0.3),
      ),
    ),
  );
}
