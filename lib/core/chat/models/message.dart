import 'package:json_annotation/json_annotation.dart';

part 'message.g.dart';

enum ChatRole { user, model, system, tool, developer }

@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class MessageContents {
  final String? content;
  final DateTime timestamp;
  final String? reasoningContent;
  final List<String> files;
  final Map<String, dynamic> toolCall;

  MessageContents({
    required this.content,
    required this.timestamp,
    this.reasoningContent,
    this.files = const [],
    this.toolCall = const {},
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
    String? reasoningContent,
    List<String> files = const [],
    Map<String, dynamic> toolCall = const {},
  }) : versions =
           versions ??
           [
             MessageContents(
               content: content,
               timestamp: timestamp ?? DateTime.now(),
               reasoningContent: reasoningContent,
               files: files,
               toolCall: toolCall,
             ),
           ];

  MessageContents get current => versions[currentVersionIndex];
  String? get content => current.content;
  DateTime get timestamp => current.timestamp;
  String? get reasoningContent => current.reasoningContent;
  List<String> get files => current.files;
  Map<String, dynamic> get toolCall => current.toolCall;

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
      reasoningContent: currentV.reasoningContent,
      files: currentV.files,
      toolCall: currentV.toolCall,
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
