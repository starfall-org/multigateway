import 'package:flutter_tts/flutter_tts.dart';
import 'package:multigateway/core/speech/models/speech_service.dart';
import 'package:multigateway/core/speech/storage/speech_service_storage.dart';

class SpeechManager {
  final SpeechServiceStorage storage;
  final FlutterTts _flutterTts = FlutterTts();

  SpeechManager({required this.storage}) {
    _initTts();
  }

  Future<void> _initTts() async {
    await _flutterTts.setSharedInstance(true);
    await _flutterTts.awaitSpeakCompletion(true);
  }

  Future<void> speak(String text) async {
    final config = await _loadConfig();
    if (config != null) {
      await _applyConfig(config.tts);
    }
    await _flutterTts.speak(text);
  }

  Future<void> stop() async {
    await _flutterTts.stop();
  }

  Future<void> setLanguage(String language) async {
    await _flutterTts.setLanguage(language);
  }

  Future<void> setSpeechRate(double rate) async {
    await _flutterTts.setSpeechRate(rate);
  }

  Future<void> setVolume(double volume) async {
    await _flutterTts.setVolume(volume);
  }

  Future<void> setPitch(double pitch) async {
    await _flutterTts.setPitch(pitch);
  }

  Future<SpeechService?> _loadConfig() async {
    final items = storage.getItems();
    if (items.isEmpty) return null;
    return items.first;
  }

  Future<void> _applyConfig(TextToSpeech config) async {
    if (config.settings['language'] != null) {
      await _flutterTts.setLanguage(config.settings['language']);
    }
    if (config.settings['speechRate'] != null) {
      await _flutterTts.setSpeechRate(
        (config.settings['speechRate'] as num).toDouble(),
      );
    }
    if (config.settings['volume'] != null) {
      await _flutterTts.setVolume(
        (config.settings['volume'] as num).toDouble(),
      );
    }
    if (config.settings['pitch'] != null) {
      await _flutterTts.setPitch(
        (config.settings['pitch'] as num).toDouble(),
      );
    }
  }
}
