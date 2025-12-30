class OllamaModel {
  final String name;
  final String model;
  final String parameterSize;
  final String quantizationLevel;

  OllamaModel({
    required this.name,
    required this.model,
    required this.parameterSize,
    required this.quantizationLevel,
  });

  factory OllamaModel.fromJson(Map<String, dynamic> json) {
    return OllamaModel(
      name: json['name'],
      model: json['model'],
      parameterSize: json['details']['parameter_size'],
      quantizationLevel: json['details']['quantization_level'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'model': model,
      'details': {
        'parameter_size': parameterSize,
        'quantization_level': quantizationLevel,
      },
    };
  }
}
