import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_reorderable_grid_view/widgets/reorderable_builder.dart';
import 'package:multigateway/app/storage/preferences_storage.dart';
import 'package:multigateway/app/translate/tl.dart';
import 'package:multigateway/core/core.dart';
import 'package:multigateway/features/mcp/presentation/ui/edit_mcpserver_screen.dart';
import 'package:multigateway/features/mcp/presentation/widgets/mcp_server_card.dart';
import 'package:multigateway/features/mcp/presentation/widgets/mcp_server_tile.dart';
import 'package:multigateway/shared/widgets/app_snackbar.dart';
import 'package:multigateway/shared/widgets/confirm_dialog.dart';
import 'package:multigateway/shared/widgets/empty_state.dart';

class McpItemsPage extends StatefulWidget {
  const McpItemsPage({super.key});

  @override
  State<McpItemsPage> createState() => _McpItemsPageState();
}

class _McpItemsPageState extends State<McpItemsPage> {
  List<McpInfo> _servers = [];
  bool _isGridView = false;
  McpInfoStorage? _repository;
  Stream<List<McpInfo>>? _serversStream;

  @override
  void initState() {
    super.initState();
    _initStorage();
  }

  Future<void> _initStorage() async {
    try {
      _repository = await McpInfoStorage.init().timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException(
            'Timeout initializing MCP server repository',
            const Duration(seconds: 10),
          );
        },
      );
      if (mounted) {
        final prefs = await PreferencesStorage.instance;
        setState(() {
          _serversStream = _repository!.itemsStream;
          _isGridView = prefs.currentPreferences.showMcpAsGrid;
        });
      }
    } catch (e) {
      if (mounted) {
        context.showErrorSnackBar(
          tl('Error loading MCP servers: $e'),
          onAction: () => _initStorage(),
          actionLabel: tl('Retry'),
        );
      }
    }
  }

  Future<void> _deleteServer(String id) async {
    try {
      await _repository?.deleteItem(id);
      if (mounted) {
        context.showSuccessSnackBar(tl('MCP server has been deleted'));
      }
    } catch (e) {
      if (mounted) {
        context.showErrorSnackBar(tl('Error deleting MCP server: $e'));
      }
    }
  }

  String _getServerSubtitle(McpInfo server) {
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

    return parts.isEmpty ? 'No protocol' : parts.join(' • ');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: colorScheme.onSurface.withValues(alpha: 0.7),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              tl('MCP Servers'),
              style: theme.textTheme.titleLarge?.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              tl('Manage MCP servers'),
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.primary,
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0.5,
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
            onPressed: () async {
              setState(() {
                _isGridView = !_isGridView;
              });
              final prefs = await PreferencesStorage.instance;
              await prefs.setMcpViewMode(_isGridView);
            },
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        bottom: true,
        child: _serversStream == null
            ? const Center(child: CircularProgressIndicator())
            : StreamBuilder<List<McpInfo>>(
                stream: _serversStream,
                initialData: _servers,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting &&
                      snapshot.data == null) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final servers = snapshot.data ?? [];
                  _servers = servers; // Keep local ref

                  if (servers.isEmpty) {
                    return EmptyState(
                      icon: Icons.dns_outlined,
                      message: tl('No MCP servers found'),
                      subMessage: tl(
                        'Add an MCP server to get started with Model Context Protocol',
                      ),
                      actionLabel: tl('Add MCP Server'),
                      onAction: () => _navigateToEdit(null),
                    );
                  }

                  if (_isGridView) {
                    return ReorderableBuilder(
                      onReorder: _onReorderGrid,
                      builder: (children) => GridView.count(
                        padding: const EdgeInsets.all(16),
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 1.5,
                        children: children,
                      ),
                      children: servers.map((server) {
                        return McpItemCard(
                          key: ValueKey(server.id),
                          server: server,
                          subtitle: _getServerSubtitle(server),
                          onTap: () => _navigateToEdit(server),
                          onEdit: () => _navigateToEdit(server),
                          onDelete: () => _confirmDelete(server),
                        );
                      }).toList(),
                    );
                  }

                  return ReorderableListView.builder(
                    itemCount: servers.length,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    onReorder: _onReorder,
                    itemBuilder: (context, index) {
                      final server = servers[index];
                      return McpItemTile(
                        key: ValueKey(server.id),
                        server: server,
                        subtitle: _getServerSubtitle(server),
                        onTap: () => _navigateToEdit(server),
                        onEdit: () => _navigateToEdit(server),
                        onDelete: () => _confirmDelete(server),
                      );
                    },
                  );
                },
              ),
      ),
    );
  }

  void _onReorder(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final McpInfo item = _servers.removeAt(oldIndex);
    _servers.insert(newIndex, item);
    _repository?.saveOrder(_servers.map((e) => e.id).toList());
  }

  void _onReorderGrid(ReorderedListFunction reorderedList) {
    final newOrder = reorderedList(_servers);
    _servers = newOrder.cast<McpInfo>();
    _repository?.saveOrder(_servers.map((e) => e.id).toList());
  }

  Future<void> _navigateToEdit(McpInfo? server) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditMcpItemscreen(server: server),
      ),
    );
  }

  Future<void> _confirmDelete(McpInfo server) async {
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
