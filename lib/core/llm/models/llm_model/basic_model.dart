class BasicModel {
  final String id;
  final String displayName;
  final String ownedBy;

  BasicModel({
    required this.id,
    required this.displayName,
    required this.ownedBy,
  });

  factory BasicModel.fromAnthropicJson(Map<String, dynamic> json) {
    return BasicModel(
      id: json['id'],
      displayName: json['display_name'],
      ownedBy: "anthropic",
    );
  }

  factory BasicModel.fromOpenAiJson(Map<String, dynamic> json) {
    return BasicModel(
      id: json['id'],
      displayName: json['id'],
      ownedBy: json['owned_by'] ?? "unknown",
    );
  }

  factory BasicModel.fromJson(Map<String, dynamic> json) {
    try {
      return BasicModel.fromAnthropicJson(json);
    } catch (e) {
      return BasicModel.fromOpenAiJson(json);
    }
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'display_name': displayName, 'owned_by': ownedBy};
  }
}
