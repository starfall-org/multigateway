import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class ColorPickerDialog extends StatelessWidget {
  final Color currentColor;
  final ValueChanged<Color> onColorSelected;

  const ColorPickerDialog({
    super.key,
    required this.currentColor,
    required this.onColorSelected,
  });

  // preset colors
  static const List<Color> _presets = <Color>[
    Colors.black,
    Colors.white,
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.orange,
    Colors.yellow,
    Colors.purple,
    Colors.pink,
    Colors.cyan,
    Colors.teal,
    Colors.indigo,
    Colors.brown,
    Colors.grey,
  ];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('settings.appearance.colors'.tr()),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'settings.appearance.color_presets'.tr(),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _presets.map((color) {
                final isSelected = currentColor.toARGB32() == color.toARGB32();
                return GestureDetector(
                  onTap: () {
                    onColorSelected(color);
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    width: 48,
                    height: 48,
                    margin: const EdgeInsets.only(right: 16),
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      boxShadow: [
                        if (isSelected)
                          BoxShadow(
                            color: color.withValues(alpha: 0.4),
                            blurRadius: 12,
                            spreadRadius: 2,
                          ),
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: AnimatedScale(
                      scale: isSelected ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        Icons.check_circle,
                        color: color.computeLuminance() < 0.5
                            ? Colors.white
                            : Colors.black,
                        size: 28,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.color_lens_outlined),
              label: Text('settings.appearance.custom_color'.tr()),
              onPressed: () async {
                final picked = await _pickColor(context, initial: currentColor);
                if (picked != null) {
                  onColorSelected(picked);
                  // Check if the dialog is still mounted before popping
                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }
                }
              },
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('common.close'.tr()),
        ),
      ],
    );
  }

  Future<Color?> _pickColor(
    BuildContext context, {
    required Color initial,
  }) async {
    Color temp = initial;
    int r = temp.r.round();
    int g = temp.g.round();
    int b = temp.b.round();

    return showDialog<Color>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text('settings.appearance.custom_color'.tr()),
          content: StatefulBuilder(
            builder: (context, setState) {
              temp = Color.fromARGB(255, r, g, b);
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 44,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: temp,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade400),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _sliderRow('R', r, (v) => setState(() => r = v)),
                  _sliderRow('G', g, (v) => setState(() => g = v)),
                  _sliderRow('B', b, (v) => setState(() => b = v)),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(null),
              child: Text('common.close'.tr()),
            ),
            ElevatedButton(
              onPressed: () =>
                  Navigator.of(ctx).pop(Color.fromARGB(255, r, g, b)),
              child: Text('settings.update.title'.tr()),
            ),
          ],
        );
      },
    );
  }

  Widget _sliderRow(String label, int value, ValueChanged<int> onChanged) {
    return Row(
      children: [
        SizedBox(width: 20, child: Text(label)),
        Expanded(
          child: Slider(
            min: 0,
            max: 255,
            value: value.toDouble(),
            onChanged: (v) => onChanged(v.round()),
          ),
        ),
        SizedBox(
          width: 40,
          child: Text(value.toString(), textAlign: TextAlign.right),
        ),
      ],
    );
  }
}
