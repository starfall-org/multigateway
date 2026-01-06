import 'package:flutter/material.dart';
import 'package:mcp/mcp.dart';
import '../../../../core/storage/mcpserver_store.dart';
import '../../../../app/translate/tl.dart';

class EditMCPServerViewModel extends ChangeNotifier {
  // Repository
  late MCPRepository _repository;

  // Form controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController urlController = TextEditingController();

  // State
  MCPTransportType _selectedTransport = MCPTransportType.sse;
  final List<HeaderPair> _headers = [];
  bool _isLoading = false;
  String? _editingServerId;

  // Getters
  MCPTransportType get selectedTransport => _selectedTransport;
  List<HeaderPair> get headers => _headers;
  bool get isLoading => _isLoading;
  bool get isEditMode => _editingServerId != null;

  EditMCPServerViewModel() {
    _initRepository();
  }

  Future<void> _initRepository() async {
    _repository = await MCPRepository.init();
  }

  void initialize(MCPServer? server) {
    if (server != null) {
      _editingServerId = server.id;
      nameController.text = server.name;
      descriptionController.text = server.description ?? '';
      _selectedTransport = server.transport;

      if (server.httpConfig != null) {
        urlController.text = server.httpConfig!.url;
        _headers.clear();
        server.httpConfig!.headers?.forEach((key, value) {
          _headers.add(
            HeaderPair(
              TextEditingController(text: key),
              TextEditingController(text: value),
            ),
          );
        });
      }
      notifyListeners();
    } else {
      // Default values for new server
      _selectedTransport = MCPTransportType.sse;
      _headers.clear();
      addHeader(); // Add one empty header by default
    }
  }

  void updateTransport(MCPTransportType transport) {
    if (_selectedTransport != transport) {
      _selectedTransport = transport;

      // Clear URL for stdio transport
      if (transport == MCPTransportType.stdio) {
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

    if (_selectedTransport != MCPTransportType.stdio &&
        urlController.text.trim().isEmpty) {
      return tl('Please enter a server URL');
    }

    // Validate URL format for HTTP transports
    if (_selectedTransport != MCPTransportType.stdio) {
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

      final server = MCPServer(
        id:
            _editingServerId ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        name: nameController.text.trim(),
        description: descriptionController.text.trim().isEmpty
            ? null
            : descriptionController.text.trim(),
        transport: _selectedTransport,
        httpConfig: _selectedTransport != MCPTransportType.stdio
            ? MCPHttpConfig(
                url: urlController.text.trim(),
                headers: headersMap.isNotEmpty ? headersMap : null,
              )
            : null,
      );

      if (isEditMode) {
        await _repository.updateItem(server);
        if (context.mounted) {
          context.showSuccessSnackBar(tl('MCP server updated successfully'));
        }
      } else {
        await _repository.addItem(server);
        if (context.mounted) {
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
    descriptionController.dispose();
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
