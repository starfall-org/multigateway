import 'package:flutter/material.dart';
import 'package:multigateway/app/translate/tl.dart';
import 'package:multigateway/core/core.dart';
import 'package:multigateway/features/mcp/controllers/edit_mcpserver_controller.dart';
import 'package:multigateway/features/mcp/ui/widgets/mcp_controller_provider.dart';
import 'package:multigateway/features/mcp/ui/widgets/mcp_tabs/mcp_config_tab.dart';
import 'package:multigateway/features/mcp/ui/widgets/mcp_tabs/mcp_connection_tab.dart';
import 'package:multigateway/features/mcp/ui/widgets/mcp_tabs/mcp_info_tab.dart';

/// Màn hình thêm/chỉnh sửa MCP server
class EditMcpServerscreen extends StatefulWidget {
  final McpServerInfo? server;

  const EditMcpServerscreen({super.key, this.server});

  @override
  State<EditMcpServerscreen> createState() => _EditMcpServerscreenState();
}

class _EditMcpServerscreenState extends State<EditMcpServerscreen>
    with SingleTickerProviderStateMixin {
  late EditMcpServerController _controller;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {}); // Rebuild to show/hide FAB based on tab
    });
    _controller = EditMcpServerController();
    _controller.addListener(_onControllerChanged);
    _controller.initialize(widget.server);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _controller.removeListener(_onControllerChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return McpControllerProvider(
      controller: _controller,
      child: Scaffold(
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _controller.saveServer(context),
          label: Text(tl('Save')),
          icon: _controller.isLoading
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
            tabs: const [
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
            children: const [
              McpConfigTab(),
              McpConnectionTab(),
              McpInfoTab(),
            ],
          ),
        ),
      ),
    );
  }
}
