import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,

    scaffoldBackgroundColor: AppColors.lightBackground,

    shadowColor: AppColors.shadowLight,

    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.lightBackground,
      foregroundColor: AppColors.textDark,
      elevation: 1,
      shadowColor: AppColors.appBarShadowLight,
    ),

    cardTheme: CardThemeData(
      elevation: 16,
      shadowColor: AppColors.cardShadowLight,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),

    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      surface: AppColors.lightBackground,
      onSurface: AppColors.textDark,
      secondaryContainer: AppColors.lightSecondaryContainer,
      onSecondaryContainer: AppColors.textLight,
      onPrimary: AppColors.textLight,
      onSecondary: AppColors.textLight,
      error: AppColors.errorLight,
      onError: AppColors.textLight,
      outline: AppColors.textGrey,
    ),

    textTheme: TextTheme(
      displayLarge: AppTextStyles.headline1.copyWith(color: AppColors.textDark),
      displayMedium: AppTextStyles.headline2.copyWith(color: AppColors.textDark),
      displaySmall: AppTextStyles.headline3.copyWith(color: AppColors.textDark),
      headlineLarge: AppTextStyles.headline4.copyWith(color: AppColors.textDark),
      bodyLarge: AppTextStyles.body1.copyWith(color: AppColors.textDark),
      bodyMedium: AppTextStyles.body2.copyWith(color: AppColors.textDark),
      labelSmall: AppTextStyles.caption.copyWith(color: AppColors.textGrey),
    ),

    inputDecorationTheme: InputDecorationTheme(
      hintStyle: AppTextStyles.topNavbarLabel.copyWith(color: AppColors.hintText),
    ),

    sliderTheme: const SliderThemeData(
      inactiveTrackColor: AppColors.inactiveTrackLight,
    ),

    iconTheme: const IconThemeData(color: AppColors.lightIcon),
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,

    scaffoldBackgroundColor: AppColors.darkBackground,

    shadowColor: AppColors.shadowDark,

    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.darkSidebar,
      foregroundColor: AppColors.textLight,
      elevation: 1,
      shadowColor: AppColors.appBarShadowDark,
    ),

    cardTheme: CardThemeData(
      elevation: 12,
      shadowColor: AppColors.cardShadowDark,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),

    colorScheme: const ColorScheme.dark(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      surface: AppColors.darkSidebar,
      onSurface: AppColors.textLight,
      secondaryContainer: AppColors.darkSecondaryContainer,
      onSecondaryContainer: AppColors.textLight,
      onPrimary: AppColors.textLight,
      onSecondary: AppColors.textLight,
      error: AppColors.errorDark,
      onError: AppColors.textLight,
      outline: AppColors.darkIcon,
    ),

    textTheme: TextTheme(
      displayLarge: AppTextStyles.headline1.copyWith(color: AppColors.textLight),
      displayMedium: AppTextStyles.headline2.copyWith(color: AppColors.textLight),
      displaySmall: AppTextStyles.headline3.copyWith(color: AppColors.textLight),
      headlineLarge: AppTextStyles.headline4.copyWith(color: AppColors.textLight),
      bodyLarge: AppTextStyles.body1.copyWith(color: AppColors.textLight),
      bodyMedium: AppTextStyles.body2.copyWith(color: AppColors.textLight),
      labelSmall: AppTextStyles.caption.copyWith(color: AppColors.darkIcon),
    ),

    inputDecorationTheme: InputDecorationTheme(
      hintStyle: AppTextStyles.topNavbarLabel.copyWith(color: AppColors.hintText),
    ),

    sliderTheme: const SliderThemeData(
      inactiveTrackColor: AppColors.inactiveTrackDark,
    ),
    
    iconTheme: const IconThemeData(color: AppColors.darkIcon),
  );
}