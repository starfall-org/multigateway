//WARNING: legacy

enum ModelType { chat, image, video, audio, embed, rerank }

class AIModel {
  final String name;
  final String displayName;
  final String? icon;
  final ModelType type;
  final AIModelIO? input;
  final AIModelIO? output;
  final BuiltInTools? builtInTools;
  final bool reasoning;
  final int? contextWindow;
  final int? parameters;

  AIModel({
    required this.name,
    required this.displayName,
    this.icon,
    this.type = ModelType.chat,
    this.input,
    this.output,
    this.builtInTools,
    this.reasoning = false,
    this.contextWindow,
    this.parameters,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'displayName': displayName,
      if (icon != null) 'icon': icon,
      'type': type.name,
      'input': input?.toJson(),
      'output': output?.toJson(),
      if (builtInTools != null) 'builtInTools': builtInTools!.toJson(),
      'reasoning': reasoning,
      'contextWindow': contextWindow,
      'parameters': parameters,
    };
  }

  factory AIModel.fromJson(Map<String, dynamic> json) {
    // Handle 'id' (OpenAI, Anthropic) and 'name' (Gemini, Ollama)
    final String name =
        json['id'] as String? ?? json['name'] as String? ?? 'unknown';
    final String displayName =
        json['displayName'] as String? ?? name.replaceAll('-', ' ');

    // Infer ModelType from name/id as providers don't return our internal enum values
    ModelType type = ModelType.chat;
    final lowerName = name.toLowerCase();
    BuiltInTools? builtInTools;
    if (lowerName.contains('gemini')) {
      final isProOrFlash =
          lowerName.contains('pro') ||
          lowerName.contains('flash') ||
          lowerName.contains('2.0');
      builtInTools = BuiltInTools(
        urlContext: true,
        googleSearch: isProOrFlash,
        codeExecution: isProOrFlash,
      );
    }

    AIModelIO? input;
    AIModelIO? output;

    if (lowerName.contains('embed')) {
      type = ModelType.embed;
    } else if (lowerName.contains('sdxl') ||
        lowerName.contains('flux') ||
        lowerName.contains('image') ||
        lowerName.contains('nano-banana')) {
      type = ModelType.image;
      input = AIModelIO(text: true, image: true);
      output = AIModelIO(image: true);
    } else if (lowerName.contains('tts') ||
        lowerName.contains('audio') ||
        lowerName.contains('whisper')) {
      type = ModelType.audio;
      input = AIModelIO(text: true, audio: true);
      output = AIModelIO(audio: true, text: true);
    } else if (lowerName.contains('video') ||
        lowerName.contains('sora') ||
        lowerName.contains('veo')) {
      type = ModelType.video;
      input = AIModelIO(text: true, video: true);
      output = AIModelIO(video: true);
    } else if (lowerName.contains('rerank')) {
      type = ModelType.rerank;
    }

    // Specific keys for context window from various providers:
    // Gemini: inputTokenLimit
    // Ollama/Local: context_window
    // Standard: contextWindow
    int? contextWindow =
        safeInt(json['contextWindow']) ??
        safeInt(json['inputTokenLimit']) ??
        safeInt(json['context_window']) ??
        safeInt(json['n_ctx']);

    // Reasoning detection: checks JSON first, then falls back to name heuristics
    bool reasoning = false;
    if (json['reasoning'] is bool) {
      reasoning = json['reasoning'];
    } else if (lowerName.contains('reason') ||
        lowerName.contains('think') ||
        lowerName.contains('reason')) {
      reasoning = true;
    }

    switch (type) {
      case ModelType.image:
        if (!input!.text) {
          input.text = true;
        }
        if (!output!.image) {
          output.image = true;
        }
        break;
      case ModelType.video:
        if (!input!.text) {
          input.text = true;
        }
        if (!output!.video) {
          output.video = true;
        }
        break;
      case ModelType.audio:
        if (!input!.text) {
          input.text = true;
        }
        if (!output!.audio) {
          output.audio = true;
        }
        break;
      case ModelType.chat:
        if (!input!.text) {
          input.text = true;
        }
        if (!output!.text) {
          output.text = true;
        }
        break;
      default:
        break;
    }

    return AIModel(
      name: name,
      displayName: displayName,
      icon: json['icon'] as String?,
      type: type,
      input: input,
      output: output,
      builtInTools: builtInTools,
      reasoning: reasoning,
      contextWindow: contextWindow,
      parameters: safeInt(json['parameters']),
    );
  }
}

// Helper safely parse integers (handling int, double, string, null)
int? safeInt(dynamic val) {
  if (val is int) return val;
  if (val is double) return val.round();
  if (val is String) return int.tryParse(val);
  return null;
}

// Safe parsing for input/output lists
AIModelIO parseIOList(dynamic list) {
  if (list is List) {
    return AIModelIO(
      text: list.contains('text'),
      image: list.contains('image'),
      video: list.contains('video'),
      audio: list.contains('audio'),
    );
  }
  return AIModelIO();
}

class AIModelIO {
  bool text;
  bool image;
  bool video;
  bool audio;

  AIModelIO({
    this.text = true,
    this.image = false,
    this.video = false,
    this.audio = false,
  });

  factory AIModelIO.fromJson(Map<String, dynamic> json) {
    return AIModelIO(
      text: json['text'] == true,
      image: json['image'] == true,
      video: json['video'] == true,
      audio: json['audio'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {'text': text, 'image': image, 'video': video, 'audio': audio};
  }
}

class BuiltInTools {
  final bool urlContext;
  final bool googleSearch;
  final bool codeExecution;

  BuiltInTools({
    this.urlContext = false,
    this.googleSearch = false,
    this.codeExecution = false,
  });

  factory BuiltInTools.fromJson(Map<String, dynamic> json) {
    return BuiltInTools(
      urlContext: json['urlContext'] == true,
      googleSearch: json['googleSearch'] == true,
      codeExecution: json['codeExecution'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'urlContext': urlContext,
      'googleSearch': googleSearch,
      'codeExecution': codeExecution,
    };
  }
}
