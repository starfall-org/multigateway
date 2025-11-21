import 'dart:convert';

enum ProviderType { google, openai, anthropic }

enum ModelCapability { textGeneration, imageGeneration, tts }

enum ModelIO { text, image, audio }

class ModelInfo {
  final String id;
  final List<ModelIO> inputTypes;
  final List<ModelIO> outputTypes;
  final List<ModelCapability> capabilities;

  ModelInfo({
    required this.id,
    this.inputTypes = const [ModelIO.text],
    this.outputTypes = const [ModelIO.text],
    this.capabilities = const [ModelCapability.textGeneration],
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'inputTypes': inputTypes.map((e) => e.name).toList(),
      'outputTypes': outputTypes.map((e) => e.name).toList(),
      'capabilities': capabilities.map((e) => e.name).toList(),
    };
  }

  factory ModelInfo.fromJson(Map<String, dynamic> json) {
    return ModelInfo(
      id: json['id'] as String,
      inputTypes:
          (json['inputTypes'] as List<dynamic>?)
              ?.map((e) => ModelIO.values.firstWhere((v) => v.name == e))
              .toList() ??
          [ModelIO.text],
      outputTypes:
          (json['outputTypes'] as List<dynamic>?)
              ?.map((e) => ModelIO.values.firstWhere((v) => v.name == e))
              .toList() ??
          [ModelIO.text],
      capabilities:
          (json['capabilities'] as List<dynamic>?)
              ?.map(
                (e) => ModelCapability.values.firstWhere((v) => v.name == e),
              )
              .toList() ??
          [ModelCapability.textGeneration],
    );
  }
}

class LLMProvider {
  final String id;
  final ProviderType type;
  final String name;
  final String apiKey;
  final String? baseUrl;
  final Map<String, String> headers;
  final List<ModelInfo> models;

  LLMProvider({
    required this.id,
    required this.type,
    required this.name,
    required this.apiKey,
    this.baseUrl,
    this.headers = const {},
    this.models = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'name': name,
      'apiKey': apiKey,
      'baseUrl': baseUrl,
      'headers': headers,
      'models': models.map((m) => m.toJson()).toList(),
    };
  }

  factory LLMProvider.fromJson(Map<String, dynamic> json) {
    var modelsJson = json['models'];
    List<ModelInfo> parsedModels = [];

    if (modelsJson != null) {
      if (modelsJson is List &&
          modelsJson.isNotEmpty &&
          modelsJson.first is String) {
        // Handle legacy List<String>
        parsedModels = modelsJson
            .map((e) => ModelInfo(id: e as String))
            .toList();
      } else {
        // Handle List<ModelInfo>
        parsedModels = (modelsJson as List)
            .map((e) => ModelInfo.fromJson(e))
            .toList();
      }
    }

    return LLMProvider(
      id: json['id'] as String,
      type: ProviderType.values.firstWhere((e) => e.name == json['type']),
      name: json['name'] as String,
      apiKey: json['apiKey'] as String,
      baseUrl: json['baseUrl'] as String?,
      headers: Map<String, String>.from(json['headers'] ?? {}),
      models: parsedModels,
    );
  }

  String toJsonString() => json.encode(toJson());

  factory LLMProvider.fromJsonString(String jsonString) =>
      LLMProvider.fromJson(json.decode(jsonString));
}
