import 'package:json_annotation/json_annotation.dart';

part 'responses.g.dart';

@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class RequestMessage {
  final String role;
  final dynamic content;
  final String? name;

  RequestMessage({required this.role, required this.content, this.name});

  factory RequestMessage.fromJson(Map<String, dynamic> json) =>
      _$RequestMessageFromJson(json);

  Map<String, dynamic> toJson() => _$RequestMessageToJson(this);
}

@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class Tool {
  final String type;
  final FunctionDefinition function;

  Tool({required this.type, required this.function});

  factory Tool.fromJson(Map<String, dynamic> json) => _$ToolFromJson(json);

  Map<String, dynamic> toJson() => _$ToolToJson(this);
}

@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
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

// Response-related classes
@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class OpenAiResponses {
  final String id;
  final String object;
  final int createdAt;
  final String model;
  final String status;
  final ErrorInfo? error;
  final IncompleteDetails? incompleteDetails;
  final List<ResponseItem> output;
  final ResponsesUsage usage;

  OpenAiResponses({
    required this.id,
    required this.object,
    required this.createdAt,
    required this.model,
    required this.status,
    this.error,
    this.incompleteDetails,
    required this.output,
    required this.usage,
  });

  factory OpenAiResponses.fromJson(Map<String, dynamic> json) =>
      _$OpenAiResponsesFromJson(json);

  Map<String, dynamic> toJson() => _$OpenAiResponsesToJson(this);

  @override
  String toString() {
    return 'OpenAiResponses(id: $id, object: $object, createdAt: $createdAt, model: $model, status: $status, error: $error, incompleteDetails: $incompleteDetails, output: $output, usage: $usage)';
  }
}

@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class ResponseItem {
  final String id;
  final String type;
  final String role;
  final List<MessageContents> content;
  final String status;

  ResponseItem({
    required this.id,
    required this.type,
    required this.role,
    required this.content,
    required this.status,
  });

  factory ResponseItem.fromJson(Map<String, dynamic> json) =>
      _$ResponseItemFromJson(json);

  Map<String, dynamic> toJson() => _$ResponseItemToJson(this);

  @override
  String toString() {
    return 'ResponseItem(id: $id, type: $type, role: $role, content: $content, status: $status)';
  }
}

@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class MessageContents {
  final String type;
  final String text;
  final List<Annotation>? annotations;
  final Logprobs? logprobs;

  MessageContents({
    required this.type,
    required this.text,
    this.annotations,
    this.logprobs,
  });

  factory MessageContents.fromJson(Map<String, dynamic> json) =>
      _$MessageContentsFromJson(json);

  Map<String, dynamic> toJson() => _$MessageContentsToJson(this);

  @override
  String toString() {
    return 'MessageContents(type: $type, text: $text, annotations: $annotations, logprobs: $logprobs)';
  }
}

@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class Annotation {
  final String type;
  final String text;
  final int startIndex;
  final int endIndex;
  final String? fileId;
  final String? title;

  Annotation({
    required this.type,
    required this.text,
    required this.startIndex,
    required this.endIndex,
    this.fileId,
    this.title,
  });

  factory Annotation.fromJson(Map<String, dynamic> json) =>
      _$AnnotationFromJson(json);

  Map<String, dynamic> toJson() => _$AnnotationToJson(this);

  @override
  String toString() {
    return 'Annotation(type: $type, text: $text, startIndex: $startIndex, endIndex: $endIndex, fileId: $fileId, title: $title)';
  }
}

@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class Logprobs {
  final String token;
  final double logprob;
  final List<int> bytes;
  final List<TopLogprob> topLogprobs;

  Logprobs({
    required this.token,
    required this.logprob,
    required this.bytes,
    required this.topLogprobs,
  });

  factory Logprobs.fromJson(Map<String, dynamic> json) =>
      _$LogprobsFromJson(json);

  Map<String, dynamic> toJson() => _$LogprobsToJson(this);

  @override
  String toString() {
    return 'Logprobs(token: $token, logprob: $logprob, bytes: $bytes, topLogprobs: $topLogprobs)';
  }
}

