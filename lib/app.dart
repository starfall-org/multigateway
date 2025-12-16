import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'features/chat/presentation/chat_screen.dart';
import 'core/storage/theme_repository.dart';
import 'core/routes.dart';
import 'app_routes.dart';

class AIGatewayApp extends StatelessWidget {
  const AIGatewayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: ThemeRepository.init(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return MaterialApp(
            routes: {AppRoutes.chat: (context) => const ChatScreen()},
            home: const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
            debugShowCheckedModeBanner: false,
          );
        }

        final repository = snapshot.data as ThemeRepository;

        return ValueListenableBuilder(
          valueListenable: repository.themeNotifier,
          builder: (context, settings, _) {
            return MaterialApp(
              title: 'app_title'.tr(),
              debugShowCheckedModeBanner: false,
              themeMode: settings.themeMode,
              theme: ThemeData(
                colorScheme: ColorScheme.fromSeed(
                  seedColor: Color(settings.colorValue),
                  brightness: Brightness.light,
                ),
                useMaterial3: true,
                scaffoldBackgroundColor: Colors.white,
              ),
              darkTheme: ThemeData(
                colorScheme: ColorScheme.fromSeed(
                  seedColor: Color(settings.colorValue),
                  brightness: Brightness.dark,
                ),
                useMaterial3: true,
                scaffoldBackgroundColor: const Color(0xFF121212),
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
