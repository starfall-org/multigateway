class GitHubModel {
  final String id;
  final String name;
  final List<String> supportedInputModalities;
  final List<String> supportedOutputModalities;
  final int maxInputTokens;
  final int maxOutputTokens;

  GitHubModel({
    required this.id,
    required this.name,
    required this.supportedInputModalities,
    required this.supportedOutputModalities,
    required this.maxInputTokens,
    required this.maxOutputTokens,
  });

  factory GitHubModel.fromJson(Map<String, dynamic> json) {
    return GitHubModel(
      id: json['id'],
      name: json['name'],
      supportedInputModalities: json['supported_input_modalities'],
      supportedOutputModalities: json['supported_output_modalities'],
      maxInputTokens: json['limits']['max_input_tokens'],
      maxOutputTokens: json['limits']['max_output_tokens'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'supported_input_modalities': supportedInputModalities,
      'supported_output_modalities': supportedOutputModalities,
      'limits': {
        'max_input_tokens': maxInputTokens,
        'max_output_tokens': maxOutputTokens,
      },
    };
  }
}
