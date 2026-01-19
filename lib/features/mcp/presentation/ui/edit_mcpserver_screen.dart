import 'package:flutter/material.dart';
import 'package:multigateway/app/translate/tl.dart';
import 'package:multigateway/core/core.dart';
import 'package:multigateway/features/mcp/presentation/controllers/edit_mcpserver_controller.dart';
import 'package:multigateway/features/mcp/presentation/widgets/mcp_controller_provider.dart';
import 'package:multigateway/features/mcp/presentation/widgets/mcp_tabs/mcp_config_tab.dart';
import 'package:multigateway/features/mcp/presentation/widgets/mcp_tabs/mcp_tools_tab.dart';
import 'package:signals_flutter/signals_flutter.dart';

/// Màn hình thêm/chỉnh sửa MCP server
class EditMcpItemscreen extends StatefulWidget {
  final McpInfo? server;

  const EditMcpItemscreen({super.key, this.server});

  @override
  State<EditMcpItemscreen> createState() => _EditMcpItemscreenState();
}

class _EditMcpItemscreenState extends State<EditMcpItemscreen>
    with SingleTickerProviderStateMixin {
  late EditMcpItemController _controller;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {}); // Rebuild to show/hide FAB based on tab
    });
    _controller = EditMcpItemController();
    _controller.initialize(widget.server);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return McpControllerProvider(
      controller: _controller,
      child: Watch((context) {
        final isLoading = _controller.isLoading.value;

        return Scaffold(
          appBar: AppBar(
            title: Text(
              widget.server == null
                  ? tl('Add MCP Server')
                  : tl('Edit MCP Server'),
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _controller.saveServer(context),
            label: Text(tl('Save')),
            icon: isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.save),
          ),
          bottomNavigationBar: BottomAppBar(
            elevation: 0,
            child: TabBar(
              controller: _tabController,
              tabs: [
                Tab(icon: const Icon(Icons.edit), text: tl('Config')),
                Tab(icon: const Icon(Icons.build), text: tl('Tools')),
              ],
            ),
          ),
          body: SafeArea(
            top: true,
            bottom: true,
            child: TabBarView(
              controller: _tabController,
              children: const [McpConfigTab(), McpToolsTab()],
            ),
          ),
        );
      }),
    );
  }
}
