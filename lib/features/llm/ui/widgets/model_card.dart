import 'package:flutter/material.dart';
import 'package:llm/models/llm_model/basic_model.dart';
import 'package:llm/models/llm_model/github_model.dart';
import 'package:llm/models/llm_model/googleai_model.dart';
import 'package:llm/models/llm_model/ollama_model.dart';
import 'package:multigateway/core/llm/models/legacy_llm_model.dart';
import 'package:multigateway/shared/utils/icon_builder.dart';
import 'package:multigateway/shared/widgets/item_card.dart';

class ModelCard extends StatelessWidget {
  final dynamic
  model; // Can be BasicModel, OllamaModel, GoogleAiModel, or LegacyAiModel
  final VoidCallback? onTap;
  final Widget? trailing;

  const ModelCard({super.key, required this.model, this.onTap, this.trailing});

  @override
  Widget build(BuildContext context) {
    if (model is BasicModel) {
      return _BasicModelCard(
        model: model as BasicModel,
        onTap: onTap,
        trailing: trailing,
      );
    } else if (model is GitHubModel) {
      return _GitHubModelCard(
        model: model as GitHubModel,
        onTap: onTap,
        trailing: trailing,
      );
    } else if (model is OllamaModel) {
      return _OllamaModelCard(
        model: model as OllamaModel,
        onTap: onTap,
        trailing: trailing,
      );
    } else if (model is GoogleAiModel) {
      return _GoogleAiModelCard(
        model: model as GoogleAiModel,
        onTap: onTap,
        trailing: trailing,
      );
    } else if (model is LegacyAiModel) {
      return _LegacyModelCard(
        model: model as LegacyAiModel,
        onTap: onTap,
        trailing: trailing,
      );
    } else {
      return _UnknownModelCard(onTap: onTap, trailing: trailing);
    }
  }
}

// ============================================================================
// Private Widget Classes
// ============================================================================

/// BasicModel Card (OpenAI, Anthropic) - Simple display
class _BasicModelCard extends StatelessWidget {
  final BasicModel model;
  final VoidCallback? onTap;
  final Widget? trailing;

  const _BasicModelCard({required this.model, this.onTap, this.trailing});

  @override
  Widget build(BuildContext context) {
    return ItemCard(
      layout: ItemCardLayout.list,
      title: model.displayName,
      subtitle: 'by ${model.ownedBy}',
      icon: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        child: buildIcon(model.id),
      ),
      leading: _ModelCardHelpers.buildTag(
        context,
        const Icon(Icons.token, size: 16),
        Theme.of(context).colorScheme.primary,
      ),
      trailing: trailing,
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }
}

/// GitHubModel Card - Show publisher, summary, and license
class _GitHubModelCard extends StatelessWidget {
  final GitHubModel model;
  final VoidCallback? onTap;
  final Widget? trailing;

  const _GitHubModelCard({required this.model, this.onTap, this.trailing});

  @override
  Widget build(BuildContext context) {
    final tags = <Widget>[];

    return ItemCard(
      layout: ItemCardLayout.list,
      title: model.name,
      subtitle: model.id,
      icon: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        child: buildIcon(model.name),
      ),
      subtitleWidget: tags.isNotEmpty
          ? Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Wrap(spacing: 4, runSpacing: 4, children: tags),
            )
          : null,
      leading: _ModelCardHelpers.buildTag(
        context,
        const Icon(Icons.token, size: 16),
        Theme.of(context).colorScheme.primary,
      ),
      trailing: trailing,
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }
}

/// OllamaModel Card - Show parameter size and quantization
class _OllamaModelCard extends StatelessWidget {
  final OllamaModel model;
  final VoidCallback? onTap;
  final Widget? trailing;

  const _OllamaModelCard({required this.model, this.onTap, this.trailing});

  @override
  Widget build(BuildContext context) {
    final tags = <Widget>[
      _ModelCardHelpers.buildTextTag(
        context,
        model.parameterSize,
        Theme.of(context).colorScheme.tertiary,
      ),
      _ModelCardHelpers.buildTextTag(
        context,
        model.quantizationLevel,
        Theme.of(context).colorScheme.secondary,
      ),
    ];

    return ItemCard(
      layout: ItemCardLayout.list,
      title: model.name,
      subtitle: 'Model: ${model.model}',
      icon: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        child: buildIcon(model.name),
      ),
      subtitleWidget: Padding(
        padding: const EdgeInsets.only(top: 4.0),
        child: Wrap(spacing: 4, runSpacing: 4, children: tags),
      ),
      leading: _ModelCardHelpers.buildTag(
        context,
        const Icon(Icons.token, size: 16),
        Theme.of(context).colorScheme.primary,
      ),
      trailing: trailing,
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }
}

/// GoogleAiModel Card - Show generation methods, token limits, thinking capability
class _GoogleAiModelCard extends StatelessWidget {
  final GoogleAiModel model;
  final VoidCallback? onTap;
  final Widget? trailing;

  const _GoogleAiModelCard({required this.model, this.onTap, this.trailing});

