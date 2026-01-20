import 'package:flutter/material.dart';

typedef CustomBottomSheetBuilder = Widget Function(
  BuildContext context,
  ScrollController scrollController,
);

class CustomBottomSheet extends StatelessWidget {
  final CustomBottomSheetBuilder builder;
  final EdgeInsetsGeometry padding;
  final double initialChildSize;
  final double minChildSize;
  final double maxChildSize;
  final bool showHandle;
  final bool useSafeArea;

  const CustomBottomSheet({
    super.key,
    required this.builder,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    this.initialChildSize = 0.55,
    this.minChildSize = 0.25,
    this.maxChildSize = 0.95,
    this.showHandle = true,
    this.useSafeArea = true,
  });

  static Future<T?> show<T>(
    BuildContext context, {
    required CustomBottomSheetBuilder builder,
    EdgeInsetsGeometry padding = const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 12,
    ),
    double initialChildSize = 0.55,
    double minChildSize = 0.25,
    double maxChildSize = 0.95,
    bool showHandle = true,
    bool useSafeArea = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => CustomBottomSheet(
        builder: builder,
        padding: padding,
        initialChildSize: initialChildSize,
        minChildSize: minChildSize,
        maxChildSize: maxChildSize,
        showHandle: showHandle,
        useSafeArea: useSafeArea,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final clampedInitial =
        initialChildSize.clamp(minChildSize, maxChildSize).toDouble();

    return AnimatedPadding(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: clampedInitial,
        minChildSize: minChildSize,
        maxChildSize: maxChildSize,
        builder: (ctx, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
              boxShadow: [
                BoxShadow(
                  color: theme.shadowColor.withValues(alpha: 0.08),
                  blurRadius: 24,
                  offset: const Offset(0, -8),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              bottom: useSafeArea,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (showHandle)
                    Padding(
                      padding: const EdgeInsets.only(top: 10, bottom: 8),
                      child: Container(
                        width: 48,
                        height: 4,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.outlineVariant,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  Expanded(
                    child: Padding(
                      padding: padding,
                      child: PrimaryScrollController(
                        controller: scrollController,
                        child: builder(ctx, scrollController),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
