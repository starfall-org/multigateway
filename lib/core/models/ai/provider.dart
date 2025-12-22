import 'dart:convert';
import 'ai/ai_model.dart';

enum ProviderType {
  openai("OpenAI"),
  google('Google'),
  anthropic("Anthropic"),
  ollama("Ollama");

  final String name;

  const ProviderType(this.name);
}

class Provider {
  final String name;
  final ProviderType type;
  final String apiKey;
  final String logoUrl;
  final String baseUrl;
  final OpenAIRoutes openAIRoutes;
  final bool vertexAI;
  final bool azureAI;
  final bool responsesApi;
  final VertexAIConfig? vertexAIConfig;
  final AzureConfig? azureConfig;
  final Map<String, String> headers;
  final List<AIModel> models;

  Provider({
    required this.type,
    String? name,
    this.apiKey = '',
    this.logoUrl = '',
    String? baseUrl,
    this.openAIRoutes = const OpenAIRoutes(),
    this.vertexAI = false,
    this.azureAI = false,
    this.responsesApi = false,
    this.vertexAIConfig,
    this.azureConfig,
    this.headers = const {},
    this.models = const [],
  }) : name = name ?? _defaultName(type),
       baseUrl = baseUrl ?? _defaultBaseUrl(type);

  static String _defaultName(ProviderType type) {
    switch (type) {
      case ProviderType.openai:
        return 'OpenAI';
      case ProviderType.anthropic:
        return 'Anthropic';
      case ProviderType.ollama:
        return 'Ollama';
      case ProviderType.google:
        return 'Google';
    }
  }

  static String _defaultBaseUrl(ProviderType type) {
    switch (type) {
      case ProviderType.openai:
        return 'https://api.openai.com/v1';
      case ProviderType.anthropic:
        return 'https://api.anthropic.com/v1';
      case ProviderType.ollama:
        return 'https://ollama.com';
      case ProviderType.google:
        return 'https://generativelanguage.googleapis.com/v1beta';
    }
  }

  // Helper method to get provider enum from string name
  static ProviderType? getTypeByName(String name) {
    try {
      return ProviderType.values.firstWhere((e) => e.name == name);
    } catch (_) {
      return null;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'name': name,
      'logoUrl': logoUrl,
      'apiKey': apiKey,
      'baseUrl': baseUrl,
      'headers': headers,
      'openAIRoutes': openAIRoutes.toJson(),
      'vertexAI': vertexAI,
      'azureAI': azureAI,
      'responsesApi': responsesApi,
      if (vertexAIConfig != null) 'vertexAIConfig': vertexAIConfig!.toJson(),
      if (azureConfig != null) 'azureConfig': azureConfig!.toJson(),
      'models': models.map((m) => m.toJson()).toList(),
    };
  }

  factory Provider.fromJson(Map<String, dynamic> json) {
    var modelsJson = json['models'];
    List<AIModel> parsedModels = [];

    if (modelsJson != null) {
      if (modelsJson is List &&
          modelsJson.isNotEmpty &&
          modelsJson.first is String) {
        parsedModels = modelsJson
            .map(
              (e) => AIModel(
                name: e as String,
                displayName: (e).replaceAll('-', ' '),
              ),
            )
            .toList();
      } else {
        parsedModels = (modelsJson as List)
            .map((e) => AIModel.fromJson(e))
            .toList();
      }
    }

    return Provider(
      type: ProviderType.values.firstWhere((e) => e.name == json['type']),
      name: json['name'] as String?,
      logoUrl: (json['logoUrl'] as String?) ?? '',
      apiKey: (json['apiKey'] as String?) ?? '',
      baseUrl: json['baseUrl'] as String?,
      openAIRoutes: json['openAIRoutes'] != null
          ? OpenAIRoutes.fromJson(json['openAIRoutes'])
          : const OpenAIRoutes(),
      vertexAI: json['vertexAI'] == true,
      azureAI: json['azureAI'] == true,
      responsesApi: json['responsesApi'] == true,
      vertexAIConfig: json['vertexAIConfig'] != null
          ? VertexAIConfig.fromJson(json['vertexAIConfig'])
          : null,
      azureConfig: json['azureConfig'] != null
          ? AzureConfig.fromJson(json['azureConfig'])
          : null,
      headers:
          (json['headers'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(key, value.toString()),
          ) ??
          {},
      models: parsedModels,
    );
  }

  String toJsonString() => json.encode(toJson());

  factory Provider.fromJsonString(String jsonString) =>
      Provider.fromJson(json.decode(jsonString));
}

class OpenAIRoutes {
  final String chatCompletion;
  final String modelsRouteOrUrl;

