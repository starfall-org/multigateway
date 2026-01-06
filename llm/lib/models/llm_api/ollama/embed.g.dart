// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'embed.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OllamaEmbedRequest _$OllamaEmbedRequestFromJson(Map<String, dynamic> json) =>
    OllamaEmbedRequest(
      model: json['model'] as String,
      input: json['input'] as String,
      options: json['options'] == null
          ? null
          : OllamaEmbedOptions.fromJson(
              json['options'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$OllamaEmbedRequestToJson(OllamaEmbedRequest instance) =>
    <String, dynamic>{
      'model': instance.model,
      'input': instance.input,
      'options': instance.options,
    };

OllamaEmbedOptions _$OllamaEmbedOptionsFromJson(Map<String, dynamic> json) =>
    OllamaEmbedOptions(
      numCtx: (json['numCtx'] as num?)?.toInt(),
      numBatch: (json['numBatch'] as num?)?.toInt(),
      numGqa: (json['numGqa'] as num?)?.toInt(),
      numGpu: (json['numGpu'] as num?)?.toInt(),
      numThread: (json['numThread'] as num?)?.toInt(),
      seed: (json['seed'] as num?)?.toInt(),
      useMmap: json['useMmap'] as bool?,
      useMlock: json['useMlock'] as bool?,
      f16Kv: (json['f16Kv'] as num?)?.toInt(),
      logitsAll: (json['logitsAll'] as num?)?.toInt(),
      vocabOnly: (json['vocabOnly'] as num?)?.toInt(),
      ropeFrequencyBase: json['ropeFrequencyBase'] as bool?,
      ropeFrequencyScale: json['ropeFrequencyScale'] as bool?,
      numPredict: (json['numPredict'] as num?)?.toInt(),
    );

Map<String, dynamic> _$OllamaEmbedOptionsToJson(OllamaEmbedOptions instance) =>
    <String, dynamic>{
      'numCtx': instance.numCtx,
      'numBatch': instance.numBatch,
      'numGqa': instance.numGqa,
      'numGpu': instance.numGpu,
      'numThread': instance.numThread,
      'seed': instance.seed,
      'useMmap': instance.useMmap,
      'useMlock': instance.useMlock,
      'f16Kv': instance.f16Kv,
      'logitsAll': instance.logitsAll,
      'vocabOnly': instance.vocabOnly,
      'ropeFrequencyBase': instance.ropeFrequencyBase,
      'ropeFrequencyScale': instance.ropeFrequencyScale,
      'numPredict': instance.numPredict,
    };

OllamaEmbedResponse _$OllamaEmbedResponseFromJson(Map<String, dynamic> json) =>
    OllamaEmbedResponse(
      model: json['model'] as String,
      embedding: (json['embedding'] as List<dynamic>)
          .map((e) => (e as num).toDouble())
          .toList(),
    );

Map<String, dynamic> _$OllamaEmbedResponseToJson(
  OllamaEmbedResponse instance,
) => <String, dynamic>{
  'model': instance.model,
  'embedding': instance.embedding,
};
