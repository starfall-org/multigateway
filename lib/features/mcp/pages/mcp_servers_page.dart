import 'dart:async';

import 'package:flutter/material.dart';
import 'package:multigateway/app/translate/tl.dart';
import 'package:multigateway/core/core.dart';
import 'package:multigateway/features/mcp/ui/edit_mcpserver_screen.dart';
import 'package:multigateway/features/mcp/ui/widgets/mcp_server_card.dart';
import 'package:multigateway/features/mcp/ui/widgets/mcp_server_tile.dart';
import 'package:multigateway/shared/widgets/app_snackbar.dart';
import 'package:multigateway/shared/widgets/confirm_dialog.dart';
import 'package:multigateway/shared/widgets/empty_state.dart';

class McpServersPage extends StatefulWidget {
  const McpServersPage({super.key});

  @override
  State<McpServersPage> createState() => _McpServersPageState();
}

class _McpServersPageState extends State<McpServersPage> {
  List<McpServerInfo> _servers = [];
  bool _isLoading = true;
  bool _isGridView = false;
  late McpServerInfoStorage _repository;

  @override
  void initState() {
    super.initState();
    _loadServers();
  }

  Future<void> _loadServers() async {
    // Only prevent if already loading (not the initial state)
    if (_isLoading && _servers.isNotEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Add timeout to prevent infinite loading
      _repository = await McpServerInfoStorage.init().timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException(
            'Timeout initializing MCP server repository',
            const Duration(seconds: 10),
          );
        },
      );

      final servers = _repository.getItems();

      if (mounted) {
        setState(() {
          _servers = servers;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        context.showErrorSnackBar(
          tl('Error loading MCP servers: $e'),
          onAction: () => _loadServers(),
          actionLabel: tl('Retry'),
        );
      }
    }
  }

  Future<void> _deleteServer(String id) async {
    try {
      await _repository.deleteItem(id);
      await _loadServers(); // Use await to ensure proper sequencing
      if (mounted) {
        context.showSuccessSnackBar(tl('MCP server has been deleted'));
      }
    } catch (e) {
      if (mounted) {
        context.showErrorSnackBar(tl('Error deleting MCP server: $e'));
      }
    }
  }

  String _getServerSubtitle(McpServerInfo server) {
    final List<String> parts = [];

    // Add transport type
    switch (server.protocol) {
      case McpProtocol.stdio:
        parts.add('STDIO');
        break;
      case McpProtocol.sse:
        parts.add('SSE');
        break;
      case McpProtocol.streamableHttp:
        parts.add('Streamable');
        break;
    }

    // Note: Tool/resource counts would come from McpServerTools
    // For now, just show the protocol
    return parts.isEmpty ? 'No protocol' : parts.join(' • ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tl('MCP Servers')),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        iconTheme: IconThemeData(
          color: Theme.of(context).colorScheme.onSurface,
        ),
        titleTextStyle: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
          fontSize: 20,
        ),
        actions: [
          // Add button
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: tl('Add MCP Server'),
            onPressed: () => _navigateToEdit(null),
          ),
          // View toggle button
          IconButton(
            icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
            tooltip: _isGridView ? tl('List view') : tl('Grid view'),
            onPressed: () {
              setState(() {
                _isGridView = !_isGridView;
              });
            },
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        bottom: true,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _servers.isEmpty
            ? EmptyState(
                icon: Icons.dns_outlined,
                message: tl('No MCP servers found'),
                subMessage: tl(
                  'Add an MCP server to get started with Model Context Protocol',
                ),
                actionLabel: tl('Add MCP Server'),
                onAction: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EditMcpServerscreen(),
                    ),
                  );
                  if (result == true) {
                    _loadServers();
                  }
                },
              )
            : _isGridView
            ? GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.5,
                ),
                itemCount: _servers.length,
                itemBuilder: (context, index) {
                  final server = _servers[index];
                  return McpServerCard(
                    server: server,
                    subtitle: _getServerSubtitle(server),
                    onTap: () => _navigateToEdit(server),
                    onEdit: () => _navigateToEdit(server),
                    onDelete: () => _confirmDelete(server),
                  );
                },
              )
            : ReorderableListView.builder(
                itemCount: _servers.length,
                padding: const EdgeInsets.symmetric(vertical: 8),
                onReorder: _onReorder,
                itemBuilder: (context, index) {
                  final server = _servers[index];
                  return McpServerTile(
                    key: ValueKey(server.id),
                    server: server,
                    subtitle: _getServerSubtitle(server),
                    onTap: () => _navigateToEdit(server),
                    onEdit: () => _navigateToEdit(server),
                    onDelete: () => _confirmDelete(server),
                  );
                },
              ),
      ),
    );
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }
      final McpServerInfo item = _servers.removeAt(oldIndex);
      _servers.insert(newIndex, item);
    });
    _repository.saveOrder(_servers.map((e) => e.id).toList());
  }

  Future<void> _navigateToEdit(McpServerInfo? server) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditMcpServerscreen(server: server),
      ),
    );
    if (result == true) {
      _loadServers();
    }
  }

  Future<void> _confirmDelete(McpServerInfo server) async {
    final confirm = await ConfirmDialog.show(
      context,
      title: tl('Delete'),
      content: tl('Are you sure you want to delete ${server.name}?'),
      confirmLabel: tl('Delete'),
      isDestructive: true,
    );

    if (confirm == true) {
      _deleteServer(server.id);
    }
  }
}
