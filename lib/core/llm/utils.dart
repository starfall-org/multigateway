import 'dart:convert';
import 'models/api/api.dart';

/// General helpers
String encodeDataUrl({required String mimeType, required String base64Data}) {
  return 'data:$mimeType;base64,$base64Data';
}

String ensureTextFromContent(List<AIContent> parts) {
  return parts
      .where((p) => p.type == AIContentType.text)
      .map((p) => p.text ?? '')
      .join();
}

List<int> toBytes(dynamic data) {
  if (data is List<int>) return data;
  if (data is String) return utf8.encode(data);
  return utf8.encode(jsonEncode(data));
}

/// OpenAI Specific Helpers

List<Map<String, dynamic>> toOpenAIMessages(
  List<AIMessage> messages, {
  List<AIContent> extraImages = const [],
}) {
  return messages.map((m) {
    if (m.role == 'tool') {
      return {
        'role': 'tool',
        if (m.toolCallId != null) 'tool_call_id': m.toolCallId,
        'content': ensureTextFromContent(m.content),
      };
    }
    final parts = <Map<String, dynamic>>[];

    for (final c in m.content) {
      switch (c.type) {
        case AIContentType.text:
          if ((c.text ?? '').isNotEmpty) {
            parts.add({'type': 'text', 'text': c.text});
          }
          break;
        case AIContentType.image:
          final url = (c.uri != null && c.uri!.isNotEmpty)
              ? c.uri
              : ((c.dataBase64 != null && (c.mimeType ?? '').isNotEmpty)
                    ? encodeDataUrl(
                        mimeType: c.mimeType!,
                        base64Data: c.dataBase64!,
                      )
                    : null);
          if (url != null) {
            parts.add({
              'type': 'image_url',
              'image_url': {'url': url},
            });
          }
          break;
        default:
          break;
      }
    }

    // Attach extra images (global on request) to the first user message
    if (extraImages.isNotEmpty && m.role == 'user') {
      for (final c in extraImages) {
        if (c.type == AIContentType.image) {
          final url = (c.uri != null && c.uri!.isNotEmpty)
              ? c.uri
              : ((c.dataBase64 != null && (c.mimeType ?? '').isNotEmpty)
                    ? encodeDataUrl(
                        mimeType: c.mimeType!,
                        base64Data: c.dataBase64!,
                      )
                    : null);
          if (url != null) {
            parts.add({
              'type': 'image_url',
              'image_url': {'url': url},
            });
          }
        }
      }
    }

    if (parts.isEmpty) {
      return {
        'role': m.role,
        'content': ensureTextFromContent(m.content),
        if (m.name != null) 'name': m.name,
      };
    }
    return {
      'role': m.role,
      'content': parts,
      if (m.name != null) 'name': m.name,
    };
  }).toList();
}

List<Map<String, dynamic>> toOpenAITools(List<AIToolFunction> tools) {
  return tools
      .map(
        (t) => {
          'type': 'function',
          'function': {
            'name': t.name,
            if (t.description != null) 'description': t.description,
            'parameters': t.parameters,
          },
        },
      )
      .toList();
}

dynamic toOpenAIToolChoice(String choice) {
  if (choice == 'auto' || choice == 'none') return choice;
  return {
    'type': 'function',
    'function': {'name': choice},
  };
}

AIResponse parseOpenAIResponse(Map<String, dynamic> json) {
  final choices = (json['choices'] as List? ?? const []);
  final first = choices.isNotEmpty
      ? (choices.first as Map).cast<String, dynamic>()
      : const {};
  final message =
      (first['message'] as Map?)?.cast<String, dynamic>() ?? const {};
  String text = '';
  final content = message['content'];
  if (content is String) {
    text = content;
  } else if (content is List) {
    final sb = StringBuffer();
    for (final p in content) {
      final mp = (p as Map).cast<String, dynamic>();
      if (mp['type'] == 'text') {
        sb.write(mp['text'] ?? '');
      }
    }
    text = sb.toString();
  }

  final toolCalls = <AIToolCall>[];
  final tc = message['tool_calls'];
  if (tc is List) {
    for (final t in tc) {
      final mt = (t as Map).cast<String, dynamic>();
      final fid = (mt['id'] as String?) ?? '';
      final fn =
          ((mt['function'] as Map?)?.cast<String, dynamic>() ?? const {});
      final name = (fn['name'] as String?) ?? '';
      final argsStr = (fn['arguments'] as String?) ?? '{}';
      Map<String, dynamic> args;
      try {
        args = jsonDecode(argsStr) as Map<String, dynamic>;
      } catch (_) {
        args = {'_raw': argsStr};
      }
      toolCalls.add(AIToolCall(id: fid, name: name, arguments: args));
    }
  }

  final finish = first['finish_reason'] as String?;
  return AIResponse(
    text: text,
    toolCalls: toolCalls,
    finishReason: finish,
    raw: json,
  );
}

/// Anthropic Specific Helpers

(String?, List<AIMessage>) splitSystemAndMessages(List<AIMessage> msgs) {
  String? system;
  final rest = <AIMessage>[];
  for (final m in msgs) {
    if (system == null && m.role == 'system') {
      final t = ensureTextFromContent(m.content);
      if (t.isNotEmpty) system = t;
      continue;
    }
    rest.add(m);
  }
  return (system, rest);
}

