import 'dart:convert';

class Agent {
  final String id;
  final String name;
  final String systemPrompt;
  final double? topK;
  final double? temperature;

  Agent({
    required this.id,
    required this.name,
    required this.systemPrompt,
    this.topK,
    this.temperature,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'systemPrompt': systemPrompt,
      'topK': topK,
      'temperature': temperature,
    };
  }

  factory Agent.fromJson(Map<String, dynamic> json) {
    return Agent(
      id: json['id'] as String,
      name: json['name'] as String,
      systemPrompt: json['systemPrompt'] as String,
      topK: json['topK'] as double?,
      temperature: json['temperature'] as double?,
    );
  }

  String toJsonString() => json.encode(toJson());

  factory Agent.fromJsonString(String jsonString) =>
      Agent.fromJson(json.decode(jsonString));
}