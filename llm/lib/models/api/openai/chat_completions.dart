import 'package:json_annotation/json_annotation.dart';

part 'chat_completions.g.dart';

// Request Models
@JsonSerializable(fieldRename: FieldRename.snake)
class OpenAiChatCompletionsRequest {
  final String model;
  final List<RequestMessage> messages;
  final Map<String, String>? metadata;
  final int? topLogprobs;
  final double? temperature;
  final double? topP;
  final String? user;
  final String? safetyIdentifier;
  final String? promptCacheKey;
  final String? serviceTier;
  final List<String>? modalities;
  final String? verbosity;
  final String? reasoningEffort;
  final int? maxCompletionTokens;
  final double? frequencyPenalty;
  final double? presencePenalty;
  final WebSearchOptions? webSearchOptions;
  final ResponseFormat? responseFormat;
  final AudioConfig? audio;
  final bool? store;
  final bool? stream;
  final String? stop;
  final Map<String, dynamic>? logitBias;
  final bool? logprobs;
  final int? maxTokens;
  final int? n;
  final Prediction? prediction;
  final int? seed;
  final StreamOptions? streamOptions;
  final List<Tool>? tools;
  final String? toolChoice;
  final bool? parallelToolCalls;
  final String? functionCall;
  final List<FunctionDefinition>? functions;

  OpenAiChatCompletionsRequest({
    required this.model,
    required this.messages,
    this.metadata,
    this.topLogprobs,
    this.temperature,
    this.topP,
    this.user,
    this.safetyIdentifier,
    this.promptCacheKey,
    this.serviceTier,
    this.modalities,
    this.verbosity,
    this.reasoningEffort,
    this.maxCompletionTokens,
    this.frequencyPenalty,
    this.presencePenalty,
    this.webSearchOptions,
    this.responseFormat,
    this.audio,
    this.store,
    this.stream,
    this.stop,
    this.logitBias,
    this.logprobs,
    this.maxTokens,
    this.n,
    this.prediction,
    this.seed,
    this.streamOptions,
    this.tools,
    this.toolChoice,
    this.parallelToolCalls,
    this.functionCall,
    this.functions,
  });

  factory OpenAiChatCompletionsRequest.fromJson(Map<String, dynamic> json) =>
      _$OpenAiChatCompletionsRequestFromJson(json);

