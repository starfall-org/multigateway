import 'package:flutter/material.dart';
import 'empty_state.dart';

/// A utility widget that handles common screen states:
/// - Loading: Shows a progress indicator
/// - Error: Shows an error message with optional retry action
/// - Empty: Shows an [EmptyState] widget
/// - Content: Shows the actual content
class ScreenState extends StatelessWidget {
  final bool isLoading;
  final String? error;
  final VoidCallback? onRetry;
  final bool isEmpty;
  final Widget? emptyWidget;
  final Widget child;

  // Empty state configuration
  final IconData? emptyIcon;
  final String? emptyMessage;
  final String? emptySubMessage;
  final VoidCallback? onEmptyAction;
  final String? emptyActionLabel;

  const ScreenState({
    super.key,
    required this.isLoading,
    this.error,
    this.onRetry,
    this.isEmpty = false,
    this.emptyWidget,
    required this.child,
    this.emptyIcon,
    this.emptyMessage,
    this.emptySubMessage,
    this.onEmptyAction,
    this.emptyActionLabel,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                error!,
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.error,
                ),
                textAlign: TextAlign.center,
              ),
              if (onRetry != null) ...[
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ],
          ),
        ),
      );
    }

    if (isEmpty) {
      if (emptyWidget != null) return emptyWidget!;

      return EmptyState(
        icon: emptyIcon ?? Icons.inbox_outlined,
        message: emptyMessage ?? 'No items found',
        subMessage: emptySubMessage,
        onAction: onEmptyAction,
        actionLabel: emptyActionLabel,
      );
    }

    return child;
  }
}