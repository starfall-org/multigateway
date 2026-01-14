import 'dart:async';

import 'package:multigateway/core/speech/models/speech_service.dart';
import 'package:multigateway/core/storage/base.dart';

class SpeechServiceStorage extends HiveBaseStorage<SpeechService> {
  static const String _prefix = 'speech_service';

  static SpeechServiceStorage? _instance;
  static Future<SpeechServiceStorage>? _instanceFuture;

  SpeechServiceStorage();

  static Future<SpeechServiceStorage> get instance async {
    if (_instance != null) return _instance!;
    _instanceFuture ??= init();
    _instance = await _instanceFuture!;
    return _instance!;
  }

  static Future<SpeechServiceStorage> init() async {
    final instance = SpeechServiceStorage();
    // Ensure box is opened before returning
    await instance.ensureBoxReady();
    return instance;
  }

  @override
  String get prefix => _prefix;

  @override
  String getItemId(SpeechService item) => item.id;

  @override
  Map<String, dynamic> serializeToFields(SpeechService item) {
    return item.toJson();
  }

  @override
  SpeechService deserializeFromFields(String id, Map<String, dynamic> fields) {
    return SpeechService.fromJson(fields);
  }
}
