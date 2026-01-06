import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dynamic_color/dynamic_color.dart';

import 'app_routes.dart';
import 'config/theme.dart';
import 'data/appearance.dart';

class MultiGatewayApp extends StatelessWidget {
  const MultiGatewayApp({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = AppearanceSp.instance;

    return ValueListenableBuilder(
      valueListenable: repository.themeNotifier,
      builder: (context, settings, _) {
        return DynamicColorBuilder(
          builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
            final bool useDynamic = settings.dynamicColor;

            final ColorScheme lightScheme = (useDynamic && lightDynamic != null)
                ? lightDynamic.harmonized()
                : ColorScheme.fromSeed(
                    seedColor: Color(settings.primaryColor),
                    brightness: Brightness.light,
                  ).copyWith(
                    secondary: Color(settings.secondaryColor),
                    surface: Color(settings.surfaceColor),
                  );

            final ColorScheme darkScheme = (useDynamic && darkDynamic != null)
                ? darkDynamic.harmonized()
                : ColorScheme.fromSeed(
                    seedColor: Color(settings.primaryColor),
                    brightness: Brightness.dark,
                  ).copyWith(
                    secondary: Color(settings.secondaryColor),
                    surface: Color(settings.surfaceColor),
                  );

            // Apply custom text colors only if they match the current brightness
            // Otherwise use ColorScheme defaults (fixes black text in dark mode when using system theme)
            final Color customTextColor = Color(settings.textColor);
            final Color customTextHintColor = Color(settings.textHintColor);

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
              title: 'AI Gateway',
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
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
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
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
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
                  contentTextStyle: TextStyle(
                    color: darkScheme.onSurfaceVariant,
                  ),
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
      },
    );
  }
}
