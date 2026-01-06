// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'responses.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RequestMessage _$RequestMessageFromJson(Map<String, dynamic> json) =>
    RequestMessage(
      role: json['role'] as String,
      content: json['content'],
      name: json['name'] as String?,
    );

Map<String, dynamic> _$RequestMessageToJson(RequestMessage instance) =>
    <String, dynamic>{
      'role': instance.role,
      'content': instance.content,
      'name': instance.name,
    };

Tool _$ToolFromJson(Map<String, dynamic> json) => Tool(
  type: json['type'] as String,
  function: FunctionDefinition.fromJson(
    json['function'] as Map<String, dynamic>,
  ),
);

Map<String, dynamic> _$ToolToJson(Tool instance) => <String, dynamic>{
  'type': instance.type,
  'function': instance.function.toJson(),
};

FunctionDefinition _$FunctionDefinitionFromJson(Map<String, dynamic> json) =>
    FunctionDefinition(
      description: json['description'] as String?,
      name: json['name'] as String,
      parameters: json['parameters'] as Map<String, dynamic>?,
      strict: json['strict'] as bool?,
    );

Map<String, dynamic> _$FunctionDefinitionToJson(FunctionDefinition instance) =>
    <String, dynamic>{
      'description': instance.description,
      'name': instance.name,
      'parameters': instance.parameters,
      'strict': instance.strict,
    };

