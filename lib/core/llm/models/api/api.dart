enum AIContentType { text, image, audio, video }

class AIContent {
  final AIContentType type;
  final String? text;
  final String? uri;
  final String? filePath;
  final String? mimeType;
  final String? dataBase64;

  const AIContent({
    required this.type,
    this.text,
    this.uri,
    this.filePath,
    this.mimeType,
    this.dataBase64,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'text': text,
      'uri': uri,
      'filePath': filePath,
      'mimeType': mimeType,
      if (dataBase64 != null) 'dataBase64': dataBase64,
    };
  }

  factory AIContent.fromJson(Map<String, dynamic> json) {
    return AIContent(
      type: AIContentType.values.firstWhere(
        (e) => e.name == (json['type'] as String? ?? 'text'),
        orElse: () => AIContentType.text,
      ),
      text: json['text'] as String?,
      uri: json['uri'] as String?,
      filePath: json['filePath'] as String?,
      mimeType: json['mimeType'] as String?,
      dataBase64: json['dataBase64'] as String?,
    );
  }
}

class AIToolFunction {
  final String name;
  final String? description;
  final Map<String, dynamic> parameters;

  const AIToolFunction({
    required this.name,
    this.description,
    this.parameters = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      if (description != null) 'description': description,
      'parameters': parameters,
    };
  }

  factory AIToolFunction.fromJson(Map<String, dynamic> json) {
    return AIToolFunction(
      name: json['name'] as String,
      description: json['description'] as String?,
      parameters:
          (json['parameters'] as Map?)?.cast<String, dynamic>() ?? const {},
    );
  }
}

class AIToolCall {
  final String id;
  final String name;
  final Map<String, dynamic> arguments;

  const AIToolCall({
    required this.id,
    required this.name,
    this.arguments = const {},
  });

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'arguments': arguments};
  }

  factory AIToolCall.fromJson(Map<String, dynamic> json) {
    return AIToolCall(
      id: json['id'] as String,
      name: json['name'] as String,
      arguments:
          (json['arguments'] as Map?)?.cast<String, dynamic>() ?? const {},
    );
  }
}

class AIMessage {
  final String role; // system/developer | user | assistant | tool
  final List<AIContent> content;
  final String? name;
  final String? toolCallId;

  const AIMessage({
    required this.role,
    required this.content,
    this.name,
    this.toolCallId,
  });

  Map<String, dynamic> toJson() {
    return {
      'role': role,
      'content': content.map((c) => c.toJson()).toList(),
      if (name != null) 'name': name,
      if (toolCallId != null) 'toolCallId': toolCallId,
    };
  }

  factory AIMessage.fromJson(Map<String, dynamic> json) {
    return AIMessage(
      role: json['role'] as String,
      content: (json['content'] as List? ?? const [])
          .map((e) => AIContent.fromJson((e as Map).cast<String, dynamic>()))
          .toList(),
      name: json['name'] as String?,
      toolCallId: json['toolCallId'] as String?,
    );
  }
}

class AIRequest {
  final String model;
  final List<AIMessage> messages;
  final List<AIToolFunction> tools;
  final String? toolChoice; // 'auto' | 'none' | function name
  final List<AIContent> images;
  final List<AIContent> audios;
  final List<AIContent> files;
  final double? temperature;
  final int? maxTokens;
  final bool stream;
  final Map<String, dynamic> extra;

  const AIRequest({
    required this.model,
    required this.messages,
    this.tools = const [],
    this.toolChoice,
    this.images = const [],
    this.audios = const [],
    this.files = const [],
    this.temperature,
    this.maxTokens,
    this.stream = false,
    this.extra = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'model': model,
      'messages': messages.map((m) => m.toJson()).toList(),
      if (tools.isNotEmpty) 'tools': tools.map((t) => t.toJson()).toList(),
      if (toolChoice != null) 'toolChoice': toolChoice,
      if (images.isNotEmpty) 'images': images.map((e) => e.toJson()).toList(),
      if (audios.isNotEmpty) 'audios': audios.map((e) => e.toJson()).toList(),
      if (files.isNotEmpty) 'files': files.map((e) => e.toJson()).toList(),
      if (temperature != null) 'temperature': temperature,
      if (maxTokens != null) 'maxTokens': maxTokens,
      'stream': stream,
      if (extra.isNotEmpty) 'extra': extra,
    };
  }

  factory AIRequest.fromJson(Map<String, dynamic> json) {
    return AIRequest(
      model: json['model'] as String,
      messages: (json['messages'] as List? ?? const [])
          .map((e) => AIMessage.fromJson((e as Map).cast<String, dynamic>()))
          .toList(),
      tools: (json['tools'] as List? ?? const [])
          .map(
            (e) => AIToolFunction.fromJson((e as Map).cast<String, dynamic>()),
          )
          .toList(),
      toolChoice: json['toolChoice'] as String?,
      images: (json['images'] as List? ?? const [])
          .map((e) => AIContent.fromJson((e as Map).cast<String, dynamic>()))
          .toList(),
      audios: (json['audios'] as List? ?? const [])
          .map((e) => AIContent.fromJson((e as Map).cast<String, dynamic>()))
          .toList(),
      files: (json['files'] as List? ?? const [])
          .map((e) => AIContent.fromJson((e as Map).cast<String, dynamic>()))
          .toList(),
      temperature: (json['temperature'] as num?)?.toDouble(),
      maxTokens: json['maxTokens'] as int?,
      stream: json['stream'] as bool? ?? false,
      extra: (json['extra'] as Map?)?.cast<String, dynamic>() ?? const {},
    );
  }
}

class AIResponse {
  final String text;
  final List<AIToolCall> toolCalls;
  final String? finishReason;
  final List<AIContent> contents;
  final String? reasoningContent;
  final Map<String, dynamic> raw;

  const AIResponse({
    required this.text,
    this.toolCalls = const [],
    this.finishReason,
    this.contents = const [],
    this.reasoningContent,
    this.raw = const {},
  });

  AIResponse copyWith({
    String? text,
    List<AIToolCall>? toolCalls,
    String? finishReason,
    List<AIContent>? contents,
    String? reasoningContent,
    Map<String, dynamic>? raw,
  }) {
    return AIResponse(
      text: text ?? this.text,
      toolCalls: toolCalls ?? this.toolCalls,
      finishReason: finishReason ?? this.finishReason,
      contents: contents ?? this.contents,
      reasoningContent: reasoningContent ?? this.reasoningContent,
      raw: raw ?? this.raw,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'toolCalls': toolCalls.map((t) => t.toJson()).toList(),
      if (finishReason != null) 'finishReason': finishReason,
      if (contents.isNotEmpty)
        'contents': contents.map((c) => c.toJson()).toList(),
      if (reasoningContent != null) 'reasoningContent': reasoningContent,
      if (raw.isNotEmpty) 'raw': raw,
    };
  }

  factory AIResponse.fromJson(Map<String, dynamic> json) {
    return AIResponse(
      text: json['text'] as String? ?? '',
      toolCalls: (json['toolCalls'] as List? ?? const [])
          .map((e) => AIToolCall.fromJson((e as Map).cast<String, dynamic>()))
          .toList(),
      finishReason: json['finishReason'] as String?,
      contents: (json['contents'] as List? ?? const [])
          .map((e) => AIContent.fromJson((e as Map).cast<String, dynamic>()))
          .toList(),
      reasoningContent: json['reasoningContent'] as String?,
      raw: (json['raw'] as Map?)?.cast<String, dynamic>() ?? const {},
    );
  }
}
