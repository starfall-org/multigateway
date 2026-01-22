import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:multigateway/app/app_routes.dart';
import 'package:multigateway/app/config/theme.dart';
import 'package:multigateway/app/storage/appearance_storage.dart';
import 'package:signals/signals_flutter.dart';

/// Build a consistent light ColorScheme when dynamic color is disabled.
ColorScheme _buildLightColorScheme({
  required Color primaryColor,
  required Color secondaryColor,
}) {
  // Ensure primary color has good contrast in light mode
  final HSLColor primaryHsl = HSLColor.fromColor(primaryColor);
  final Color adjustedPrimary = primaryHsl.lightness > 0.6
      ? primaryHsl.withLightness(0.45).toColor()
      : primaryHsl
            .withLightness((primaryHsl.lightness * 0.9).clamp(0.3, 0.55))
            .toColor();

  // Adjust secondary color similarly
  final HSLColor secondaryHsl = HSLColor.fromColor(secondaryColor);
  final Color adjustedSecondary = secondaryHsl.lightness > 0.6
      ? secondaryHsl.withLightness(0.5).toColor()
      : secondaryHsl
            .withLightness((secondaryHsl.lightness * 0.9).clamp(0.35, 0.6))
            .toColor();

  // Create soft container colors
  final Color primaryContainer = HSLColor.fromColor(
    primaryColor,
  ).withLightness(0.9).withSaturation(0.5).toColor();
  final Color secondaryContainer = HSLColor.fromColor(
    secondaryColor,
  ).withLightness(0.88).withSaturation(0.45).toColor();

  return ColorScheme(
    brightness: Brightness.light,
    primary: adjustedPrimary,
    onPrimary: Colors.white,
    primaryContainer: primaryContainer,
    onPrimaryContainer: HSLColor.fromColor(
      primaryColor,
    ).withLightness(0.2).toColor(),
    secondary: adjustedSecondary,
    onSecondary: Colors.white,
    secondaryContainer: secondaryContainer,
    onSecondaryContainer: HSLColor.fromColor(
      secondaryColor,
    ).withLightness(0.25).toColor(),
    tertiary: adjustedSecondary.withValues(alpha: 0.9),
    onTertiary: Colors.white,
    tertiaryContainer: secondaryContainer.withValues(alpha: 0.8),
    onTertiaryContainer: const Color(0xFF2D2D2D),
    error: const Color(0xFFBA1A1A),
    onError: Colors.white,
    errorContainer: const Color(0xFFFFDAD6),
    onErrorContainer: const Color(0xFF410002),
    surface: Colors.white,
    onSurface: const Color(0xFF1C1B1F),
    surfaceContainerLowest: Colors.white,
    surfaceContainerLow: const Color(0xFFF7F7F7),
    surfaceContainer: const Color(0xFFF3F3F3),
    surfaceContainerHigh: const Color(0xFFEDEDED),
    surfaceContainerHighest: const Color(0xFFE6E6E6),
    onSurfaceVariant: const Color(0xFF49454F),
    outline: const Color(0xFF79747E),
    outlineVariant: const Color(0xFFCAC4D0),
    shadow: Colors.black,
    scrim: Colors.black,
    inverseSurface: const Color(0xFF313033),
    onInverseSurface: const Color(0xFFF4EFF4),
    inversePrimary: HSLColor.fromColor(
      primaryColor,
    ).withLightness(0.75).toColor(),
  );
}

