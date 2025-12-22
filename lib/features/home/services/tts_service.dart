import 'dart:async';
import 'package:flutter_tts/flutter_tts.dart';

class TTSService {
  FlutterTts? _tts;
  bool _isSpeaking = false;

  // Singleton pattern if needed, but for now we can rely on DI
  TTSService() {
    _initTts();
  }

  Future<void> _initTts() async {
    _tts = FlutterTts();
    await _tts?.setLanguage("en-US");
    await _tts?.setSpeechRate(0.5);
    await _tts?.setVolume(1.0);
    await _tts?.setPitch(1.0);

    _tts?.setStartHandler(() {
      _isSpeaking = true;
    });

    _tts?.setCompletionHandler(() {
      _isSpeaking = false;
    });

    _tts?.setCancelHandler(() {
      _isSpeaking = false;
    });

    _tts?.setErrorHandler((msg) {
      _isSpeaking = false;
      // print("TTS Error: $msg");
    });
  }

  bool get isSpeaking => _isSpeaking;

  Future<void> speak(String text) async {
    if (_tts == null) await _initTts();

    if (text.isNotEmpty) {
      await _tts?.speak(text);
    }
  }

  Future<void> stop() async {
    if (_tts != null) {
      await _tts?.stop();
    }
  }

  // Method to update config dynamically if needed
  Future<void> updateConfig({
    String? language,
    double? rate,
    double? volume,
    double? pitch,
  }) async {
    if (_tts == null) await _initTts();

    if (language != null) await _tts?.setLanguage(language);
    if (rate != null) await _tts?.setSpeechRate(rate);
    if (volume != null) await _tts?.setVolume(volume);
    if (pitch != null) await _tts?.setPitch(pitch);
  }

  void dispose() {
    _tts?.stop();
  }
}