  const OpenAIRoutes({
    this.chatCompletion = '/chat/completions',
    this.modelsRouteOrUrl = '/models',
  });

  Map<String, dynamic> toJson() {
    return {
      'chatCompletion': chatCompletion,
      'modelsRouteOrUrl': modelsRouteOrUrl,
    };
  }

  static OpenAIRoutes fromJson(Map<String, dynamic> json) {
    return OpenAIRoutes(
      chatCompletion: json['chatCompletion'] ?? '/chat/completions',
      modelsRouteOrUrl: json['modelsRouteOrUrl'] ?? json['models'] ?? '/models',
    );
  }
}

class AnthropicRoutes {
  final String messages;
  final String models;
  final String anthropicVersion;

  const AnthropicRoutes({
    this.messages = '/messages',
    this.models = '/models',
    this.anthropicVersion = '2023-06-01',
  });

  Map<String, dynamic> toJson() {
    return {
      'messages': messages,
      'models': models,
      'anthropicVersion': anthropicVersion,
    };
  }

  static AnthropicRoutes fromJson(Map<String, dynamic> json) {
    return AnthropicRoutes(
      messages: json['messages'] ?? '/messages',
      models: json['models'] ?? '/models',
      anthropicVersion: json['anthropicVersion'] ?? '2023-06-01',
    );
  }
}

class OllamaRoutes {
  final String chat;
  final String tags;
  final String embeddings;

  const OllamaRoutes({
    this.chat = '/api/chat',
    this.tags = '/api/tags',
    this.embeddings = '/api/embeddings',
  });

  Map<String, dynamic> toJson() {
    return {'chat': chat, 'tags': tags, 'embeddings': embeddings};
  }

  static OllamaRoutes fromJson(Map<String, dynamic> json) {
    return OllamaRoutes(
      chat: json['chat'] ?? '/api/chat',
      tags: json['tags'] ?? '/api/tags',
      embeddings: json['embeddings'] ?? '/api/embeddings',
    );
  }
}

class GoogleRoutes {
  final String generateContent;
  final String streamGenerateContent;
  final String models;

  const GoogleRoutes({
    this.generateContent = '/v1beta/models/{model}:generateContent',
    this.streamGenerateContent = '/v1beta/models/{model}:streamGenerateContent',
    this.models = '/v1beta/models',
  });

  Map<String, dynamic> toJson() {
    return {
      'generateContent': generateContent,
      'streamGenerateContent': streamGenerateContent,
      'models': models,
    };
  }

  static GoogleRoutes fromJson(Map<String, dynamic> json) {
    return GoogleRoutes(
      generateContent:
          json['generateContent'] ?? '/v1beta/models/{model}:generateContent',
      streamGenerateContent:
          json['streamGenerateContent'] ??
          '/v1beta/models/{model}:streamGenerateContent',
      models: json['models'] ?? '/v1beta/models',
    );
  }
}

class VertexAIConfig {
  final String projectId;
  final String location;

  const VertexAIConfig({this.projectId = '', this.location = 'us-central1'});

  Map<String, dynamic> toJson() {
    return {'projectId': projectId, 'location': location};
  }

  static VertexAIConfig fromJson(Map<String, dynamic> json) {
    return VertexAIConfig(
      projectId: json['projectId'] ?? '',
      location: json['location'] ?? 'us-central1',
    );
  }
}

class AzureConfig {
  final String deploymentId;
  final String apiVersion;

  const AzureConfig({
    this.deploymentId = '',
    this.apiVersion = '2024-02-15-preview',
  });

  Map<String, dynamic> toJson() {
    return {'deploymentId': deploymentId, 'apiVersion': apiVersion};
  }

  static AzureConfig fromJson(Map<String, dynamic> json) {
    return AzureConfig(
      deploymentId: json['deploymentId'] ?? '',
      apiVersion: json['apiVersion'] ?? '2024-02-15-preview',
    );
  }
}