/// Build a consistent dark ColorScheme when dynamic color is disabled.
/// This ensures good contrast and readability across all UI elements.
ColorScheme _buildDarkColorScheme({
  required Color primaryColor,
  required Color secondaryColor,
  required bool superDarkMode,
}) {
  // Base surface colors - consistent gray scale for dark mode
  final Color surface = superDarkMode
      ? const Color(0xFF000000)
      : const Color(0xFF121212);
  final Color surfaceContainerLowest = superDarkMode
      ? const Color(0xFF000000)
      : const Color(0xFF0D0D0D);
  final Color surfaceContainerLow = superDarkMode
      ? const Color(0xFF0A0A0A)
      : const Color(0xFF1A1A1A);
  final Color surfaceContainer = superDarkMode
      ? const Color(0xFF141414)
      : const Color(0xFF1E1E1E);
  final Color surfaceContainerHigh = superDarkMode
      ? const Color(0xFF1E1E1E)
      : const Color(0xFF252525);
  final Color surfaceContainerHighest = superDarkMode
      ? const Color(0xFF282828)
      : const Color(0xFF2C2C2C);

  // Ensure primary color has good contrast in dark mode
  // Lighten if too dark (luminance < 0.3)
  final HSLColor primaryHsl = HSLColor.fromColor(primaryColor);
  final Color adjustedPrimary = primaryHsl.lightness < 0.4
      ? primaryHsl.withLightness(0.65).toColor()
      : primaryHsl
            .withLightness((primaryHsl.lightness * 0.8 + 0.5).clamp(0.5, 0.8))
            .toColor();

  // Adjust secondary color similarly
  final HSLColor secondaryHsl = HSLColor.fromColor(secondaryColor);
  final Color adjustedSecondary = secondaryHsl.lightness < 0.4
      ? secondaryHsl.withLightness(0.6).toColor()
      : secondaryHsl
            .withLightness(
              (secondaryHsl.lightness * 0.8 + 0.45).clamp(0.45, 0.75),
            )
            .toColor();

  // Create muted container colors from primary/secondary
  final Color primaryContainer = HSLColor.fromColor(
    primaryColor,
  ).withLightness(0.25).withSaturation(0.4).toColor();
  final Color secondaryContainer = HSLColor.fromColor(
    secondaryColor,
  ).withLightness(0.22).withSaturation(0.35).toColor();

  // Text colors with good contrast
  const Color onSurface = Color(0xFFE6E6E6);
  const Color onSurfaceVariant = Color(0xFFB3B3B3);
  const Color outline = Color(0xFF737373);
  const Color outlineVariant = Color(0xFF404040);

  return ColorScheme(
    brightness: Brightness.dark,
    primary: adjustedPrimary,
    onPrimary: _contrastingTextColor(adjustedPrimary),
    primaryContainer: primaryContainer,
    onPrimaryContainer: const Color(0xFFE0E0E0),
    secondary: adjustedSecondary,
    onSecondary: _contrastingTextColor(adjustedSecondary),
    secondaryContainer: secondaryContainer,
    onSecondaryContainer: const Color(0xFFDCDCDC),
    tertiary: adjustedSecondary.withValues(alpha: 0.8),
    onTertiary: Colors.white,
    tertiaryContainer: secondaryContainer.withValues(alpha: 0.7),
    onTertiaryContainer: const Color(0xFFD8D8D8),
    error: const Color(0xFFFFB4AB),
    onError: const Color(0xFF690005),
    errorContainer: const Color(0xFF93000A),
    onErrorContainer: const Color(0xFFFFDAD6),
    surface: surface,
    onSurface: onSurface,
    surfaceContainerLowest: surfaceContainerLowest,
    surfaceContainerLow: surfaceContainerLow,
    surfaceContainer: surfaceContainer,
    surfaceContainerHigh: surfaceContainerHigh,
    surfaceContainerHighest: surfaceContainerHighest,
    onSurfaceVariant: onSurfaceVariant,
    outline: outline,
    outlineVariant: outlineVariant,
    shadow: Colors.black,
    scrim: Colors.black,
    inverseSurface: const Color(0xFFE6E1E5),
    onInverseSurface: const Color(0xFF1C1B1F),
    inversePrimary: primaryColor,
  );
}

/// Returns black or white text color based on background luminance
Color _contrastingTextColor(Color background) {
  return background.computeLuminance() > 0.5
      ? const Color(0xFF1A1A1A)
      : const Color(0xFFF5F5F5);
}

class MultiGatewayApp extends StatelessWidget {
  final AppearanceStorage appearanceStorage;

  const MultiGatewayApp({super.key, required this.appearanceStorage});