  @override
  Widget build(BuildContext context) {
    final tags = <Widget>[];

    // Thinking capability
    if (model.thinking) {
      tags.add(
        _ModelCardHelpers.buildTextTag(
          context,
          'Thinking',
          Theme.of(context).colorScheme.primary,
        ),
      );
    }

    // Supported generation methods
    for (var method in model.supportedGenerationMethods) {
      tags.add(
        _ModelCardHelpers.buildTextTag(
          context,
          method,
          Theme.of(context).colorScheme.secondary,
        ),
      );
    }

    // Token limits
    tags.add(
      _ModelCardHelpers.buildTextTag(
        context,
        'In: ${_ModelCardHelpers.formatNumber(model.inputTokenLimit)}',
        Theme.of(context).colorScheme.tertiary,
      ),
    );

    tags.add(
      _ModelCardHelpers.buildTextTag(
        context,
        'Out: ${_ModelCardHelpers.formatNumber(model.outputTokenLimit)}',
        Theme.of(context).colorScheme.tertiary,
      ),
    );

    // Temperature info
    tags.add(
      _ModelCardHelpers.buildTextTag(
        context,
        'T: ${model.temperature}-${model.maxTemperature}',
        Theme.of(context).colorScheme.tertiary,
      ),
    );

    return ItemCard(
      layout: ItemCardLayout.list,
      title: model.displayName,
      subtitle: 'Top-K: ${model.topK}, Top-P: ${model.topP}',
      icon: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        child: buildIcon(model.name),
      ),
      subtitleWidget: Padding(
        padding: const EdgeInsets.only(top: 4.0),
        child: Wrap(spacing: 4, runSpacing: 4, children: tags),
      ),
      leading: _ModelCardHelpers.buildTag(
        context,
        const Icon(Icons.token, size: 16),
        Theme.of(context).colorScheme.primary,
      ),
      trailing: trailing,
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }
}

/// Legacy LegacyAiModel Card
class _LegacyModelCard extends StatelessWidget {
  final LegacyAiModel model;
  final VoidCallback? onTap;
  final Widget? trailing;

  const _LegacyModelCard({required this.model, this.onTap, this.trailing});

  @override
  Widget build(BuildContext context) {
    return ItemCard(
      layout: ItemCardLayout.list,
      title: model.displayName,
      icon: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        child: buildIcon(model.name),
      ),
      subtitleWidget: model.parameters != null
          ? Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Wrap(
                spacing: 4,
                runSpacing: 4,
                children: [
                  _ModelCardHelpers.buildTextTag(
                    context,
                    _ModelCardHelpers.formatParameters(model.parameters!),
                    Theme.of(context).colorScheme.tertiary,
                  ),
                ],
              ),
            )
          : null,
      leading: _ModelCardHelpers.buildTag(
        context,
        const Icon(Icons.token, size: 16),
        Theme.of(context).colorScheme.primary,
      ),
      trailing: trailing,
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }
}

/// Unknown model type card
class _UnknownModelCard extends StatelessWidget {
  final VoidCallback? onTap;
  final Widget? trailing;

  const _UnknownModelCard({this.onTap, this.trailing});

  @override
  Widget build(BuildContext context) {
    return ItemCard(
      layout: ItemCardLayout.list,
      title: 'Unknown Model',
      icon: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.errorContainer,
        child: Icon(
          Icons.error_outline,
          color: Theme.of(context).colorScheme.onErrorContainer,
        ),
      ),
      trailing: trailing,
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }
}

// ============================================================================
// Helper Class
// ============================================================================

/// Helper methods for building model card components
class _ModelCardHelpers {
  _ModelCardHelpers._(); // Private constructor to prevent instantiation

  /// Format large numbers (e.g., 1000000 → "1.0M")
  static String formatNumber(int num) {
    if (num >= 1000000) {
      return '${(num / 1000000).toStringAsFixed(1)}M';
    } else if (num >= 1000) {
      return '${(num / 1000).toStringAsFixed(1)}K';
    }
    return num.toString();
  }

  /// Format parameters (e.g., 7000000000 → "7B")
  static String formatParameters(int params) {
    if (params >= 1000000000) {
      return '${(params / 1000000000).toStringAsFixed(0)}B';
    } else if (params >= 1000000) {
      return '${(params / 1000000).toStringAsFixed(0)}M';
    } else if (params >= 1000) {
      return '${(params / 1000).toStringAsFixed(0)}K';
    }
    return params.toString();
  }

  /// Build a colored tag widget
  static Widget buildTag(BuildContext context, Widget label, Color color) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final boxColor = isDark
        ? Color.lerp(color, theme.colorScheme.surface, 0.7)!
        : Color.lerp(color, theme.colorScheme.onSurface, 0.5)!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: boxColor.withValues(alpha: isDark ? 0.2 : 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: isDark ? 0.4 : 0.3)),
      ),
      child: label,
    );
  }

  /// Build a text tag widget
  static Widget buildTextTag(BuildContext context, String label, Color color) {
    return buildTag(
      context,
      Text(label, style: const TextStyle(fontSize: 11)),
      color,
    );
  }
}
