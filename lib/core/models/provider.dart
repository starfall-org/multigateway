import 'dart:convert';
import 'ai_model.dart';

enum ProviderType {
  google('Google'),
  openai("OpenAI"),
  anthropic("Anthropic"),
  ollama("Ollama");

  final String name;

  const ProviderType(this.name);
}

class OpenAIRoutes {
  final String chatCompletion;
  final String responses;
  final String embeddings;
  final String models;
  final String imagesGenerations;
  final String imagesEdits;
  final String videos;
  final String audioSpeech;

  const OpenAIRoutes({
    this.chatCompletion = '/chat/completions',
    this.responses = '/responses',
    this.embeddings = '/embeddings',
    this.models = '/models',
    this.imagesGenerations = '/images/generations',
    this.imagesEdits = '/images/edits',
    this.videos = '/videos',
    this.audioSpeech = '/audio/speech',
  });

  Map<String, dynamic> toJson() {
    return {
      'chatCompletion': chatCompletion,
      'responses': responses,
      'embeddings': embeddings,
      'models': models,
      'imagesGenerations': imagesGenerations,
      'imagesEdits': imagesEdits,
      'videos': videos,
      'audioSpeech': audioSpeech,
    };
  }

  static OpenAIRoutes fromJson(Map<String, dynamic> json) {
    return OpenAIRoutes(
      chatCompletion: json['chatCompletion'] ?? '/chat/completions',
      responses: json['responses'] ?? '/responses',
      embeddings: json['embeddings'] ?? '/embeddings',
      models: json['models'] ?? '/models',
      imagesGenerations: json['imagesGenerations'] ?? '/images/generations',
      imagesEdits: json['imagesEdits'] ?? '/images/edits',
      videos: json['videos'] ?? '/videos',
      audioSpeech: json['audioSpeech'] ?? '/audio/speech',
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
    return {
      'chat': chat,
      'tags': tags,
      'embeddings': embeddings,
    };
  }

  static OllamaRoutes fromJson(Map<String, dynamic> json) {
    return OllamaRoutes(
      chat: json['chat'] ?? '/api/chat',
      tags: json['tags'] ?? '/api/tags',
      embeddings: json['embeddings'] ?? '/api/embeddings',
    );
  }
}

class Provider {
  final String name;
  final ProviderType type;
  final String apiKey;
  final String logoUrl;
  final String baseUrl;
  final OpenAIRoutes openAIRoutes;
  final AnthropicRoutes anthropicRoutes;
  final OllamaRoutes ollamaRoutes;
  final Map<String, String> headers;
  final List<AIModel> models;

  Provider({
    required this.type,
    String? name,
    this.apiKey = '',
    this.logoUrl = '',
    String? baseUrl,
    this.openAIRoutes = const OpenAIRoutes(),
    this.anthropicRoutes = const AnthropicRoutes(),
    this.ollamaRoutes = const OllamaRoutes(),
    this.headers = const {},
    this.models = const [],
  })  : name = name ?? _defaultName(type),
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

  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'name': name,
      'logoUrl': logoUrl,
      'apiKey': apiKey,
      'baseUrl': baseUrl,
      'headers': headers,
      'openAIRoutes': openAIRoutes.toJson(),
      'anthropicRoutes': anthropicRoutes.toJson(),
      'ollamaRoutes': ollamaRoutes.toJson(),
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
            .map((e) => AIModel(name: e as String))
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
      anthropicRoutes: json['anthropicRoutes'] != null
          ? AnthropicRoutes.fromJson(json['anthropicRoutes'])
          : const AnthropicRoutes(),
      ollamaRoutes: json['ollamaRoutes'] != null
          ? OllamaRoutes.fromJson(json['ollamaRoutes'])
          : const OllamaRoutes(),
      headers: (json['headers'] as Map<String, dynamic>?)
              ?.map((key, value) => MapEntry(key, value.toString())) ??
          {},
      models: parsedModels,
    );
  }

  String toJsonString() => json.encode(toJson());

  factory Provider.fromJsonString(String jsonString) =>
      Provider.fromJson(json.decode(jsonString));
}
