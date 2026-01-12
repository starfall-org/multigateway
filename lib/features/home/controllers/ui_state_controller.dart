import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mcp/mcp.dart';
import 'package:multigateway/app/translate/tl.dart';
import 'package:multigateway/core/llm/models/llm_provider_info.dart';
import 'package:multigateway/core/llm/models/llm_provider_models.dart';
import 'package:multigateway/core/llm/storage/llm_provider_info_storage.dart';
import 'package:multigateway/core/llm/storage/llm_provider_models_storage.dart';
import 'package:multigateway/core/mcp/storage/mcp_server_info_storage.dart';
import 'package:multigateway/core/profile/profile.dart';
import 'package:multigateway/features/home/services/file_pick_service.dart';
import 'package:multigateway/features/home/services/gallery_pick_service.dart';
import 'package:multigateway/shared/widgets/app_snackbar.dart';

/// Controller hợp nhất xử lý UI state, attachment, model selection và profile
class UiStateController extends ChangeNotifier {
  // === Attachment Management ===
  final List<String> pendingFiles = [];
  final List<String> inspectingFiles = [];

  // === Model Selection ===
  final LlmProviderInfoStorage pInfStorage;
  final LlmProviderModelsStorage pModStorage;
  
  StreamSubscription? _providerSubscription;
  List<LlmProviderInfo> providers = [];
  Map<String, List<LlmModel>> providerModels = {};
  final Map<String, bool> providerCollapsed = {};
  String? selectedProviderName;
  String? selectedModelName;

  // === Profile Management ===
  final ChatProfileStorage aiProfileRepository;
  final McpServerInfoStorage mcpServerStorage;
  
  ChatProfile? selectedProfile;
  List<McpServer> mcpServers = [];

  UiStateController({
    required this.pInfStorage,
    required this.pModStorage,
    required this.aiProfileRepository,
    required this.mcpServerStorage,
  }) {
    _providerSubscription = pInfStorage.changes.listen((_) {
      refreshProviders();
    });
  }

  // === Attachment Methods ===
  Future<void> pickFromFiles(BuildContext context) async {
    try {
      filePickService(pendingFiles);
      notifyListeners();
    } catch (e) {
      if (context.mounted) {
        context.showErrorSnackBar(tl('Unable to pick files: ${e.toString()}'));
      }
    }
  }

  Future<void> pickFromGallery(BuildContext context) async {
    try {
      galleryPickService(pendingFiles);
      notifyListeners();
    } catch (e) {
      if (context.mounted) {
        context.showErrorSnackBar(tl('Unable to pick files: ${e.toString()}'));
      }
    }
  }

  void removeAttachmentAt(int index) {
    if (index < 0 || index >= pendingFiles.length) return;
    pendingFiles.removeAt(index);
    notifyListeners();
  }

  void clearPendingAttachments() {
    pendingFiles.clear();
    notifyListeners();
  }

  void setInspectingAttachments(List<String> attachments) {
    inspectingFiles
      ..clear()
      ..addAll(attachments);
    notifyListeners();
  }

  void openFilesDialog(List<String> attachments) {
    setInspectingAttachments(attachments);
  }

  void clearInspectingAttachments() {
    inspectingFiles.clear();
    notifyListeners();
  }

  // === Model Selection Methods ===
  LlmModel? get selectedLlmModel {
    if (selectedProviderName == null || selectedModelName == null) return null;
    try {
      final provider = providers.firstWhere(
        (p) => p.name == selectedProviderName,
      );
      final models = providerModels[provider.id];
      if (models == null) return null;
      return models.firstWhere((m) => m.id == selectedModelName);
    } catch (e) {
      return null;
    }
  }

  Future<void> refreshProviders() async {
    providers = pInfStorage.getItems();
    providerModels.clear();

    for (final p in providers) {
      providerCollapsed.putIfAbsent(p.name, () => false);
      final modelsObj = pModStorage.getItem(p.id);
      if (modelsObj != null) {
        providerModels[p.id] = modelsObj.models.whereType<LlmModel>().toList();
      } else {
        providerModels[p.id] = [];
      }
    }
    notifyListeners();
  }

  void setProviderCollapsed(String providerName, bool collapsed) {
    providerCollapsed[providerName] = collapsed;
    notifyListeners();
  }

  void selectModel(String providerName, String modelName) {
    selectedProviderName = providerName;
    selectedModelName = modelName;
    notifyListeners();
  }

  void loadSelectionFromSession({String? providerName, String? modelName}) {
    if (providerName != null && modelName != null) {
      selectedProviderName = providerName;
      selectedModelName = modelName;
      notifyListeners();
    }
  }

  // === Profile Methods ===
  Future<void> loadSelectedProfile() async {
    final profile = await aiProfileRepository.getOrInitSelectedProfile();
    selectedProfile = profile;
    notifyListeners();
  }

  Future<void> updateProfile(ChatProfile profile) async {
    selectedProfile = profile;
    await aiProfileRepository.saveItem(profile);
    notifyListeners();
  }

  Future<void> loadMcpServers() async {
    mcpServers = mcpServerStorage.getItems().whereType<McpServer>().toList();
    notifyListeners();
  }

  Future<List<String>> snapshotEnabledToolNames(ChatProfile profile) async {
    try {
      final mcpRepo = McpServerInfoStorage.instance;
      final servers = profile.activeMcpServerIds
          .map((id) => mcpRepo.getItem(id))
          .whereType<McpServer>()
          .toList();
      final names = <String>{};
      for (final s in servers) {
        for (final t in s.tools) {
          if (t.enabled) names.add(t.name);
        }
      }
      return names.toList();
    } catch (_) {
      return const <String>[];
    }
  }

  @override
  void dispose() {
    _providerSubscription?.cancel();
    super.dispose();
  }
}