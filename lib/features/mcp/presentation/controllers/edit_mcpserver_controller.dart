import 'package:flutter/material.dart';
import 'package:multigateway/app/translate/tl.dart';
import 'package:multigateway/core/core.dart';
import 'package:multigateway/shared/widgets/app_snackbar.dart';
import 'package:signals/signals.dart';

class EditMcpServerController {
  // Repository
  late McpServerInfoStorage _repository;

  // Form controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController urlController = TextEditingController();

  // State
  final selectedTransport = signal<McpProtocol>(McpProtocol.sse);
  final headers = signal<List<HeaderPair>>([]);
  final isLoading = signal<bool>(false);
  String? _editingServerId;

  // Getters
  bool get isEditMode => _editingServerId != null;

  EditMcpServerController() {
    _initRepository();
  }

  Future<void> _initRepository() async {
    _repository = await McpServerInfoStorage.init();
  }

  void initialize(McpServerInfo? serverInfo) {
    if (serverInfo != null) {
      _editingServerId = serverInfo.id;
      nameController.text = serverInfo.name;
      selectedTransport.value = serverInfo.protocol;

      if (serverInfo.url != null) {
        urlController.text = serverInfo.url!;
      }

      final headersList = <HeaderPair>[];
      serverInfo.headers?.forEach((key, value) {
        headersList.add(
          HeaderPair(
            TextEditingController(text: key),
            TextEditingController(text: value),
          ),
        );
      });
      headers.value = headersList;
    } else {
      // Default values for new server
      selectedTransport.value = McpProtocol.sse;
      headers.value = [];
      addHeader(); // Add one empty header by default
    }
  }

  void updateTransport(McpProtocol transport) {
    if (selectedTransport.value != transport) {
      selectedTransport.value = transport;

      // Clear URL for stdio transport
      if (transport == McpProtocol.stdio) {
        urlController.clear();
        headers.value = [];
      } else if (headers.value.isEmpty) {
        addHeader(); // Add default header for HTTP transports
      }
    }
  }

  void addHeader() {
    final list = List<HeaderPair>.from(headers.value);
    list.add(HeaderPair(TextEditingController(), TextEditingController()));
    headers.value = list;
  }

  void removeHeader(int index) {
    final list = List<HeaderPair>.from(headers.value);
    if (index >= 0 && index < list.length) {
      final header = list.removeAt(index);
      header.dispose();
      headers.value = list;
    }
  }

  String? validateForm() {
    if (nameController.text.trim().isEmpty) {
      return tl('Please enter a server name');
    }

    if (selectedTransport.value != McpProtocol.stdio &&
        urlController.text.trim().isEmpty) {
      return tl('Please enter a server URL');
    }

    // Validate URL format for HTTP transports
    if (selectedTransport.value != McpProtocol.stdio) {
      final url = urlController.text.trim();
      final uri = Uri.tryParse(url);
      if (uri == null || !uri.hasAbsolutePath) {
        return tl('Please enter a valid URL');
      }
    }

    return null;
  }

  Future<void> saveServer(BuildContext context) async {
    final validationError = validateForm();
    if (validationError != null) {
      if (context.mounted) {
        context.showErrorSnackBar(validationError);
      }
      return;
    }

    isLoading.value = true;

    try {
      // Prepare headers map
      final headersMap = <String, String>{};
      for (final header in headers.value) {
        final key = header.key.text.trim();
        final value = header.value.text.trim();
        if (key.isNotEmpty && value.isNotEmpty) {
          headersMap[key] = value;
        }
      }

      final serverInfo = McpServerInfo(
        _editingServerId,
        nameController.text.trim(),
        selectedTransport.value,
        selectedTransport.value != McpProtocol.stdio
            ? urlController.text.trim()
            : null,
        headersMap.isNotEmpty ? headersMap : null,
        null, // stdioConfig
      );

      await _repository.saveItem(serverInfo);

      if (context.mounted) {
        if (isEditMode) {
          context.showSuccessSnackBar(tl('MCP server updated successfully'));
        } else {
          context.showSuccessSnackBar(tl('MCP server added successfully'));
        }
      }

      if (context.mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (context.mounted) {
        context.showErrorSnackBar(tl('Error saving MCP server: $e'));
      }
    } finally {
      isLoading.value = false;
    }
  }

  void dispose() {
    nameController.dispose();
    urlController.dispose();
    for (final header in headers.value) {
      header.dispose();
    }
    selectedTransport.dispose();
    headers.dispose();
    isLoading.dispose();
  }
}

class HeaderPair {
  final TextEditingController key;
  final TextEditingController value;

  HeaderPair(this.key, this.value);

  void dispose() {
    key.dispose();
    value.dispose();
  }
}
