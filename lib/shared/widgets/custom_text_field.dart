import 'package:flutter/material.dart';
import 'package:signals/signals.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController? controller;
  final Signal<String>? signal;
  final String? initialValue;
  final String label;
  final String? hint;
  final IconData? prefixIcon;
  final bool obscureText;
  final TextInputType keyboardType;
  final int? maxLines;
  final int? minLines;
  final String? Function(String?)? validator;
  final Widget? suffixIcon;
  final void Function(String)? onChanged;

  const CustomTextField({
    super.key,
    this.controller,
    this.signal,
    this.initialValue,
    required this.label,
    this.hint,
    this.prefixIcon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.minLines,
    this.validator,
    this.suffixIcon,
    this.onChanged,
  }) : assert(
          (controller != null && signal == null && initialValue == null) ||
          (controller == null && signal != null && initialValue == null) ||
          (controller == null && signal == null && initialValue != null),
          'Provide exactly one: controller, signal, or initialValue',
        );

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late final TextEditingController _internalController;
  EffectCleanup? _cleanup;

  @override
  void initState() {
    super.initState();

    if (widget.controller != null) {
      _internalController = widget.controller!;
    } else if (widget.signal != null) {
      _internalController = TextEditingController(text: widget.signal!.value);
      // Sync signal -> controller
      _cleanup = effect(() {
        if (_internalController.text != widget.signal!.value) {
          _internalController.text = widget.signal!.value;
        }
      });
      // Sync controller -> signal
      _internalController.addListener(_onControllerChanged);
    } else {
      _internalController = TextEditingController(text: widget.initialValue);
    }
  }

  void _onControllerChanged() {
    if (widget.signal != null && widget.signal!.value != _internalController.text) {
      widget.signal!.value = _internalController.text;
    }
    widget.onChanged?.call(_internalController.text);
  }

  @override
  void dispose() {
    _cleanup?.call();
    if (widget.controller == null) {
      _internalController.removeListener(_onControllerChanged);
      _internalController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _internalController,
      obscureText: widget.obscureText,
      keyboardType: widget.keyboardType,
      maxLines: widget.maxLines,
      minLines: widget.minLines,
      validator: widget.validator,
      onChanged: widget.signal == null ? widget.onChanged : null,
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        prefixIcon: widget.prefixIcon != null ? Icon(widget.prefixIcon) : null,
        suffixIcon: widget.suffixIcon,
        filled: true,
        fillColor: Theme.of(context).cardColor,
      ),
    );
  }
}
