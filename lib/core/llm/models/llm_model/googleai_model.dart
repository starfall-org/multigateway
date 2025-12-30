class GoogleAiModel {
  final String name;
  final String displayName;
  final int inputTokenLimit;
  final int outputTokenLimit;
  final List<String> supportedGenerationMethods;
  final bool thinking;
  final double temperature;
  final double maxTemperature;
  final double topP;
  final int topK;

  GoogleAiModel({
    required this.name,
    required this.displayName,
    required this.inputTokenLimit,
    required this.outputTokenLimit,
    required this.supportedGenerationMethods,
    required this.thinking,
    required this.temperature,
    required this.maxTemperature,
    required this.topP,
    required this.topK,
  });

  factory GoogleAiModel.fromJson(Map<String, dynamic> json) {
    return GoogleAiModel(
      name: json['name'],
      displayName: json['display_name'],
      inputTokenLimit: json['input_token_limit'],
      outputTokenLimit: json['output_token_limit'],
      supportedGenerationMethods: json['supported_generation_methods'],
      thinking: json['thinking'],
      temperature: json['temperature'],
      maxTemperature: json['max_temperature'],
      topP: json['top_p'],
      topK: json['top_k'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'display_name': displayName,
      'input_token_limit': inputTokenLimit,
      'output_token_limit': outputTokenLimit,
      'supported_generation_methods': supportedGenerationMethods,
      'thinking': thinking,
      'temperature': temperature,
      'max_temperature': maxTemperature,
      'top_p': topP,
      'top_k': topK,
    };
  }
}
