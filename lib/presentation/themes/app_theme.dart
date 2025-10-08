import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.lightBackground,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.lightBackground,
      foregroundColor: AppColors.textDark,
      elevation: 0,
    ),
    colorScheme: ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.secondary,

      surface: AppColors.lightBackground,
      onSurface: AppColors.textDark,

      secondaryContainer: const Color.fromARGB(255, 145, 156, 167),
      onSecondaryContainer: AppColors.textDark,

      onPrimary: AppColors.textLight,
      onSecondary: AppColors.textLight,

      error: Colors.red,
      onError: AppColors.textLight,
      outline: AppColors.textGrey,
    ),
    textTheme: TextTheme(
      displayLarge: AppTextStyles.headline1.copyWith(color: AppColors.textDark),
      displayMedium: AppTextStyles.headline2.copyWith(
        color: AppColors.textDark,
      ),
      displaySmall: AppTextStyles.headline3.copyWith(color: AppColors.textDark),
      headlineLarge: AppTextStyles.headline4.copyWith(
        color: AppColors.textDark,
      ),
      bodyLarge: AppTextStyles.body1.copyWith(color: AppColors.textDark),
      bodyMedium: AppTextStyles.body2.copyWith(color: AppColors.textDark),
      labelSmall: AppTextStyles.caption.copyWith(color: AppColors.textGrey),
    ),
    iconTheme: const IconThemeData(color: AppColors.lightIcon),
    cardTheme: CardThemeData(
      elevation: 4,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.darkBackground,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.darkSidebar,
      foregroundColor: AppColors.textLight,
      elevation: 0,
    ),
    colorScheme: ColorScheme.dark(
      primary: AppColors.primary,
      secondary: AppColors.secondary,

      surface: AppColors.darkSidebar,
      onSurface: AppColors.textLight,

      secondaryContainer: const Color.fromARGB(255, 136, 136, 153),
      onSecondaryContainer: AppColors.textLight,

      onPrimary: AppColors.textLight,
      onSecondary: AppColors.textLight,

      error: Colors.redAccent,
      onError: AppColors.textLight,
      outline: AppColors.darkIcon,
    ),
    textTheme: TextTheme(
      displayLarge: AppTextStyles.headline1.copyWith(
        color: AppColors.textLight,
      ),
      displayMedium: AppTextStyles.headline2.copyWith(
        color: AppColors.textLight,
      ),
      displaySmall: AppTextStyles.headline3.copyWith(
        color: AppColors.textLight,
      ),
      headlineLarge: AppTextStyles.headline4.copyWith(
        color: AppColors.textLight,
      ),
      bodyLarge: AppTextStyles.body1.copyWith(color: AppColors.textLight),
      bodyMedium: AppTextStyles.body2.copyWith(color: AppColors.textLight),
      labelSmall: AppTextStyles.caption.copyWith(color: AppColors.darkIcon),
    ),
    iconTheme: const IconThemeData(color: AppColors.darkIcon),
    cardTheme: CardThemeData(
      elevation: 6,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
  );
}
