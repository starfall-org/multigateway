import 'package:flutter/material.dart';
import 'package:multigateway/app/translate/tl.dart';
import 'package:multigateway/core/core.dart';
import 'package:multigateway/shared/widgets/app_snackbar.dart';

class EditMcpServerController extends ChangeNotifier {
  // Repository
  late McpServerInfoStorage _repository;

  // Form controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController urlController = TextEditingController();

  // State
  McpProtocol _selectedTransport = McpProtocol.sse;
  final List<HeaderPair> _headers = [];
  bool _isLoading = false;
  String? _editingServerId;

  // Getters
  McpProtocol get selectedTransport => _selectedTransport;
  List<HeaderPair> get headers => _headers;
  bool get isLoading => _isLoading;
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
      _selectedTransport = serverInfo.protocol;

      if (serverInfo.url != null) {
        urlController.text = serverInfo.url!;
      }

      _headers.clear();
      serverInfo.headers?.forEach((key, value) {
        _headers.add(
          HeaderPair(
            TextEditingController(text: key),
            TextEditingController(text: value),
          ),
        );
      });
      notifyListeners();
    } else {
      // Default values for new server
      _selectedTransport = McpProtocol.sse;
      _headers.clear();
      addHeader(); // Add one empty header by default
    }
  }

  void updateTransport(McpProtocol transport) {
    if (_selectedTransport != transport) {
      _selectedTransport = transport;

      // Clear URL for stdio transport
      if (transport == McpProtocol.stdio) {
        urlController.clear();
        _headers.clear();
      } else if (_headers.isEmpty) {
        addHeader(); // Add default header for HTTP transports
      }

      notifyListeners();
    }
  }

  void addHeader() {
    _headers.add(HeaderPair(TextEditingController(), TextEditingController()));
    notifyListeners();
  }

  void removeHeader(int index) {
    if (index >= 0 && index < _headers.length) {
      final header = _headers.removeAt(index);
      header.dispose();
      notifyListeners();
    }
  }

  String? validateForm() {
    if (nameController.text.trim().isEmpty) {
      return tl('Please enter a server name');
    }

    if (_selectedTransport != McpProtocol.stdio &&
        urlController.text.trim().isEmpty) {
      return tl('Please enter a server URL');
    }

    // Validate URL format for HTTP transports
    if (_selectedTransport != McpProtocol.stdio) {
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

    _isLoading = true;
    notifyListeners();

    try {
      // Prepare headers map
      final headersMap = <String, String>{};
      for (final header in _headers) {
        final key = header.key.text.trim();
        final value = header.value.text.trim();
        if (key.isNotEmpty && value.isNotEmpty) {
          headersMap[key] = value;
        }
      }

      final serverInfo = McpServerInfo(
        _editingServerId,
        nameController.text.trim(),
        _selectedTransport,
        _selectedTransport != McpProtocol.stdio
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
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    urlController.dispose();
    for (final header in _headers) {
      header.dispose();
    }
    super.dispose();
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
