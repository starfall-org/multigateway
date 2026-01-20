import 'package:flutter/material.dart';
import 'package:multigateway/app/translate/tl.dart';

class TranslationSearchField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const TranslationSearchField({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.search),
        hintText: tl('Search translations'),
        filled: true,
        isDense: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
