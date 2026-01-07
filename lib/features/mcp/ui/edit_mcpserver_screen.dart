import 'package:flutter/material.dart';
import 'package:multigateway/app/translate/tl.dart';
import 'package:multigateway/core/core.dart';
import 'package:multigateway/features/mcp/controllers/edit_mcpserver_controller.dart';
import 'package:multigateway/shared/widgets/common_dropdown.dart';
import 'package:multigateway/shared/widgets/custom_text_field.dart';

class EditMcpServerscreen extends StatefulWidget {
  final McpServerInfo? server;

  const EditMcpServerscreen({super.key, this.server});

  @override
  State<EditMcpServerscreen> createState() => _EditMcpServerscreenState();
}

class _EditMcpServerscreenState extends State<EditMcpServerscreen>
    with SingleTickerProviderStateMixin {
  late EditMcpServerViewModel _viewModel;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {}); // Rebuild to show/hide FAB based on tab
    });
    _viewModel = EditMcpServerViewModel();
    _viewModel.addListener(_onViewModelChanged);
    _viewModel.initialize(widget.server);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _viewModel.removeListener(_onViewModelChanged);
    _viewModel.dispose();
    super.dispose();
  }

  void _onViewModelChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _viewModel.saveServer(context),
        label: Text(tl('Save')),
        icon: _viewModel.isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.save),
      ),
      bottomNavigationBar: BottomAppBar(
        elevation: 0,
        child: TabBar(
          controller: _tabController,
          tabs: [
            Tab(icon: Icon(Icons.edit), text: 'Config'),
            Tab(icon: Icon(Icons.http), text: 'Connection'),
            Tab(icon: Icon(Icons.info), text: 'Info'),
          ],
        ),
      ),
      body: SafeArea(
        top: true,
        bottom: true,
        child: TabBarView(
          controller: _tabController,
          children: [_buildConfigTab(), _buildConnectionTab(), _buildInfoTab()],
        ),
      ),
    );
  }

  Widget _buildConfigTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Transport Type Selection
        CommonDropdown<McpProtocol>(
          value: _viewModel.selectedTransport,
          labelText: tl('Transport Type'),
          options: McpProtocol.values.map((transport) {
            return DropdownOption<McpProtocol>(
              value: transport,
              label: _getTransportLabel(transport),
              icon: _getTransportIcon(transport),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              _viewModel.updateTransport(value);
            }
          },
        ),

        const SizedBox(height: 24),

        // Basic Information
        Text(
          tl('Basic Information'),
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        // Server Name
        CustomTextField(
          controller: _viewModel.nameController,
          label: tl('Server Name'),
          hint: tl('Enter a descriptive name for this MCP server'),
          prefixIcon: Icons.dns_outlined,
        ),

        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildConnectionTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Connection Settings
        if (_viewModel.selectedTransport != McpProtocol.stdio) ...[
          Text(
            tl('Connection Settings'),
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Server URL
          CustomTextField(
            controller: _viewModel.urlController,
            label: tl('Server URL'),
            hint: _getUrlHint(_viewModel.selectedTransport),
            prefixIcon: Icons.link,
            keyboardType: TextInputType.url,
          ),

          const SizedBox(height: 24),

          // Headers Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                tl('HTTP Headers'),
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                onPressed: _viewModel.addHeader,
                tooltip: tl('Add Header'),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Headers List
          if (_viewModel.headers.isEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      tl(
                        'No headers configured. Add headers for authentication or other custom needs.',
                      ),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            ..._viewModel.headers.asMap().entries.map((entry) {
              final index = entry.key;
              final header = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              '${tl('Header')} ${index + 1}',
                              style: Theme.of(context).textTheme.labelLarge,
                            ),
                            const Spacer(),
                            IconButton(
                              icon: Icon(
                                Icons.delete_outline,
                                color: Theme.of(context).colorScheme.error,
                                size: 20,
                              ),
                              onPressed: () => _viewModel.removeHeader(index),
                              tooltip: tl('Remove Header'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: CustomTextField(
                                controller: header.key,
                                label: tl('Header Name'),
                                hint: 'Authorization, Content-Type, etc.',
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: CustomTextField(
                                controller: header.value,
                                label: tl('Header Value'),
                                hint: 'Bearer token, application/json, etc.',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
        ] else ...[
          // STDIO Information
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.terminal,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      tl('STDIO Transport'),
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  tl(
                    'STDIO transport is used for local MCP servers that communicate through standard input/output streams. This is typically used for command-line tools and local processes.',
                  ),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildInfoTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Transport Information Card
        _buildTransportInfoCard(),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildTransportInfoCard() {
    String title;
    String description;
    IconData icon;
    Color color;

    switch (_viewModel.selectedTransport) {
      case McpProtocol.sse:
        title = tl('Server-Sent Events (SSE)');
        description = tl(
          'SSE provides real-time communication over HTTP. Best for servers that need to send continuous updates to clients.',
        );
        icon = Icons.stream;
        color = Theme.of(context).colorScheme.primary;
        break;
      case McpProtocol.streamableHttp:
        title = tl('Streamable HTTP');
        description = tl(
          'Streamable HTTP is the recommended transport for new MCP implementations. It provides efficient bidirectional communication.',
        );
        icon = Icons.http;
        color = Theme.of(context).colorScheme.tertiary;
        break;
      case McpProtocol.stdio:
        title = tl('Standard I/O (STDIO)');
        description = tl(
          'STDIO transport communicates through standard input/output. Perfect for local command-line tools and processes.',
        );
        icon = Icons.terminal;
        color = Theme.of(context).colorScheme.secondary;
        break;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getTransportLabel(McpProtocol transport) {
    switch (transport) {
      case McpProtocol.sse:
        return tl('Server-Sent Events (SSE)');
      case McpProtocol.streamableHttp:
        return tl('Streamable HTTP');
      case McpProtocol.stdio:
        return tl('Standard I/O (STDIO)');
    }
  }

  Icon _getTransportIcon(McpProtocol transport) {
    switch (transport) {
      case McpProtocol.sse:
        return const Icon(Icons.stream);
      case McpProtocol.streamableHttp:
        return const Icon(Icons.http);
      case McpProtocol.stdio:
        return const Icon(Icons.terminal);
    }
  }

  String _getUrlHint(McpProtocol transport) {
    switch (transport) {
      case McpProtocol.sse:
        return 'https://example.com/mcp/sse';
      case McpProtocol.streamableHttp:
        return 'https://example.com/mcp/';
      case McpProtocol.stdio:
        return '';
    }
  }
}
