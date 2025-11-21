import 'package:flutter/material.dart';
import 'features/chat/presentation/chat_screen.dart';

class LMHubApp extends StatelessWidget {
  const LMHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LMHub',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const ChatScreen(),
    );
  }
}