OpenAiResponses _$OpenAiResponsesFromJson(Map<String, dynamic> json) =>
    OpenAiResponses(
      id: json['id'] as String,
      object: json['object'] as String,
      createdAt: (json['created_at'] as num).toInt(),
      model: json['model'] as String,
      status: json['status'] as String,
      error: json['error'] == null
          ? null
          : ErrorInfo.fromJson(json['error'] as Map<String, dynamic>),
      incompleteDetails: json['incomplete_details'] == null
          ? null
          : IncompleteDetails.fromJson(
              json['incomplete_details'] as Map<String, dynamic>,
            ),
      output: (json['output'] as List<dynamic>)
          .map((e) => ResponseItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      usage: ResponsesUsage.fromJson(json['usage'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$OpenAiResponsesToJson(OpenAiResponses instance) =>
    <String, dynamic>{
      'id': instance.id,
      'object': instance.object,
      'created_at': instance.createdAt,
      'model': instance.model,
      'status': instance.status,
      'error': instance.error?.toJson(),
      'incomplete_details': instance.incompleteDetails?.toJson(),
      'output': instance.output.map((e) => e.toJson()).toList(),
      'usage': instance.usage.toJson(),
    };

ResponseItem _$ResponseItemFromJson(Map<String, dynamic> json) => ResponseItem(
  id: json['id'] as String,
  type: json['type'] as String,
  role: json['role'] as String,
  content: (json['content'] as List<dynamic>)
      .map((e) => MessageContents.fromJson(e as Map<String, dynamic>))
      .toList(),
  status: json['status'] as String,
);

Map<String, dynamic> _$ResponseItemToJson(ResponseItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'role': instance.role,
      'content': instance.content.map((e) => e.toJson()).toList(),
      'status': instance.status,
    };

MessageContents _$MessageContentsFromJson(Map<String, dynamic> json) =>
    MessageContents(
      type: json['type'] as String,
      text: json['text'] as String,
      annotations: (json['annotations'] as List<dynamic>?)
          ?.map((e) => Annotation.fromJson(e as Map<String, dynamic>))
          .toList(),
      logprobs: json['logprobs'] == null
          ? null
          : Logprobs.fromJson(json['logprobs'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$MessageContentsToJson(MessageContents instance) =>
    <String, dynamic>{
      'type': instance.type,
      'text': instance.text,
      'annotations': instance.annotations?.map((e) => e.toJson()).toList(),
      'logprobs': instance.logprobs?.toJson(),
    };

Annotation _$AnnotationFromJson(Map<String, dynamic> json) => Annotation(
  type: json['type'] as String,
  text: json['text'] as String,
  startIndex: (json['start_index'] as num).toInt(),
  endIndex: (json['end_index'] as num).toInt(),
  fileId: json['file_id'] as String?,
  title: json['title'] as String?,
);

Map<String, dynamic> _$AnnotationToJson(Annotation instance) =>
    <String, dynamic>{
      'type': instance.type,
      'text': instance.text,
      'start_index': instance.startIndex,
      'end_index': instance.endIndex,
      'file_id': instance.fileId,
      'title': instance.title,
    };

Logprobs _$LogprobsFromJson(Map<String, dynamic> json) => Logprobs(
  token: json['token'] as String,
  logprob: (json['logprob'] as num).toDouble(),
  bytes: (json['bytes'] as List<dynamic>)
      .map((e) => (e as num).toInt())
      .toList(),
  topLogprobs: (json['top_logprobs'] as List<dynamic>)
      .map((e) => TopLogprob.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$LogprobsToJson(Logprobs instance) => <String, dynamic>{
  'token': instance.token,
  'logprob': instance.logprob,
  'bytes': instance.bytes,
  'top_logprobs': instance.topLogprobs.map((e) => e.toJson()).toList(),
};

TopLogprob _$TopLogprobFromJson(Map<String, dynamic> json) => TopLogprob(
  token: json['token'] as String,
  logprob: (json['logprob'] as num).toDouble(),
  bytes: (json['bytes'] as List<dynamic>)
      .map((e) => (e as num).toInt())
      .toList(),
);

Map<String, dynamic> _$TopLogprobToJson(TopLogprob instance) =>
    <String, dynamic>{
      'token': instance.token,
      'logprob': instance.logprob,
      'bytes': instance.bytes,
    };

ErrorInfo _$ErrorInfoFromJson(Map<String, dynamic> json) =>
    ErrorInfo(code: json['code'] as String, message: json['message'] as String);

Map<String, dynamic> _$ErrorInfoToJson(ErrorInfo instance) => <String, dynamic>{
  'code': instance.code,
  'message': instance.message,
};

IncompleteDetails _$IncompleteDetailsFromJson(Map<String, dynamic> json) =>
    IncompleteDetails(
      reason: json['reason'] as String,
      type: json['type'] as String,
    );

Map<String, dynamic> _$IncompleteDetailsToJson(IncompleteDetails instance) =>
    <String, dynamic>{'reason': instance.reason, 'type': instance.type};

ResponsesUsage _$ResponsesUsageFromJson(Map<String, dynamic> json) =>
    ResponsesUsage(
      inputTokens: (json['input_tokens'] as num).toInt(),
      outputTokens: (json['output_tokens'] as num).toInt(),
      totalTokens: (json['total_tokens'] as num).toInt(),
      inputTokensDetails: UsageDetails.fromJson(
        json['input_tokens_details'] as Map<String, dynamic>,
      ),
      outputTokensDetails: UsageDetails.fromJson(
        json['output_tokens_details'] as Map<String, dynamic>,
      ),
    );

Map<String, dynamic> _$ResponsesUsageToJson(ResponsesUsage instance) =>
    <String, dynamic>{
      'input_tokens': instance.inputTokens,
      'output_tokens': instance.outputTokens,
      'total_tokens': instance.totalTokens,
      'input_tokens_details': instance.inputTokensDetails.toJson(),
      'output_tokens_details': instance.outputTokensDetails.toJson(),
    };

UsageDetails _$UsageDetailsFromJson(Map<String, dynamic> json) => UsageDetails(
  cachedTokens: (json['cached_tokens'] as num?)?.toInt(),
  textTokens: (json['text_tokens'] as num?)?.toInt(),
  imageTokens: (json['image_tokens'] as num?)?.toInt(),
  audioTokens: (json['audio_tokens'] as num?)?.toInt(),
  reasoningTokens: (json['reasoning_tokens'] as num?)?.toInt(),
);

Map<String, dynamic> _$UsageDetailsToJson(UsageDetails instance) =>
    <String, dynamic>{
      'cached_tokens': instance.cachedTokens,
      'text_tokens': instance.textTokens,
      'image_tokens': instance.imageTokens,
      'audio_tokens': instance.audioTokens,
      'reasoning_tokens': instance.reasoningTokens,
    };

OpenAiResponsesRequest _$OpenAiResponsesRequestFromJson(
  Map<String, dynamic> json,
) => OpenAiResponsesRequest(
  model: json['model'] as String,
  input: (json['input'] as List<dynamic>)
      .map((e) => RequestMessage.fromJson(e as Map<String, dynamic>))
      .toList(),
  instructions: json['instructions'] as String?,
  maxOutputTokens: (json['max_output_tokens'] as num?)?.toInt(),
  include: (json['include'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  previousResponseId: json['previous_response_id'] as String?,
  store: json['store'] as bool?,
  metadata: (json['metadata'] as Map<String, dynamic>?)?.map(
    (k, e) => MapEntry(k, e as String),
  ),
  serviceTier: json['service_tier'] as String?,
  background: json['background'] as bool?,
  promptCacheKey: json['prompt_cache_key'] as String?,
  promptCacheRetention: json['prompt_cache_retention'] as String?,
  safetyIdentifier: json['safety_identifier'] as String?,
  parallelToolCalls: json['parallel_tool_calls'] as bool?,
  maxToolCalls: (json['max_tool_calls'] as num?)?.toInt(),
  reasoning: json['reasoning'] == null
      ? null
      : ReasoningConfig.fromJson(json['reasoning'] as Map<String, dynamic>),
  tools: (json['tools'] as List<dynamic>?)
      ?.map((e) => Tool.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$OpenAiResponsesRequestToJson(
  OpenAiResponsesRequest instance,
) => <String, dynamic>{
  'model': instance.model,
  'input': instance.input.map((e) => e.toJson()).toList(),
  'instructions': instance.instructions,
  'max_output_tokens': instance.maxOutputTokens,
  'include': instance.include,
  'previous_response_id': instance.previousResponseId,
  'store': instance.store,
  'metadata': instance.metadata,
  'service_tier': instance.serviceTier,
  'background': instance.background,
  'prompt_cache_key': instance.promptCacheKey,
  'prompt_cache_retention': instance.promptCacheRetention,
  'safety_identifier': instance.safetyIdentifier,
  'parallel_tool_calls': instance.parallelToolCalls,
  'max_tool_calls': instance.maxToolCalls,
  'reasoning': instance.reasoning?.toJson(),
  'tools': instance.tools?.map((e) => e.toJson()).toList(),
};

ReasoningConfig _$ReasoningConfigFromJson(Map<String, dynamic> json) =>
    ReasoningConfig(effort: json['effort'] as String);

Map<String, dynamic> _$ReasoningConfigToJson(ReasoningConfig instance) =>
    <String, dynamic>{'effort': instance.effort};
