import 'package:flutter/material.dart';
import 'package:multigateway/core/llm/models/llm_provider_models.dart';
import 'package:multigateway/shared/utils/icon_builder.dart';
import 'package:multigateway/shared/widgets/item_card.dart';

class ModelCard extends StatelessWidget {
  final LlmModel model;
  final VoidCallback? onTap;
  final Widget? trailing;

  const ModelCard({super.key, required this.model, this.onTap, this.trailing});

  @override
  Widget build(BuildContext context) {
    return ItemCard(
      layout: ItemCardLayout.list,
      title: model.displayName,
      subtitle: _buildSubtitle(),
      icon: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        child: model.icon != null
            ? buildIcon(model.icon!)
            : buildIcon(model.id),
      ),
      subtitleWidget: _buildOriginSpecificInfo(context),
      leading: _buildTypeTag(context),
      trailing: trailing,
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }

  String _buildSubtitle() {
    if (model.providerName != null) {
      return model.providerName!;
    }
    return model.id;
  }

  Widget? _buildOriginSpecificInfo(BuildContext context) {
    return null;
  }

  Widget _buildTypeTag(BuildContext context) {
    IconData iconData;
    Color color = Theme.of(context).colorScheme.primary;

    switch (model.type) {
      case LlmModelType.chat:
        iconData = Icons.chat;
        break;
      case LlmModelType.image:
        iconData = Icons.image;
        color = Theme.of(context).colorScheme.secondary;
        break;
      case LlmModelType.audio:
        iconData = Icons.audiotrack;
        color = Theme.of(context).colorScheme.tertiary;
        break;
      case LlmModelType.video:
        iconData = Icons.videocam;
        color = Theme.of(context).colorScheme.error;
        break;
      case LlmModelType.embed:
        iconData = Icons.data_array;
        color = Theme.of(context).colorScheme.outline;
        break;
      case LlmModelType.media:
        iconData = Icons.perm_media;
        color = Theme.of(context).colorScheme.secondary;
        break;
      case LlmModelType.other:
        iconData = Icons.device_unknown;
        color = Theme.of(context).colorScheme.outline;
        break;
    }

    return _ModelCardHelpers.buildTag(context, Icon(iconData, size: 16), color);
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
