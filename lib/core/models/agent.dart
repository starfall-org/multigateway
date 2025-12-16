import 'dart:convert';

class Agent {
  final String id;
  final String name;
  final String systemPrompt;
  final double? topK;
  final double? temperature;
  final int contextWindow;
  final int conversationLength;
  final List<String> activeMCPServer;

  Agent({
    required this.id,
    required this.name,
    required this.systemPrompt,
    this.topK,
    this.temperature,
    this.contextWindow = 60000,
    this.conversationLength = 10,
    this.activeMCPServer = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'systemPrompt': systemPrompt,
      'topK': topK,
      'temperature': temperature,
      'contextWindow': contextWindow,
      'conversationLength': conversationLength,
      'activeMCPServer': activeMCPServer,
    };
  }

  factory Agent.fromJson(Map<String, dynamic> json) {
    return Agent(
      id: json['id'] as String,
      name: json['name'] as String,
      systemPrompt: json['systemPrompt'] as String,
      topK: json['topK'] as double?,
      temperature: json['temperature'] as double?,
      contextWindow: json['contextWindow'] as int,
      conversationLength: json['conversationLength'] as int,
      activeMCPServer:
          (json['activeMCPServer'] as List?)?.cast<String>() ?? const [],
    );
  }

  String toJsonString() => json.encode(toJson());

  factory Agent.fromJsonString(String jsonString) =>
      Agent.fromJson(json.decode(jsonString));
}
