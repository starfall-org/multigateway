import 'package:flutter/material.dart';
import 'package:multigateway/core/llm/models/llm_provider_info.dart';
import 'package:multigateway/core/llm/storage/llm_provider_config_storage.dart';
import 'package:multigateway/core/llm/storage/llm_provider_models_storage.dart';
import 'package:multigateway/features/llm/presentation/controllers/edit_provider_controller.dart';
import 'package:multigateway/features/llm/presentation/widgets/provider_config/http_config_section.dart';
import 'package:multigateway/features/llm/presentation/widgets/provider_config/models_management_section.dart';
import 'package:multigateway/features/llm/presentation/widgets/provider_config/provider_info_section.dart';

/// Màn hình thêm/chỉnh sửa provider
class AddProviderScreen extends StatefulWidget {
  final LlmProviderInfo? providerInfo;

  const AddProviderScreen({super.key, this.providerInfo});

  @override
  State<AddProviderScreen> createState() => _AddProviderScreenState();
}

class _AddProviderScreenState extends State<AddProviderScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late AddProviderController _controller;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
    _controller = AddProviderController();
    _initController();
  }

  Future<void> _initController() async {
    if (widget.providerInfo != null) {
      final configStorage = await LlmProviderConfigStorage.init();
      final modelsStorage = await LlmProviderModelsStorage.init();

      final config = configStorage.getItem(widget.providerInfo!.id);
      final models = modelsStorage.getItem(widget.providerInfo!.id);

      _controller.initialize(
        providerInfo: widget.providerInfo,
        providerConfig: config,
        providerModels: models,
      );

      // Rebuild UI after loading data
      if (mounted) {
        setState(() {});
      }
    } else {
      _controller.initialize();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _controller.saveProvider(
          context,
          existingProvider: widget.providerInfo,
        ),
        label: const Text('Save'),
        icon: const Icon(Icons.save),
      ),
      bottomNavigationBar: BottomAppBar(
        elevation: 0,
        child: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.abc_rounded), text: 'Info'),
            Tab(icon: Icon(Icons.token_rounded), text: 'Models'),
            Tab(icon: Icon(Icons.http_rounded), text: 'Config'),
          ],
        ),
      ),
      body: SafeArea(
        top: true,
        bottom: true,
        child: ListenableBuilder(
          listenable: _controller,
          builder: (context, child) {
            return TabBarView(
              controller: _tabController,
              children: [
                ProviderInfoSection(controller: _controller),
                ModelsManagementSection(controller: _controller),
                HttpConfigSection(controller: _controller),
              ],
            );
          },
        ),
      ),
    );
  }
}
