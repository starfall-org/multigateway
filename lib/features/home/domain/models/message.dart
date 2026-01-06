import 'package:json_annotation/json_annotation.dart';

part 'message.g.dart';

enum ChatRole {
  user,
  model,
  system,
  tool,
  developer,
}

@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class MessageContents {
  final String content;
  final DateTime timestamp;
  final List<String> attachments;
  final String? reasoningContent;
  final List<String> files;

  MessageContents({
    required this.content,
    required this.timestamp,
    this.attachments = const [],
    this.reasoningContent,
    this.files = const [],
  });

  factory MessageContents.fromJson(Map<String, dynamic> json) =>
      _$MessageContentsFromJson(json);

  Map<String, dynamic> toJson() => _$MessageContentsToJson(this);
}

@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class ChatMessage {
  final String id;
  final ChatRole role;
  final List<MessageContents> versions;
  final int currentVersionIndex;

  ChatMessage({
    required this.id,
    required this.role,
    List<MessageContents>? versions,
    this.currentVersionIndex = 0,
    String content = '',
    DateTime? timestamp,
    List<String> attachments = const [],
    String? reasoningContent,
    List<String> files = const [],
  }) : versions =
            versions ??
            [
              MessageContents(
                content: content,
                timestamp: timestamp ?? DateTime.now(),
                attachments: attachments,
                reasoningContent: reasoningContent,
                files: files,
              ),
            ];

  MessageContents get current => versions[currentVersionIndex];
  String get content => current.content;
  DateTime get timestamp => current.timestamp;
  List<String> get attachments => current.attachments;
  String? get reasoningContent => current.reasoningContent;
  List<String> get files => current.files;

  ChatMessage copyWith({
    String? id,
    ChatRole? role,
    List<MessageContents>? versions,
    int? currentVersionIndex,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      role: role ?? this.role,
      versions: versions ?? this.versions,
      currentVersionIndex: currentVersionIndex ?? this.currentVersionIndex,
    );
  }

  ChatMessage addVersion(MessageContents content) {
    return copyWith(
      versions: [...versions, content],
      currentVersionIndex: versions.length,
    );
  }

  ChatMessage updateActiveContent(String newContent) {
    final updatedVersions = List<MessageContents>.from(versions);
    final currentV = updatedVersions[currentVersionIndex];
    updatedVersions[currentVersionIndex] = MessageContents(
      content: newContent,
      timestamp: currentV.timestamp,
      attachments: currentV.attachments,
      reasoningContent: currentV.reasoningContent,
      files: currentV.files,
    );
    return copyWith(versions: updatedVersions);
  }

  ChatMessage switchVersion(int index) {
    if (index < 0 || index >= versions.length) return this;
    return copyWith(currentVersionIndex: index);
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) =>
      _$ChatMessageFromJson(json);

  Map<String, dynamic> toJson() => _$ChatMessageToJson(this);
}