  Map<String, dynamic> toJson() => _$OpenAiChatCompletionsRequestToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class RequestMessage {
  final String role;
  final dynamic content;
  final String? name;

  RequestMessage({required this.role, required this.content, this.name});

  factory RequestMessage.fromJson(Map<String, dynamic> json) =>
      _$RequestMessageFromJson(json);

  Map<String, dynamic> toJson() => _$RequestMessageToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class WebSearchOptions {
  final UserLocation? userLocation;
  final String? searchContextSize;

  WebSearchOptions({this.userLocation, this.searchContextSize});

  factory WebSearchOptions.fromJson(Map<String, dynamic> json) =>
      _$WebSearchOptionsFromJson(json);

  Map<String, dynamic> toJson() => _$WebSearchOptionsToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class UserLocation {
  final String type;
  final ApproximateLocation approximate;

  UserLocation({required this.type, required this.approximate});

  factory UserLocation.fromJson(Map<String, dynamic> json) =>
      _$UserLocationFromJson(json);

  Map<String, dynamic> toJson() => _$UserLocationToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class ApproximateLocation {
  final String? country;
  final String? region;
  final String? city;
  final String? timezone;

  ApproximateLocation({this.country, this.region, this.city, this.timezone});

  factory ApproximateLocation.fromJson(Map<String, dynamic> json) =>
      _$ApproximateLocationFromJson(json);

  Map<String, dynamic> toJson() => _$ApproximateLocationToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class ResponseFormat {
  final String type;

  ResponseFormat({required this.type});

  factory ResponseFormat.fromJson(Map<String, dynamic> json) =>
      _$ResponseFormatFromJson(json);

  Map<String, dynamic> toJson() => _$ResponseFormatToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class AudioConfig {
  final String voice;
  final String format;

  AudioConfig({required this.voice, required this.format});

  factory AudioConfig.fromJson(Map<String, dynamic> json) =>
      _$AudioConfigFromJson(json);

  Map<String, dynamic> toJson() => _$AudioConfigToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class Prediction {
  final String type;
  final String content;

  Prediction({required this.type, required this.content});

  factory Prediction.fromJson(Map<String, dynamic> json) =>
      _$PredictionFromJson(json);

  Map<String, dynamic> toJson() => _$PredictionToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class StreamOptions {
  final bool? includeUsage;
  final bool? includeObfuscation;

  StreamOptions({this.includeUsage, this.includeObfuscation});

  factory StreamOptions.fromJson(Map<String, dynamic> json) =>
      _$StreamOptionsFromJson(json);

  Map<String, dynamic> toJson() => _$StreamOptionsToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class Tool {
  final String type;
  final FunctionDefinition function;

  Tool({required this.type, required this.function});

  factory Tool.fromJson(Map<String, dynamic> json) => _$ToolFromJson(json);

  Map<String, dynamic> toJson() => _$ToolToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class FunctionDefinition {
  final String? description;
  final String name;
  final Map<String, dynamic>? parameters;
  final bool? strict;

  FunctionDefinition({
    this.description,
    required this.name,
    this.parameters,
    this.strict,
  });

  factory FunctionDefinition.fromJson(Map<String, dynamic> json) =>
      _$FunctionDefinitionFromJson(json);

  Map<String, dynamic> toJson() => _$FunctionDefinitionToJson(this);
}

// Response Models
@JsonSerializable(fieldRename: FieldRename.snake)
class OpenAiChatCompletions {
  final String? id;
  final String? object;
  final int? created;
  final String? model;
  final List<Choice>? choices;
  final ChatCompletionUsage? usage;
  final String? systemFingerprint;
  final String? serviceTier;

  OpenAiChatCompletions({
    this.id,
    this.object,
    this.created,
    this.model,
    this.choices,
    this.usage,
    this.systemFingerprint,
    this.serviceTier,
  });

  factory OpenAiChatCompletions.fromJson(Map<String, dynamic> json) =>
      _$OpenAiChatCompletionsFromJson(json);

  Map<String, dynamic> toJson() => _$OpenAiChatCompletionsToJson(this);

  @override
  String toString() {
    return 'OpenAiChatCompletions(id: $id, object: $object, created: $created, model: $model, choices: $choices, usage: $usage, systemFingerprint: $systemFingerprint, serviceTier: $serviceTier)';
  }
}

@JsonSerializable(fieldRename: FieldRename.snake)
class Choice {
  final int? index;
  final Message? message;
  final Delta? delta;
  final String? finishReason;
  final Logprobs? logprobs;

  Choice({
    this.index,
    this.message,
    this.delta,
    this.finishReason,
    this.logprobs,
  });

  factory Choice.fromJson(Map<String, dynamic> json) => _$ChoiceFromJson(json);

  Map<String, dynamic> toJson() => _$ChoiceToJson(this);

  @override
  String toString() {
    return 'Choice(index: $index, message: $message, delta: $delta, finishReason: $finishReason, logprobs: $logprobs)';
  }
}

@JsonSerializable(fieldRename: FieldRename.snake)
class Message {
  final String? content;
  final String? refusal;
  final String role;
  final FunctionCall? functionCall;
  final List<ToolCall>? toolCalls;
  final List<Annotation>? annotations;
  final Audio? audio;
  final String? reasoningContent;

  Message({
    this.content,
    this.refusal,
    required this.role,
    this.functionCall,
    this.toolCalls,
    this.annotations,
    this.audio,
    this.reasoningContent,
  });

  factory Message.fromJson(Map<String, dynamic> json) =>
      _$MessageFromJson(json);

  Map<String, dynamic> toJson() => _$MessageToJson(this);

  @override
  String toString() {
    return 'Message(content: $content, refusal: $refusal, role: $role, functionCall: $functionCall, toolCalls: $toolCalls, annotations: $annotations, audio: $audio, reasoningContent: $reasoningContent)';
  }
}

@JsonSerializable(fieldRename: FieldRename.snake)
class Delta {
  final String? content;
  final String? role;
  final String? refusal;
  final FunctionCall? functionCall;
  final List<ToolCall>? toolCalls;
  final Audio? audio;
  final String? reasoningContent;

  Delta({
    this.content,
    this.role,
    this.refusal,
    this.functionCall,
    this.toolCalls,
    this.audio,
    this.reasoningContent,
  });

  factory Delta.fromJson(Map<String, dynamic> json) => _$DeltaFromJson(json);

  Map<String, dynamic> toJson() => _$DeltaToJson(this);

  @override
  String toString() {
    return 'Delta(content: $content, role: $role, refusal: $refusal, functionCall: $functionCall, toolCalls: $toolCalls, audio: $audio, reasoningContent: $reasoningContent)';
  }
}

@JsonSerializable(fieldRename: FieldRename.snake)
class ToolCall {
  final String? id;
  final String? type;
  final FunctionCall? function;

  ToolCall({this.id, this.type, this.function});

  factory ToolCall.fromJson(Map<String, dynamic> json) =>
      _$ToolCallFromJson(json);

  Map<String, dynamic> toJson() => _$ToolCallToJson(this);

  @override
  String toString() {
    return 'ToolCall(id: $id, type: $type, function: $function)';
  }
}

@JsonSerializable(fieldRename: FieldRename.snake)
class FunctionCall {
  final String? name;
  final String? arguments;

  FunctionCall({this.name, this.arguments});

  factory FunctionCall.fromJson(Map<String, dynamic> json) =>
      _$FunctionCallFromJson(json);

  Map<String, dynamic> toJson() => _$FunctionCallToJson(this);

  @override
  String toString() {
    return 'FunctionCall(name: $name, arguments: $arguments)';
  }
}

@JsonSerializable(fieldRename: FieldRename.snake)
class Annotation {
  final String? type;
  final UrlCitation? urlCitation;

  Annotation({this.type, this.urlCitation});

  factory Annotation.fromJson(Map<String, dynamic> json) =>
      _$AnnotationFromJson(json);

  Map<String, dynamic> toJson() => _$AnnotationToJson(this);

  @override
  String toString() {
    return 'Annotation(type: $type, urlCitation: $urlCitation)';
  }
}

@JsonSerializable(fieldRename: FieldRename.snake)
class UrlCitation {
  final int? endIndex;
  final int? startIndex;
  final String? url;
  final String? title;

  UrlCitation({this.endIndex, this.startIndex, this.url, this.title});

  factory UrlCitation.fromJson(Map<String, dynamic> json) =>
      _$UrlCitationFromJson(json);

  Map<String, dynamic> toJson() => _$UrlCitationToJson(this);

  @override
  String toString() {
    return 'UrlCitation(endIndex: $endIndex, startIndex: $startIndex, url: $url, title: $title)';
  }
}

@JsonSerializable(fieldRename: FieldRename.snake)
class Audio {
  final String? id;
  final int? expiresAt;
  final String? data;
  final String? transcript;

  Audio({this.id, this.expiresAt, this.data, this.transcript});

  factory Audio.fromJson(Map<String, dynamic> json) => _$AudioFromJson(json);

  Map<String, dynamic> toJson() => _$AudioToJson(this);

  @override
  String toString() {
    return 'Audio(id: $id, expiresAt: $expiresAt, data: $data, transcript: $transcript)';
  }
}

@JsonSerializable(fieldRename: FieldRename.snake)
class Logprobs {
  final List<Token>? content;
  final List<Token>? refusal;

  Logprobs({this.content, this.refusal});

  factory Logprobs.fromJson(Map<String, dynamic> json) =>
      _$LogprobsFromJson(json);

  Map<String, dynamic> toJson() => _$LogprobsToJson(this);

  @override
  String toString() {
    return 'Logprobs(content: $content, refusal: $refusal)';
  }
}

@JsonSerializable(fieldRename: FieldRename.snake)
class Token {
  final String? token;
  final double? logprob;
  final List<int>? bytes;
  final List<TopLogprob>? topLogprobs;

  Token({this.token, this.logprob, this.bytes, this.topLogprobs});

  factory Token.fromJson(Map<String, dynamic> json) => _$TokenFromJson(json);

  Map<String, dynamic> toJson() => _$TokenToJson(this);

  @override
  String toString() {
    return 'Token(token: $token, logprob: $logprob, bytes: $bytes, topLogprobs: $topLogprobs)';
  }
}

@JsonSerializable(fieldRename: FieldRename.snake)
class TopLogprob {
  final String? token;
  final double? logprob;
  final List<int>? bytes;

  TopLogprob({this.token, this.logprob, this.bytes});

  factory TopLogprob.fromJson(Map<String, dynamic> json) =>
      _$TopLogprobFromJson(json);

  Map<String, dynamic> toJson() => _$TopLogprobToJson(this);

  @override
  String toString() {
    return 'TopLogprob(token: $token, logprob: $logprob, bytes: $bytes)';
  }
}

@JsonSerializable(fieldRename: FieldRename.snake)
class ChatCompletionUsage {
  final int? promptTokens;
  final int? completionTokens;
  final int? totalTokens;
  final CompletionTokenDetails? completionTokensDetails;
  final PromptTokenDetails? promptTokensDetails;

  ChatCompletionUsage({
    this.promptTokens,
    this.completionTokens,
    this.totalTokens,
    this.completionTokensDetails,
    this.promptTokensDetails,
  });

  factory ChatCompletionUsage.fromJson(Map<String, dynamic> json) =>
      _$ChatCompletionUsageFromJson(json);

  Map<String, dynamic> toJson() => _$ChatCompletionUsageToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class PromptTokenDetails {
  final int? cachedTokens;
  final int? audioTokens;

  PromptTokenDetails({this.cachedTokens, this.audioTokens});

  factory PromptTokenDetails.fromJson(Map<String, dynamic> json) =>
      _$PromptTokenDetailsFromJson(json);

  Map<String, dynamic> toJson() => _$PromptTokenDetailsToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class CompletionTokenDetails {
  final int? reasoningTokens;
  final int? audioTokens;
  final int? acceptedPredictionTokens;
  final int? rejectedPredictionTokens;

  CompletionTokenDetails({
    this.reasoningTokens,
    this.audioTokens,
    this.acceptedPredictionTokens,
    this.rejectedPredictionTokens,
  });

  factory CompletionTokenDetails.fromJson(Map<String, dynamic> json) =>
      _$CompletionTokenDetailsFromJson(json);

  Map<String, dynamic> toJson() => _$CompletionTokenDetailsToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class Custom {
  final String input;
  final String name;

  Custom({required this.input, required this.name});

  factory Custom.fromJson(Map<String, dynamic> json) => _$CustomFromJson(json);

  Map<String, dynamic> toJson() => _$CustomToJson(this);
}
