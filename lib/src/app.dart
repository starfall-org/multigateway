import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'features/chat/presentation/chat_screen.dart';

class LMHubApp extends StatelessWidget {
  const LMHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'app_title'.tr(),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
      ),
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      home: const ChatScreen(),
    );
  }
}