@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class TopLogprob {
  final String token;
  final double logprob;
  final List<int> bytes;

  TopLogprob({required this.token, required this.logprob, required this.bytes});

  factory TopLogprob.fromJson(Map<String, dynamic> json) =>
      _$TopLogprobFromJson(json);

  Map<String, dynamic> toJson() => _$TopLogprobToJson(this);

  @override
  String toString() {
    return 'TopLogprob(token: $token, logprob: $logprob, bytes: $bytes)';
  }
}

@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class ErrorInfo {
  final String code;
  final String message;

  ErrorInfo({required this.code, required this.message});

  factory ErrorInfo.fromJson(Map<String, dynamic> json) =>
      _$ErrorInfoFromJson(json);

  Map<String, dynamic> toJson() => _$ErrorInfoToJson(this);

  @override
  String toString() {
    return 'ErrorInfo(code: $code, message: $message)';
  }
}

@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class IncompleteDetails {
  final String reason;
  final String type;

  IncompleteDetails({required this.reason, required this.type});

  factory IncompleteDetails.fromJson(Map<String, dynamic> json) =>
      _$IncompleteDetailsFromJson(json);

  Map<String, dynamic> toJson() => _$IncompleteDetailsToJson(this);

  @override
  String toString() {
    return 'IncompleteDetails(reason: $reason, type: $type)';
  }
}

@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class ResponsesUsage {
  final int inputTokens;
  final int outputTokens;
  final int totalTokens;
  final UsageDetails inputTokensDetails;
  final UsageDetails outputTokensDetails;

  ResponsesUsage({
    required this.inputTokens,
    required this.outputTokens,
    required this.totalTokens,
    required this.inputTokensDetails,
    required this.outputTokensDetails,
  });

  factory ResponsesUsage.fromJson(Map<String, dynamic> json) =>
      _$ResponsesUsageFromJson(json);

  Map<String, dynamic> toJson() => _$ResponsesUsageToJson(this);

  @override
  String toString() {
    return 'ResponsesUsage(inputTokens: $inputTokens, outputTokens: $outputTokens, totalTokens: $totalTokens, inputTokensDetails: $inputTokensDetails, outputTokensDetails: $outputTokensDetails)';
  }
}

@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class UsageDetails {
  final int? cachedTokens;
  final int? textTokens;
  final int? imageTokens;
  final int? audioTokens;
  final int? reasoningTokens;

  UsageDetails({
    this.cachedTokens,
    this.textTokens,
    this.imageTokens,
    this.audioTokens,
    this.reasoningTokens,
  });

  factory UsageDetails.fromJson(Map<String, dynamic> json) =>
      _$UsageDetailsFromJson(json);

  Map<String, dynamic> toJson() => _$UsageDetailsToJson(this);

  @override
  String toString() {
    return 'UsageDetails(cachedTokens: $cachedTokens, textTokens: $textTokens, imageTokens: $imageTokens, audioTokens: $audioTokens, reasoningTokens: $reasoningTokens)';
  }
}

@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class OpenAiResponsesRequest {
  final String model;
  final List<RequestMessage> input;
  final String? instructions;
  final int? maxOutputTokens;
  final List<String>? include;
  final String? previousResponseId;
  final bool? store;
  final Map<String, String>? metadata;
  final String? serviceTier;
  final bool? background;
  final String? promptCacheKey;
  final String? promptCacheRetention;
  final String? safetyIdentifier;
  final bool? parallelToolCalls;
  final int? maxToolCalls;
  final ReasoningConfig? reasoning;
  final List<Tool>? tools;

  OpenAiResponsesRequest({
    required this.model,
    required this.input,
    this.instructions,
    this.maxOutputTokens,
    this.include,
    this.previousResponseId,
    this.store,
    this.metadata,
    this.serviceTier,
    this.background,
    this.promptCacheKey,
    this.promptCacheRetention,
    this.safetyIdentifier,
    this.parallelToolCalls,
    this.maxToolCalls,
    this.reasoning,
    this.tools,
  });

  factory OpenAiResponsesRequest.fromJson(Map<String, dynamic> json) =>
      _$OpenAiResponsesRequestFromJson(json);

  Map<String, dynamic> toJson() => _$OpenAiResponsesRequestToJson(this);
}

@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class ReasoningConfig {
  final String effort;

  ReasoningConfig({required this.effort});

  factory ReasoningConfig.fromJson(Map<String, dynamic> json) =>
      _$ReasoningConfigFromJson(json);

  Map<String, dynamic> toJson() => _$ReasoningConfigToJson(this);
}