  @override
  Widget build(BuildContext context) {
    return Watch((context) {
      final settings = appearanceStorage.theme.value;

      return DynamicColorBuilder(
        builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
          final bool useDynamic = settings.dynamicColor;

          final ColorScheme lightScheme = (useDynamic && lightDynamic != null)
              ? lightDynamic.harmonized()
              : _buildLightColorScheme(
                  primaryColor: Color(settings.colors.primaryColor),
                  secondaryColor: Color(settings.colors.secondaryColor),
                );

          final ColorScheme darkScheme = (useDynamic && darkDynamic != null)
              ? darkDynamic.harmonized()
              : _buildDarkColorScheme(
                  primaryColor: Color(settings.colors.primaryColor),
                  secondaryColor: Color(settings.colors.secondaryColor),
                  superDarkMode: settings.superDarkMode,
                );

          // Apply custom text colors only if they match the current brightness
          // Otherwise use ColorScheme defaults (fixes black text in dark mode when using system theme)
          final Color customTextColor = Color(settings.colors.textColor);
          final Color customTextHintColor = Color(
            settings.colors.textHintColor,
          );

          final bool useCustomTextColor =
              (lightScheme.brightness == Brightness.light &&
                  customTextColor.computeLuminance() < 0.5) ||
              (lightScheme.brightness == Brightness.dark &&
                  customTextColor.computeLuminance() > 0.5);

          final TextTheme customLightTextTheme = useCustomTextColor
              ? const TextTheme().apply(
                  bodyColor: customTextColor,
                  displayColor: customTextColor,
                )
              : const TextTheme();

          final bool useCustomTextColorDark =
              (darkScheme.brightness == Brightness.light &&
                  customTextColor.computeLuminance() < 0.5) ||
              (darkScheme.brightness == Brightness.dark &&
                  customTextColor.computeLuminance() > 0.5);

          final TextTheme customDarkTextTheme = useCustomTextColorDark
              ? const TextTheme().apply(
                  bodyColor: customTextColor,
                  displayColor: customTextColor,
                )
              : const TextTheme();

          // Update hint colors in the theme
          final bool useCustomHintColor =
              (lightScheme.brightness == Brightness.light &&
                  customTextHintColor.computeLuminance() < 0.5) ||
              (lightScheme.brightness == Brightness.dark &&
                  customTextHintColor.computeLuminance() > 0.5);
          final InputDecorationTheme lightInputDecorationTheme =
              InputDecorationTheme(
                hintStyle: useCustomHintColor
                    ? TextStyle(color: customTextHintColor)
                    : null,
              );

          final bool useCustomHintColorDark =
              (darkScheme.brightness == Brightness.light &&
                  customTextHintColor.computeLuminance() < 0.5) ||
              (darkScheme.brightness == Brightness.dark &&
                  customTextHintColor.computeLuminance() > 0.5);
          final InputDecorationTheme darkInputDecorationTheme =
              InputDecorationTheme(
                hintStyle: useCustomHintColorDark
                    ? TextStyle(color: customTextHintColor)
                    : null,
              );

          // Main background colors
          final Color lightMainBg = Colors.white;
          final Color darkMainBg = settings.superDarkMode
              ? Colors.black
              : const Color(0xFF121212);

          // Utilities for secondary background calculation

          Color deriveSecondaryBg(
            Brightness br,
            ColorScheme scheme,
            Color mainBg,
          ) {
            // AMOLED: Nếu đang ở Dark Mode và nền chính được thiết lập là đen tuyệt đối (#000000),
            // ta cũng dùng đen cho vùng phụ để đảm bảo tính nhất quán của màn hình AMOLED.
            if (br == Brightness.dark && mainBg.value == 0xFF000000) {
              return Colors.black;
            }
            return scheme.secondaryContainer;
          }

          // Light palette surfaces
          final Color lightSecondaryBg = deriveSecondaryBg(
            Brightness.light,
            lightScheme,
            lightMainBg,
          );

          // Dark palette surfaces
          final Color darkSecondaryBg = deriveSecondaryBg(
            Brightness.dark,
            darkScheme,
            darkMainBg,
          );

          return MaterialApp(
            title: 'MultiGateway',
            debugShowCheckedModeBanner: false,
            themeMode: settings.themeMode,
            theme: ThemeData(
              colorScheme: lightScheme,
              useMaterial3: true,
              textTheme: customLightTextTheme,
              inputDecorationTheme: lightInputDecorationTheme,
              scaffoldBackgroundColor: lightMainBg,
              appBarTheme: const AppBarTheme(
                systemOverlayStyle: SystemUiOverlayStyle(
                  statusBarColor: Colors.transparent,
                  statusBarIconBrightness: Brightness.dark,
                  systemNavigationBarColor: Colors.transparent,
                  systemNavigationBarDividerColor: Colors.transparent,
                  systemNavigationBarIconBrightness: Brightness.dark,
                  systemNavigationBarContrastEnforced: false,
                ),
              ),
              dialogTheme: DialogThemeData(
                backgroundColor: lightSecondaryBg,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              drawerTheme: DrawerThemeData(
                backgroundColor: lightSecondaryBg,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
              ),
              navigationDrawerTheme: NavigationDrawerThemeData(
                backgroundColor: lightSecondaryBg,
              ),
              extensions: <ThemeExtension<dynamic>>[
                SecondarySurface(backgroundColor: lightSecondaryBg),
              ],
              snackBarTheme: SnackBarThemeData(
                behavior: SnackBarBehavior.floating,
                backgroundColor: lightScheme.surfaceContainerHighest,
                contentTextStyle: TextStyle(
                  color: lightScheme.onSurfaceVariant,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 6,
              ),
            ),
            darkTheme: ThemeData(
              colorScheme: darkScheme,
              useMaterial3: true,
              textTheme: customDarkTextTheme,
              inputDecorationTheme: darkInputDecorationTheme,
              scaffoldBackgroundColor: darkMainBg,
              appBarTheme: const AppBarTheme(
                systemOverlayStyle: SystemUiOverlayStyle(
                  statusBarColor: Colors.transparent,
                  statusBarIconBrightness: Brightness.light,
                  systemNavigationBarColor: Colors.transparent,
                  systemNavigationBarDividerColor: Colors.transparent,
                  systemNavigationBarIconBrightness: Brightness.light,
                  systemNavigationBarContrastEnforced: false,
                ),
              ),
              dialogTheme: DialogThemeData(
                backgroundColor: darkSecondaryBg,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              drawerTheme: DrawerThemeData(
                backgroundColor: darkSecondaryBg,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
              ),
              navigationDrawerTheme: NavigationDrawerThemeData(
                backgroundColor: darkSecondaryBg,
              ),
              extensions: <ThemeExtension<dynamic>>[
                SecondarySurface(backgroundColor: darkSecondaryBg),
              ],
              snackBarTheme: SnackBarThemeData(
                behavior: SnackBarBehavior.floating,
                backgroundColor: darkScheme.surfaceContainerHighest,
                contentTextStyle: TextStyle(color: darkScheme.onSurfaceVariant),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 6,
              ),
            ),
            onGenerateRoute: generateRoute,
            initialRoute: '/',
          );
        },
      );
    });
  }
}