List<Map<String, dynamic>> toAnthropicMessages(
  List<AIMessage> messages, {
  List<AIContent> extraImages = const [],
}) {
  bool firstUser = true;
  return messages.map((m) {
    if (m.role == 'tool') {
      return {
        'role': 'user',
        'content': [
          {
            'type': 'tool_result',
            if (m.toolCallId != null) 'tool_use_id': m.toolCallId,
            'content': ensureTextFromContent(m.content),
          },
        ],
      };
    }

    final blocks = <Map<String, dynamic>>[];
    for (final c in m.content) {
      switch (c.type) {
        case AIContentType.text:
          if ((c.text ?? '').isNotEmpty) {
            blocks.add({'type': 'text', 'text': c.text});
          }
          break;
        case AIContentType.image:
          final mediaType = (c.mimeType ?? '').isNotEmpty
              ? c.mimeType!
              : 'image/png';
          String? data = c.dataBase64;
          if (data == null && (c.uri ?? '').startsWith('data:')) {
            final u = c.uri!;
            final comma = u.indexOf(',');
            if (comma != -1) data = u.substring(comma + 1);
          }
          if (data != null) {
            blocks.add({
              'type': 'image',
              'source': {
                'type': 'base64',
                'media_type': mediaType,
                'data': data,
              },
            });
          }
          break;
        default:
          break;
      }
    }

    if (firstUser && m.role == 'user' && extraImages.isNotEmpty) {
      for (final c in extraImages) {
        if (c.type == AIContentType.image) {
          final mediaType = (c.mimeType ?? '').isNotEmpty
              ? c.mimeType!
              : 'image/png';
          String? data = c.dataBase64;
          if (data == null && (c.uri ?? '').startsWith('data:')) {
            final u = c.uri!;
            final comma = u.indexOf(',');
            if (comma != -1) data = u.substring(comma + 1);
          }
          if (data != null) {
            blocks.add({
              'type': 'image',
              'source': {
                'type': 'base64',
                'media_type': mediaType,
                'data': data,
              },
            });
          }
        }
      }
      firstUser = false;
    }

    if (blocks.isEmpty) {
      blocks.add({'type': 'text', 'text': ensureTextFromContent(m.content)});
    }

    final role = m.role == 'model'
        ? 'assistant'
        : (m.role == 'user' || m.role == 'assistant')
        ? m.role
        : 'user';

    return {'role': role, 'content': blocks};
  }).toList();
}

List<Map<String, dynamic>> toAnthropicTools(List<AIToolFunction> tools) {
  return tools
      .map(
        (t) => {
          'name': t.name,
          if (t.description != null) 'description': t.description,
          'input_schema': t.parameters,
        },
      )
      .toList();
}

dynamic toAnthropicToolChoice(String choice) {
  if (choice == 'auto') return {'type': 'auto'};
  if (choice == 'none') return {'type': 'auto'};
  return {'type': 'tool', 'name': choice};
}

AIResponse parseAnthropicResponse(Map<String, dynamic> json) {
  String text = '';
  final toolCalls = <AIToolCall>[];
  final content = (json['content'] as List? ?? const []);
  for (final block in content) {
    final b = (block as Map).cast<String, dynamic>();
    final type = b['type'] as String? ?? '';
    if (type == 'text') {
      text += b['text'] as String? ?? '';
    } else if (type == 'tool_use') {
      final id = b['id'] as String? ?? '';
      final name = b['name'] as String? ?? '';
      final input = (b['input'] as Map?)?.cast<String, dynamic>() ?? const {};
      toolCalls.add(AIToolCall(id: id, name: name, arguments: input));
    }
  }
  final finish = json['stop_reason'] as String?;
  return AIResponse(
    text: text,
    toolCalls: toolCalls,
    finishReason: finish,
    raw: json,
  );
}

/// Ollama Specific Helpers

List<Map<String, dynamic>> toOllamaMessages(
  List<AIMessage> messages, {
  List<AIContent> extraImages = const [],
}) {
  bool firstUser = true;
  return messages.map((m) {
    final role = m.role == 'model' ? 'assistant' : m.role;
    final text = ensureTextFromContent(m.content);
    final imgsBase64 = <String>[];

    void addImage(AIContent c) {
      String? data = c.dataBase64;
      if (data == null) {
        final u = c.uri ?? '';
        if (u.startsWith('data:')) {
          final comma = u.indexOf(',');
          if (comma != -1) data = u.substring(comma + 1);
        }
      }
      if (data != null && data.isNotEmpty) imgsBase64.add(data);
    }

    for (final c in m.content) {
      if (c.type == AIContentType.image) addImage(c);
    }

    if (firstUser && role == 'user' && extraImages.isNotEmpty) {
      for (final c in extraImages) {
        if (c.type == AIContentType.image) addImage(c);
      }
      firstUser = false;
    }

    final map = <String, dynamic>{'role': role, 'content': text};
    if (imgsBase64.isNotEmpty) {
      map['images'] = imgsBase64;
    }
    return map;
  }).toList();
}

AIResponse parseOllamaResponse(Map<String, dynamic> json) {
  final msg = (json['message'] as Map?)?.cast<String, dynamic>() ?? const {};
  final content = (msg['content'] as String?) ?? '';
  return AIResponse(text: content, raw: json);
}
