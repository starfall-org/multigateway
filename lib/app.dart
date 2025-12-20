import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'core/storage/appearances_repository.dart';
import 'core/models/appearances.dart';
import 'core/theme_extensions.dart';
import 'core/routes.dart';
import 'app_routes.dart';

class AIGatewayApp extends StatelessWidget {
  const AIGatewayApp({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = AppearancesRepository.instance;

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
                  );

            final ColorScheme darkScheme = (useDynamic && darkDynamic != null)
                ? darkDynamic.harmonized()
                : ColorScheme.fromSeed(
                    seedColor: Color(settings.primaryColor),
                    brightness: Brightness.dark,
                  ).copyWith(
                    secondary: Color(settings.secondaryColor),
                  );

            // Main background colors
            final Color lightMainBg = Colors.white;
            final Color darkMainBg =
                settings.superDarkMode ? Colors.black : const Color(0xFF121212);

            // Utilities for secondary background calculation
            Color autoSecondary(Color base, Brightness br) {
              final hsl = HSLColor.fromColor(base);
              final double delta = br == Brightness.dark ? 0.06 : -0.04;
              final double newLightness = (hsl.lightness + delta).clamp(0.0, 1.0);
              return hsl.withLightness(newLightness).toColor();
            }

            Color deriveSecondaryBg(
              Brightness br,
              ColorScheme scheme,
              Color mainBg,
            ) {
              switch (settings.secondaryBackgroundMode) {
                case SecondaryBackgroundMode.on:
                  // Stronger separation using container tone
                  return scheme.secondaryContainer;
                case SecondaryBackgroundMode.auto:
                  // Subtle delta from main background
                  return autoSecondary(mainBg, br);
                case SecondaryBackgroundMode.off:
                  // Same as main background
                  return mainBg;
              }
            }

            Color borderFor(Color bg) =>
                (bg.computeLuminance() < 0.5) ? Colors.white : Colors.black;

            // Light palette surfaces
            final Color lightSecondaryBg =
                deriveSecondaryBg(Brightness.light, lightScheme, lightMainBg);
            final BorderSide? lightBorderSide =
                settings.secondaryBackgroundMode == SecondaryBackgroundMode.off
                    ? BorderSide(color: borderFor(lightMainBg), width: 1)
                    : null;

            // Dark palette surfaces
            final Color darkSecondaryBg =
                deriveSecondaryBg(Brightness.dark, darkScheme, darkMainBg);
            final BorderSide? darkBorderSide =
                settings.secondaryBackgroundMode == SecondaryBackgroundMode.off
                    ? BorderSide(color: borderFor(darkMainBg), width: 1)
                    : null;

            return MaterialApp(
              title: 'app_title'.tr(),
              debugShowCheckedModeBanner: false,
              themeMode: settings.themeMode,
              theme: ThemeData(
                colorScheme: lightScheme,
                useMaterial3: true,
                scaffoldBackgroundColor: lightMainBg,
                appBarTheme: const AppBarTheme(
                  systemOverlayStyle: SystemUiOverlayStyle(
                    statusBarColor: Colors.transparent,
                    statusBarIconBrightness: Brightness.dark,
                    systemNavigationBarColor: Colors.transparent,
                    systemNavigationBarDividerColor: Colors.transparent,
                    systemNavigationBarIconBrightness: Brightness.dark,
                  ),
                ),
                dialogTheme: DialogThemeData(
                  backgroundColor: lightSecondaryBg,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: lightBorderSide ?? BorderSide.none,
                  ),
                ),
                drawerTheme: DrawerThemeData(
                  backgroundColor: lightSecondaryBg,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                    side: lightBorderSide ?? BorderSide.none,
                  ),
                ),
                navigationDrawerTheme: NavigationDrawerThemeData(
                  backgroundColor: lightSecondaryBg,
                ),
                extensions: <ThemeExtension<dynamic>>[
                  SecondarySurface(
                    backgroundColor: lightSecondaryBg,
                    borderSide: lightBorderSide,
                  ),
                ],
              ),
              darkTheme: ThemeData(
                colorScheme: darkScheme,
                useMaterial3: true,
                scaffoldBackgroundColor: darkMainBg,
                appBarTheme: const AppBarTheme(
                  systemOverlayStyle: SystemUiOverlayStyle(
                    statusBarColor: Colors.transparent,
                    statusBarIconBrightness: Brightness.light,
                    systemNavigationBarColor: Colors.transparent,
                    systemNavigationBarDividerColor: Colors.transparent,
                    systemNavigationBarIconBrightness: Brightness.light,
                  ),
                ),
                dialogTheme: DialogThemeData(
                  backgroundColor: darkSecondaryBg,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: darkBorderSide ?? BorderSide.none,
                  ),
                ),
                drawerTheme: DrawerThemeData(
                  backgroundColor: darkSecondaryBg,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                    side: darkBorderSide ?? BorderSide.none,
                  ),
                ),
                navigationDrawerTheme: NavigationDrawerThemeData(
                  backgroundColor: darkSecondaryBg,
                ),
                extensions: <ThemeExtension<dynamic>>[
                  SecondarySurface(
                    backgroundColor: darkSecondaryBg,
                    borderSide: darkBorderSide,
                  ),
                ],
              ),
              localizationsDelegates: context.localizationDelegates,
              supportedLocales: context.supportedLocales,
              locale: context.locale,
              onGenerateRoute: generateRoute,
              initialRoute: AppRoutes.chat,
            );
          },
        );
      },
    );
  }
}
