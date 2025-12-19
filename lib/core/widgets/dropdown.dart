import 'package:flutter/material.dart';

/// A reusable dropdown selection widget with:
/// - Rounded corners (customizable)
/// - Each dropdown item has a leading icon box area
///
/// Example:
/// CommonDropdown<String>(
///   labelText: 'Provider',
///   hintText: 'Select a provider',
///   value: selected,
///   onChanged: (v) => setState(() => selected = v),
///   options: [
///     DropdownOption(value: 'openai', label: 'OpenAI', icon: const Icon(Icons.api)),
///     DropdownOption(value: 'google', label: 'Google', icon: const Icon(Icons.cloud)),
///   ],
/// )
class CommonDropdown<T> extends StatelessWidget {
  const CommonDropdown({
    super.key,
    required this.options,
    this.value,
    this.onChanged,
    this.labelText,
    this.hintText,
    this.helperText,
    this.errorText,
    this.enabled = true,
    this.isExpanded = true,
    this.radius = 12,
    this.contentPadding = const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    this.menuMaxHeight = 320,
    this.iconBoxSize = 28,
    this.iconBoxRadius = 8,
    this.iconBoxBorder,
    this.iconBoxBackground,
  });

  /// Options to show in the dropdown
  final List<DropdownOption<T>> options;

  /// Current value
  final T? value;

  /// Change callback
  final ValueChanged<T?>? onChanged;

  /// Texts
  final String? labelText;
  final String? hintText;
  final String? helperText;
  final String? errorText;

  /// State
  final bool enabled;
  final bool isExpanded;

  /// Styling
  final double radius;
  final EdgeInsetsGeometry contentPadding;
  final double? menuMaxHeight;

  /// Item icon box styling
  final double iconBoxSize;
  final double iconBoxRadius;
  final BorderSide? iconBoxBorder;
  final Color? iconBoxBackground;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final BorderSide defaultBorderSide =
        BorderSide(color: scheme.outlineVariant.withOpacity(0.6), width: 1);
    final OutlineInputBorder outline = OutlineInputBorder(
      borderRadius: BorderRadius.circular(radius),
      borderSide: defaultBorderSide,
    );
    final OutlineInputBorder focusedOutline = OutlineInputBorder(
      borderRadius: BorderRadius.circular(radius),
      borderSide: BorderSide(color: scheme.primary, width: 1.25),
    );
    final OutlineInputBorder errorOutline = OutlineInputBorder(
      borderRadius: BorderRadius.circular(radius),
      borderSide: BorderSide(color: scheme.error, width: 1.25),
    );

    final Color boxBg =
        iconBoxBackground ?? scheme.surfaceContainerHighest.withOpacity(0.8);
    final BorderSide boxBorder =
        iconBoxBorder ?? BorderSide(color: scheme.outlineVariant, width: 1);

    return DropdownButtonFormField<T>(
      initialValue: value,
      isExpanded: isExpanded,
      onChanged: enabled ? onChanged : null,
      menuMaxHeight: menuMaxHeight,
      borderRadius: BorderRadius.circular(radius), // rounds dropdown menu popup
      items: options
          .map(
            (opt) => DropdownMenuItem<T>(
              value: opt.value,
              child: _DropdownRow(
                label: opt.label,
                icon: opt.icon,
                iconBoxSize: iconBoxSize,
                iconBoxRadius: iconBoxRadius,
                iconBoxBorder: boxBorder,
                iconBoxBackground: boxBg,
              ),
            ),
          )
          .toList(),
      selectedItemBuilder: (ctx) => options
          .map(
            (opt) => _DropdownRow(
              label: opt.label,
              icon: opt.icon,
              iconBoxSize: iconBoxSize,
              iconBoxRadius: iconBoxRadius,
              iconBoxBorder: BorderSide.none, // cleaner inside the field
              iconBoxBackground: Colors.transparent,
            ),
          )
          .toList(),
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        helperText: helperText,
        errorText: errorText,
        isDense: true,
        contentPadding: contentPadding,
        border: outline,
        enabledBorder: outline,
        focusedBorder: focusedOutline,
        errorBorder: errorOutline,
        focusedErrorBorder: errorOutline,
        // Use default fill from theme to blend well with Material 3
        // If you want filled style uncomment below:
        // filled: true,
        // fillColor: Theme.of(context).colorScheme.surface,
      ),
      icon: const Icon(Icons.expand_more_rounded),
      dropdownColor: Theme.of(context).colorScheme.surface,
    );
  }
}

/// Data model for a dropdown option, including a leading icon widget.
class DropdownOption<T> {
  final T value;
  final String label;
  /// Optional icon widget displayed inside the leading icon box area.
  /// Example: const Icon(Icons.person)
  final Widget? icon;

  const DropdownOption({
    required this.value,
    required this.label,
    this.icon,
  });
}

class _DropdownRow extends StatelessWidget {
  const _DropdownRow({
    required this.label,
    required this.icon,
    required this.iconBoxSize,
    required this.iconBoxRadius,
    required this.iconBoxBorder,
    required this.iconBoxBackground,
  });

  final String label;
  final Widget? icon;
  final double iconBoxSize;
  final double iconBoxRadius;
  final BorderSide iconBoxBorder;
  final Color iconBoxBackground;

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.bodyMedium;
    final hasIcon = icon != null;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Leading icon box (reserved space even if icon is null for alignment)
        Container(
          width: iconBoxSize,
          height: iconBoxSize,
          decoration: BoxDecoration(
            color: hasIcon ? iconBoxBackground : Colors.transparent,
            borderRadius: BorderRadius.circular(iconBoxRadius),
            border: hasIcon ? Border.fromBorderSide(iconBoxBorder) : null,
          ),
          alignment: Alignment.center,
          child: hasIcon
              ? IconTheme.merge(
                  data: IconThemeData(
                    size: iconBoxSize * 0.64,
                    color: _bestOnColor(iconBoxBackground),
                  ),
                  child: icon!,
                )
              : null,
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            label,
            style: textStyle,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  // Simple luminance-based contrast helper
  static Color _bestOnColor(Color bg) {
    return bg.computeLuminance() < 0.5 ? Colors.white : Colors.black;
  }
}