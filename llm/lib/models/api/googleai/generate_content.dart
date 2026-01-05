import 'package:json_annotation/json_annotation.dart';

part 'generate_content.g.dart';

// Request Models for generateContent endpoint
@JsonSerializable(fieldRename: FieldRename.snake)
class GeminiGenerateContentRequest {
  final List<GeminiContent> contents;
  final GeminiGenerationConfig? generationConfig;
  final List<GeminiTool>? tools;
  final GeminiToolConfig? toolConfig;
  final List<GeminiSafetySetting>? safetySettings;
  final dynamic systemInstruction; // Can be string or GeminiContent

  GeminiGenerateContentRequest({
    required this.contents,
    this.generationConfig,
    this.tools,
    this.toolConfig,
    this.safetySettings,
    this.systemInstruction,
  });

  factory GeminiGenerateContentRequest.fromJson(Map<String, dynamic> json) =>
      _$GeminiGenerateContentRequestFromJson(json);

  Map<String, dynamic> toJson() => _$GeminiGenerateContentRequestToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class GeminiContent {
  final List<GeminiPart>? parts;
  final String? role;

  GeminiContent({this.parts, this.role});

  factory GeminiContent.fromJson(Map<String, dynamic> json) =>
      _$GeminiContentFromJson(json);

  Map<String, dynamic> toJson() => _$GeminiContentToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class GeminiPart {
  final String? text;
  final GeminiInlineData? inlineData;
  final GeminiFileData? fileData;
  final GeminiFunctionCall? functionCall;
  final GeminiFunctionResponse? functionResponse;
  final GeminiExecutableCode? executableCode;
  final GeminiCodeExecutionResult? codeExecutionResult;

  GeminiPart({
    this.text,
    this.inlineData,
    this.fileData,
    this.functionCall,
    this.functionResponse,
    this.executableCode,
    this.codeExecutionResult,
  });

  factory GeminiPart.fromJson(Map<String, dynamic> json) =>
      _$GeminiPartFromJson(json);

  Map<String, dynamic> toJson() => _$GeminiPartToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class GeminiInlineData {
  final String? mimeType;
  final String? data;

  GeminiInlineData({this.mimeType, this.data});

  factory GeminiInlineData.fromJson(Map<String, dynamic> json) =>
      _$GeminiInlineDataFromJson(json);

  Map<String, dynamic> toJson() => _$GeminiInlineDataToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class GeminiFileData {
  final String? mimeType;
  final String? fileUri;

  GeminiFileData({this.mimeType, this.fileUri});

  factory GeminiFileData.fromJson(Map<String, dynamic> json) =>
      _$GeminiFileDataFromJson(json);

  Map<String, dynamic> toJson() => _$GeminiFileDataToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class GeminiFunctionCall {
  final String? name;
  final Map<String, dynamic>? args;

  GeminiFunctionCall({this.name, this.args});

  factory GeminiFunctionCall.fromJson(Map<String, dynamic> json) =>
      _$GeminiFunctionCallFromJson(json);

  Map<String, dynamic> toJson() => _$GeminiFunctionCallToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class GeminiFunctionResponse {
  final String? name;
  final Map<String, dynamic>? response;

  GeminiFunctionResponse({this.name, this.response});

  factory GeminiFunctionResponse.fromJson(Map<String, dynamic> json) =>
      _$GeminiFunctionResponseFromJson(json);

  Map<String, dynamic> toJson() => _$GeminiFunctionResponseToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class GeminiExecutableCode {
  final String? language;
  final String? code;

  GeminiExecutableCode({this.language, this.code});

  factory GeminiExecutableCode.fromJson(Map<String, dynamic> json) =>
      _$GeminiExecutableCodeFromJson(json);

  Map<String, dynamic> toJson() => _$GeminiExecutableCodeToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class GeminiCodeExecutionResult {
  final String? outcome;
  final String? output;

  GeminiCodeExecutionResult({this.outcome, this.output});

  factory GeminiCodeExecutionResult.fromJson(Map<String, dynamic> json) =>
      _$GeminiCodeExecutionResultFromJson(json);

  Map<String, dynamic> toJson() => _$GeminiCodeExecutionResultToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class GeminiGenerationConfig {
  final double? temperature;
  final int? maxOutputTokens;
  final double? topP;
  final int? topK;
  final List<String>? stopSequences;
  final String? responseMimeType;
  final Map<String, dynamic>? responseSchema;
  final int? candidateCount;

  GeminiGenerationConfig({
    this.temperature,
    this.maxOutputTokens,
    this.topP,
    this.topK,
    this.stopSequences,
    this.responseMimeType,
    this.responseSchema,
    this.candidateCount,
  });

  factory GeminiGenerationConfig.fromJson(Map<String, dynamic> json) =>
      _$GeminiGenerationConfigFromJson(json);

  Map<String, dynamic> toJson() => _$GeminiGenerationConfigToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class GeminiTool {
  final List<GeminiFunctionDeclaration>? functionDeclarations;
  final GeminiCodeExecution? codeExecution;

  GeminiTool({
    this.functionDeclarations,
    this.codeExecution,
  });

  factory GeminiTool.fromJson(Map<String, dynamic> json) =>
      _$GeminiToolFromJson(json);

  Map<String, dynamic> toJson() => _$GeminiToolToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class GeminiFunctionDeclaration {
  final String? name;
  final String? description;
  final Map<String, dynamic>? parameters;

  GeminiFunctionDeclaration({
    this.name,
    this.description,
    this.parameters,
  });

  factory GeminiFunctionDeclaration.fromJson(Map<String, dynamic> json) =>
      _$GeminiFunctionDeclarationFromJson(json);

  Map<String, dynamic> toJson() => _$GeminiFunctionDeclarationToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class GeminiCodeExecution {
  const GeminiCodeExecution();

  factory GeminiCodeExecution.fromJson(Map<String, dynamic> json) =>
      _$GeminiCodeExecutionFromJson(json);

  Map<String, dynamic> toJson() => _$GeminiCodeExecutionToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class GeminiToolConfig {
  final GeminiFunctionCallingConfig? functionCallingConfig;

  GeminiToolConfig({this.functionCallingConfig});

  factory GeminiToolConfig.fromJson(Map<String, dynamic> json) =>
      _$GeminiToolConfigFromJson(json);

  Map<String, dynamic> toJson() => _$GeminiToolConfigToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class GeminiFunctionCallingConfig {
  final String? mode;
  final List<String>? allowedFunctionNames;

  GeminiFunctionCallingConfig({
    this.mode,
    this.allowedFunctionNames,
  });

  factory GeminiFunctionCallingConfig.fromJson(Map<String, dynamic> json) =>
      _$GeminiFunctionCallingConfigFromJson(json);

  Map<String, dynamic> toJson() => _$GeminiFunctionCallingConfigToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class GeminiSafetySetting {
  final String? category;
  final String? threshold;

  GeminiSafetySetting({this.category, this.threshold});

  factory GeminiSafetySetting.fromJson(Map<String, dynamic> json) =>
      _$GeminiSafetySettingFromJson(json);

  Map<String, dynamic> toJson() => _$GeminiSafetySettingToJson(this);
}

// Response Models for generateContent endpoint
@JsonSerializable(fieldRename: FieldRename.snake)
class GeminiGenerateContentResponse {
  final List<GeminiCandidate>? candidates;
  final GeminiUsageMetadata? usageMetadata;
  final GeminiPromptFeedback? promptFeedback;
  final String? modelVersion;

  GeminiGenerateContentResponse({
    this.candidates,
    this.usageMetadata,
    this.promptFeedback,
    this.modelVersion,
  });

  factory GeminiGenerateContentResponse.fromJson(Map<String, dynamic> json) =>
      _$GeminiGenerateContentResponseFromJson(json);

  Map<String, dynamic> toJson() => _$GeminiGenerateContentResponseToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class GeminiCandidate {
  final GeminiContent? content;
  final String? finishReason;
  final double? avgLogprobs;
  final int? index;
  final List<GeminiSafetyRating>? safetyRatings;
  final GeminiCitationMetadata? citationMetadata;
  final GeminiGroundingMetadata? groundingMetadata;
  final GeminiLogprobsResult? logprobsResult;

  GeminiCandidate({
    this.content,
    this.finishReason,
    this.avgLogprobs,
    this.index,
    this.safetyRatings,
    this.citationMetadata,
    this.groundingMetadata,
    this.logprobsResult,
  });

  factory GeminiCandidate.fromJson(Map<String, dynamic> json) =>
      _$GeminiCandidateFromJson(json);

  Map<String, dynamic> toJson() => _$GeminiCandidateToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class GeminiSafetyRating {
  final String? category;
  final String? probability;
  final String? severity;

  GeminiSafetyRating({
    this.category,
    this.probability,
    this.severity,
  });

  factory GeminiSafetyRating.fromJson(Map<String, dynamic> json) =>
      _$GeminiSafetyRatingFromJson(json);

  Map<String, dynamic> toJson() => _$GeminiSafetyRatingToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class GeminiCitationMetadata {
  final List<GeminiCitationSource>? citationSources;

  GeminiCitationMetadata({this.citationSources});

  factory GeminiCitationMetadata.fromJson(Map<String, dynamic> json) =>
      _$GeminiCitationMetadataFromJson(json);

  Map<String, dynamic> toJson() => _$GeminiCitationMetadataToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class GeminiCitationSource {
  final int? startIndex;
  final int? endIndex;
  final String? uri;
  final String? license;

  GeminiCitationSource({
    this.startIndex,
    this.endIndex,
    this.uri,
    this.license,
  });

  factory GeminiCitationSource.fromJson(Map<String, dynamic> json) =>
      _$GeminiCitationSourceFromJson(json);

  Map<String, dynamic> toJson() => _$GeminiCitationSourceToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class GeminiGroundingMetadata {
  final List<GeminiGroundingChunk>? groundingChunks;
  final List<GeminiGroundingPassage>? groundingPassages;
  final GeminiSearchEntryPoint? searchEntryPoint;

  GeminiGroundingMetadata({
    this.groundingChunks,
    this.groundingPassages,
    this.searchEntryPoint,
  });

  factory GeminiGroundingMetadata.fromJson(Map<String, dynamic> json) =>
      _$GeminiGroundingMetadataFromJson(json);

  Map<String, dynamic> toJson() => _$GeminiGroundingMetadataToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class GeminiGroundingChunk {
  final GeminiGroundingSegment? web;
  final int? index;

  GeminiGroundingChunk({
    this.web,
    this.index,
  });

  factory GeminiGroundingChunk.fromJson(Map<String, dynamic> json) =>
      _$GeminiGroundingChunkFromJson(json);

  Map<String, dynamic> toJson() => _$GeminiGroundingChunkToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class GeminiGroundingSegment {
  final String? uri;
  final int? startIndex;
  final int? endIndex;
  final String? title;

  GeminiGroundingSegment({
    this.uri,
    this.startIndex,
    this.endIndex,
    this.title,
  });

  factory GeminiGroundingSegment.fromJson(Map<String, dynamic> json) =>
      _$GeminiGroundingSegmentFromJson(json);

  Map<String, dynamic> toJson() => _$GeminiGroundingSegmentToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class GeminiGroundingPassage {
  final int? id;
  final String? passageText;
  final List<GeminiGroundingSegment>? sources;

  GeminiGroundingPassage({
    this.id,
    this.passageText,
    this.sources,
  });

  factory GeminiGroundingPassage.fromJson(Map<String, dynamic> json) =>
      _$GeminiGroundingPassageFromJson(json);

  Map<String, dynamic> toJson() => _$GeminiGroundingPassageToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class GeminiSearchEntryPoint {
  final String? renderedContent;
  final List<GeminiSearchEntry>? entries;

  GeminiSearchEntryPoint({
    this.renderedContent,
    this.entries,
  });

  factory GeminiSearchEntryPoint.fromJson(Map<String, dynamic> json) =>
      _$GeminiSearchEntryPointFromJson(json);

  Map<String, dynamic> toJson() => _$GeminiSearchEntryPointToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class GeminiSearchEntry {
  final String? title;
  final String? uri;

  GeminiSearchEntry({
    this.title,
    this.uri,
  });

  factory GeminiSearchEntry.fromJson(Map<String, dynamic> json) =>
      _$GeminiSearchEntryFromJson(json);

  Map<String, dynamic> toJson() => _$GeminiSearchEntryToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class GeminiLogprobsResult {
  final List<GeminiCandidateLogprobs>? chosenCandidates;

  GeminiLogprobsResult({this.chosenCandidates});

  factory GeminiLogprobsResult.fromJson(Map<String, dynamic> json) =>
      _$GeminiLogprobsResultFromJson(json);

  Map<String, dynamic> toJson() => _$GeminiLogprobsResultToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class GeminiCandidateLogprobs {
  final List<GeminiLogprobsCandidates>? candidates;

  GeminiCandidateLogprobs({this.candidates});

  factory GeminiCandidateLogprobs.fromJson(Map<String, dynamic> json) =>
      _$GeminiCandidateLogprobsFromJson(json);

  Map<String, dynamic> toJson() => _$GeminiCandidateLogprobsToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class GeminiLogprobsCandidates {
  final List<GeminiTopCandidate>? topCandidates;
  final int? tokenPosition;

  GeminiLogprobsCandidates({
    this.topCandidates,
    this.tokenPosition,
  });

  factory GeminiLogprobsCandidates.fromJson(Map<String, dynamic> json) =>
      _$GeminiLogprobsCandidatesFromJson(json);

  Map<String, dynamic> toJson() => _$GeminiLogprobsCandidatesToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class GeminiTopCandidate {
  final String? token;
  final double? logProbability;

  GeminiTopCandidate({
    this.token,
    this.logProbability,
  });

  factory GeminiTopCandidate.fromJson(Map<String, dynamic> json) =>
      _$GeminiTopCandidateFromJson(json);

  Map<String, dynamic> toJson() => _$GeminiTopCandidateToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class GeminiUsageMetadata {
  final int? promptTokenCount;
  final int? candidatesTokenCount;
  final int? totalTokenCount;
  final GeminiCachedContentTokenCount? cachedContentTokenCount;

  GeminiUsageMetadata({
    this.promptTokenCount,
    this.candidatesTokenCount,
    this.totalTokenCount,
    this.cachedContentTokenCount,
  });

  factory GeminiUsageMetadata.fromJson(Map<String, dynamic> json) =>
      _$GeminiUsageMetadataFromJson(json);

  Map<String, dynamic> toJson() => _$GeminiUsageMetadataToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class GeminiCachedContentTokenCount {
  final int? totalTokens;

  GeminiCachedContentTokenCount({this.totalTokens});

  factory GeminiCachedContentTokenCount.fromJson(Map<String, dynamic> json) =>
      _$GeminiCachedContentTokenCountFromJson(json);

  Map<String, dynamic> toJson() => _$GeminiCachedContentTokenCountToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class GeminiPromptFeedback {
  final List<GeminiSafetyRating>? safetyRatings;
  final String? blockReason;

  GeminiPromptFeedback({
    this.safetyRatings,
    this.blockReason,
  });

  factory GeminiPromptFeedback.fromJson(Map<String, dynamic> json) =>
      _$GeminiPromptFeedbackFromJson(json);

  Map<String, dynamic> toJson() => _$GeminiPromptFeedbackToJson(this);
}
