import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:multigateway/app/translate/tl.dart';
import 'package:multigateway/shared/widgets/app_snackbar.dart';

class ErrorDebugDialog extends StatelessWidget {
  final dynamic error;
  final StackTrace? stackTrace;

  const ErrorDebugDialog({super.key, required this.error, this.stackTrace});

  static Future<void> show(
    BuildContext context, {
    required dynamic error,
    StackTrace? stackTrace,
  }) async {
    return showDialog(
      context: context,
      builder: (context) =>
          ErrorDebugDialog(error: error, stackTrace: stackTrace),
    );
  }

  @override
  Widget build(BuildContext context) {
    final errorString = error.toString();
    final stackString = stackTrace?.toString() ?? '';

    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.bug_report, color: Colors.red),
          const SizedBox(width: 8),
          Text(tl('Debug Error Info')),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              tl('An error occurred during API call. Here are the details:'),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildInfoBox(context, tl('Error'), errorString),
            if (stackString.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildInfoBox(context, tl('Stack Trace'), stackString),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(tl('Close')),
        ),
        ElevatedButton.icon(
          onPressed: () {
            Clipboard.setData(
              ClipboardData(
                text: 'Error: $errorString\n\nStack Trace:\n$stackString',
              ),
            );
            context.showSuccessSnackBar(tl('Copied to clipboard'));
          },
          icon: const Icon(Icons.copy, size: 18),
          label: Text(tl('Copy All')),
        ),
      ],
    );
  }

  Widget _buildInfoBox(BuildContext context, String label, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Theme.of(context).dividerColor.withAlpha(50),
            ),
          ),
          child: SelectableText(
            content,
            style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
          ),
        ),
      ],
    );
  }
}
