import 'dart:convert';

enum ProviderType { gemini, openai, anthropic, ollama }

enum ModelType {
  textGeneration,
  imageGeneration,
  audioGeneration,
  videoGeneration,
  embedding,
  rerank,
}

enum IOType { text, video, image, audio, document }

class ModelInfo {
  final String name;
  final ModelType type;
  final List<IOType> input;
  final List<IOType> output;
  final bool tool;
  final bool reasoning;

  ModelInfo({
    required this.name,
    this.type = ModelType.textGeneration,
    this.input = const [IOType.text],
    this.output = const [IOType.text],
    this.tool = true,
    this.reasoning = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type.name,
      'input': input.map((e) => e.name).toList(),
      'output': output.map((e) => e.name).toList(),
      'tool': tool,
      'reasoning': reasoning,
    };
  }

  factory ModelInfo.fromJson(Map<String, dynamic> json) {
    return ModelInfo(
      name: json['name'] as String,
      type: ModelType.values.firstWhere((e) => e.name == json['type']),
      input:
          (json['input'] as List<dynamic>?)
              ?.map((e) => IOType.values.firstWhere((v) => v.name == e))
              .toList() ??
          [IOType.text],
      output:
          (json['output'] as List<dynamic>?)
              ?.map((e) => IOType.values.firstWhere((v) => v.name == e))
              .toList() ??
          [IOType.text],
      tool: json['tool'] ?? true,
      reasoning: json['reasoning'] ?? false,
    );
  }
}

class Provider {
  final String name;
  final ProviderType type;
  final String? apiKey;
  final String? logoUrl;
  final String? baseUrl;
  final Map<String, String> headers;
  final List<ModelInfo> models;

  Provider({
    required this.type,
    required this.name,
    this.apiKey,
    this.logoUrl,
    this.baseUrl,
    this.headers = const {},
    this.models = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'name': name,
      'logoUrl': logoUrl,
      'apiKey': apiKey,
      'baseUrl': baseUrl,
      'headers': headers,
      'models': models.map((m) => m.toJson()).toList(),
    };
  }

  factory Provider.fromJson(Map<String, dynamic> json) {
    var modelsJson = json['models'];
    List<ModelInfo> parsedModels = [];

    if (modelsJson != null) {
      if (modelsJson is List &&
          modelsJson.isNotEmpty &&
          modelsJson.first is String) {
        parsedModels = modelsJson
            .map((e) => ModelInfo(name: e as String))
            .toList();
      } else {
        parsedModels = (modelsJson as List)
            .map((e) => ModelInfo.fromJson(e))
            .toList();
      }
    }

    return Provider(
      type: ProviderType.values.firstWhere((e) => e.name == json['type']),
      name: json['name'] as String,
      logoUrl: json['logoUrl'] as String?,
      apiKey: json['apiKey'] as String?,
      baseUrl: json['baseUrl'] as String?,
      headers: Map<String, String>.from(json['headers'] ?? {}),
      models: parsedModels,
    );
  }

  String toJsonString() => json.encode(toJson());

  factory Provider.fromJsonString(String jsonString) =>
      Provider.fromJson(json.decode(jsonString));
}
