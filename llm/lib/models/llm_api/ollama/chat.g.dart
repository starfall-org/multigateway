// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OllamaChatRequest _$OllamaChatRequestFromJson(Map<String, dynamic> json) =>
    OllamaChatRequest(
      model: json['model'] as String,
      messages: (json['messages'] as List<dynamic>)
          .map((e) => OllamaMessage.fromJson(e as Map<String, dynamic>))
          .toList(),
      format: json['format'] as String?,
      options: json['options'] == null
          ? null
          : OllamaOptions.fromJson(json['options'] as Map<String, dynamic>),
      stream: json['stream'] as bool?,
      tools: (json['tools'] as List<dynamic>?)
          ?.map((e) => OllamaTool.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$OllamaChatRequestToJson(OllamaChatRequest instance) =>
    <String, dynamic>{
      'model': instance.model,
      'messages': instance.messages,
      'format': instance.format,
      'options': instance.options,
      'stream': instance.stream,
      'tools': instance.tools,
    };

OllamaMessage _$OllamaMessageFromJson(Map<String, dynamic> json) =>
    OllamaMessage(
      role: json['role'] as String,
      content: json['content'],
      images: (json['images'] as List<dynamic>?)
          ?.map((e) => OllamaImage.fromJson(e as Map<String, dynamic>))
          .toList(),
      toolCalls: json['toolCalls'] == null
          ? null
          : OllamaToolCall.fromJson(json['toolCalls'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$OllamaMessageToJson(OllamaMessage instance) =>
    <String, dynamic>{
      'role': instance.role,
      'content': instance.content,
      'images': instance.images,
      'toolCalls': instance.toolCalls,
    };

OllamaImage _$OllamaImageFromJson(Map<String, dynamic> json) =>
    OllamaImage(data: json['data'] as String);

Map<String, dynamic> _$OllamaImageToJson(OllamaImage instance) =>
    <String, dynamic>{'data': instance.data};

OllamaTool _$OllamaToolFromJson(Map<String, dynamic> json) => OllamaTool(
  function: OllamaFunction.fromJson(json['function'] as Map<String, dynamic>),
  type: json['type'] as String? ?? 'function',
);

Map<String, dynamic> _$OllamaToolToJson(OllamaTool instance) =>
    <String, dynamic>{'function': instance.function, 'type': instance.type};

OllamaFunction _$OllamaFunctionFromJson(Map<String, dynamic> json) =>
    OllamaFunction(
      name: json['name'] as String,
      description: json['description'] as String?,
      parameters: json['parameters'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$OllamaFunctionToJson(OllamaFunction instance) =>
    <String, dynamic>{
      'name': instance.name,
      'description': instance.description,
      'parameters': instance.parameters,
    };

OllamaToolCall _$OllamaToolCallFromJson(Map<String, dynamic> json) =>
    OllamaToolCall(
      function: OllamaToolCallFunction.fromJson(
        json['function'] as Map<String, dynamic>,
      ),
    );

Map<String, dynamic> _$OllamaToolCallToJson(OllamaToolCall instance) =>
    <String, dynamic>{'function': instance.function};

OllamaToolCallFunction _$OllamaToolCallFunctionFromJson(
  Map<String, dynamic> json,
) => OllamaToolCallFunction(
  name: json['name'] as String,
  arguments: json['arguments'] as Map<String, dynamic>,
);

Map<String, dynamic> _$OllamaToolCallFunctionToJson(
  OllamaToolCallFunction instance,
) => <String, dynamic>{'name': instance.name, 'arguments': instance.arguments};

OllamaOptions _$OllamaOptionsFromJson(Map<String, dynamic> json) =>
    OllamaOptions(
      numCtx: (json['numCtx'] as num?)?.toInt(),
      numBatch: (json['numBatch'] as num?)?.toInt(),
      temperature: (json['temperature'] as num?)?.toDouble(),
      topK: (json['topK'] as num?)?.toInt(),
      topP: (json['topP'] as num?)?.toDouble(),
      numGqa: (json['numGqa'] as num?)?.toInt(),
      numGpu: (json['numGpu'] as num?)?.toInt(),
      numThread: (json['numThread'] as num?)?.toInt(),
      seed: (json['seed'] as num?)?.toInt(),
      useMmap: json['useMmap'] as bool?,
      useMlock: json['useMlock'] as bool?,
      repeatLastN: (json['repeatLastN'] as num?)?.toDouble(),
      repeatPenalty: (json['repeatPenalty'] as num?)?.toDouble(),
      presencePenalty: (json['presencePenalty'] as num?)?.toDouble(),
      frequencyPenalty: (json['frequencyPenalty'] as num?)?.toDouble(),
      dryMultiplier: (json['dryMultiplier'] as num?)?.toDouble(),
      dryBase: (json['dryBase'] as num?)?.toDouble(),
      dryAllowedLength: (json['dryAllowedLength'] as num?)?.toInt(),
      drySpecialTokens: (json['drySpecialTokens'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      numPredict: (json['numPredict'] as num?)?.toInt(),
      stop: (json['stop'] as num?)?.toInt(),
      tfsZ: (json['tfsZ'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList(),
      typicalP: (json['typicalP'] as num?)?.toInt(),
      penaltyLastN: (json['penaltyLastN'] as num?)?.toInt(),
      mirostat: (json['mirostat'] as num?)?.toInt(),
      mirostatTau: (json['mirostatTau'] as num?)?.toDouble(),
      mirostatEta: (json['mirostatEta'] as num?)?.toDouble(),
      penalizeNewline: (json['penalizeNewline'] as num?)?.toInt(),
    );

Map<String, dynamic> _$OllamaOptionsToJson(OllamaOptions instance) =>
    <String, dynamic>{
      'numCtx': instance.numCtx,
      'numBatch': instance.numBatch,
      'temperature': instance.temperature,
      'topK': instance.topK,
      'topP': instance.topP,
      'numGqa': instance.numGqa,
      'numGpu': instance.numGpu,
      'numThread': instance.numThread,
      'seed': instance.seed,
      'useMmap': instance.useMmap,
      'useMlock': instance.useMlock,
      'repeatLastN': instance.repeatLastN,
      'repeatPenalty': instance.repeatPenalty,
      'presencePenalty': instance.presencePenalty,
      'frequencyPenalty': instance.frequencyPenalty,
      'dryMultiplier': instance.dryMultiplier,
      'dryBase': instance.dryBase,
      'dryAllowedLength': instance.dryAllowedLength,
      'drySpecialTokens': instance.drySpecialTokens,
      'numPredict': instance.numPredict,
      'stop': instance.stop,
      'tfsZ': instance.tfsZ,
      'typicalP': instance.typicalP,
      'penaltyLastN': instance.penaltyLastN,
      'mirostat': instance.mirostat,
      'mirostatTau': instance.mirostatTau,
      'mirostatEta': instance.mirostatEta,
      'penalizeNewline': instance.penalizeNewline,
    };

OllamaChatResponse _$OllamaChatResponseFromJson(Map<String, dynamic> json) =>
    OllamaChatResponse(
      model: json['model'] as String,
      createdAt: json['createdAt'] as String,
      message: OllamaMessage.fromJson(json['message'] as Map<String, dynamic>),
      done: json['done'] as bool,
      totalDuration: (json['totalDuration'] as num?)?.toInt(),
      loadDuration: (json['loadDuration'] as num?)?.toInt(),
      promptEvalCount: (json['promptEvalCount'] as num?)?.toInt(),
      promptEvalDuration: (json['promptEvalDuration'] as num?)?.toInt(),
      evalCount: (json['evalCount'] as num?)?.toInt(),
      evalDuration: (json['evalDuration'] as num?)?.toInt(),
    );

Map<String, dynamic> _$OllamaChatResponseToJson(OllamaChatResponse instance) =>
    <String, dynamic>{
      'model': instance.model,
      'createdAt': instance.createdAt,
      'message': instance.message,
      'done': instance.done,
      'totalDuration': instance.totalDuration,
      'loadDuration': instance.loadDuration,
      'promptEvalCount': instance.promptEvalCount,
      'promptEvalDuration': instance.promptEvalDuration,
      'evalCount': instance.evalCount,
      'evalDuration': instance.evalDuration,
    };

OllamaChatStreamResponse _$OllamaChatStreamResponseFromJson(
  Map<String, dynamic> json,
) => OllamaChatStreamResponse(
  model: json['model'] as String?,
  createdAt: json['createdAt'] as String?,
  message: json['message'] == null
      ? null
      : OllamaMessage.fromJson(json['message'] as Map<String, dynamic>),
  done: json['done'] as bool?,
  totalDuration: (json['totalDuration'] as num?)?.toInt(),
  loadDuration: (json['loadDuration'] as num?)?.toInt(),
  promptEvalCount: (json['promptEvalCount'] as num?)?.toInt(),
  promptEvalDuration: (json['promptEvalDuration'] as num?)?.toInt(),
  evalCount: (json['evalCount'] as num?)?.toInt(),
  evalDuration: (json['evalDuration'] as num?)?.toInt(),
);

Map<String, dynamic> _$OllamaChatStreamResponseToJson(
  OllamaChatStreamResponse instance,
) => <String, dynamic>{
  'model': instance.model,
  'createdAt': instance.createdAt,
  'message': instance.message,
  'done': instance.done,
  'totalDuration': instance.totalDuration,
  'loadDuration': instance.loadDuration,
  'promptEvalCount': instance.promptEvalCount,
  'promptEvalDuration': instance.promptEvalDuration,
  'evalCount': instance.evalCount,
  'evalDuration': instance.evalDuration,
};
