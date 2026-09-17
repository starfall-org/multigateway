package org.starfall.multigateway.ui

import androidx.compose.foundation.layout.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import kotlinx.coroutines.launch
import org.starfall.multigateway.data.local.preferences.AppPreferences
import org.starfall.multigateway.data.model.*
import org.starfall.multigateway.ui.chat.ChatScreen
import org.starfall.multigateway.ui.drawer.ConversationsDrawer
import org.starfall.multigateway.ui.drawer.MenuView
import org.starfall.multigateway.ui.mcp.McpScreen
import org.starfall.multigateway.ui.profiles.ProfileScreen
import org.starfall.multigateway.ui.providers.ProviderScreen
import org.starfall.multigateway.ui.settings.SettingsScreen
import org.starfall.multigateway.ui.speech.SpeechScreen
import org.starfall.multigateway.ui.chat.ChatViewModel
import org.starfall.multigateway.ui.configuration.ConfigurationViewModel
import org.starfall.multigateway.ui.settings.SettingsViewModel
import org.starfall.multigateway.data.tools.ToolFiles
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController
import androidx.activity.compose.BackHandler
import org.starfall.multigateway.ui.navigation.AppDestination
import org.starfall.multigateway.ui.tools.*

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun MainScreen(
    viewModel: ChatViewModel,
    configurationViewModel: ConfigurationViewModel,
    settingsViewModel: SettingsViewModel,
    toolFiles: ToolFiles,
) {
    val drawerState = rememberDrawerState(initialValue = DrawerValue.Closed)
    val coroutineScope = rememberCoroutineScope()

    val navController = rememberNavController()
    fun navigate(destination: AppDestination) {
        navController.navigate(destination.route) {
            popUpTo(AppDestination.CHAT.route) { saveState = true }
            launchSingleTop = true
            restoreState = true
        }
    }
    var showEndMenuSheet by rememberSaveable { mutableStateOf(false) }

    val conversations: List<Conversation> by viewModel.conversations.collectAsStateWithLifecycle()
    val currentConv: Conversation? by viewModel.currentConversation.collectAsStateWithLifecycle()
    val isGenerating: Boolean by viewModel.isGenerating.collectAsStateWithLifecycle()
    val generatingConversationId by viewModel.generatingConversationId.collectAsStateWithLifecycle()
    val chatError by viewModel.chatError.collectAsStateWithLifecycle()
    val appPrefs: AppPreferences by settingsViewModel.preferences.collectAsStateWithLifecycle()
    val profiles: List<ChatProfile> by viewModel.profiles.collectAsStateWithLifecycle()
    val providers: List<LlmProviderInfo> by viewModel.providers.collectAsStateWithLifecycle()
    val mcpServers: List<McpInfo> by viewModel.mcpServers.collectAsStateWithLifecycle()
    val speechServices: List<SpeechService> by configurationViewModel.speechServices.collectAsStateWithLifecycle()

    val toolSettings by viewModel.toolSettings.collectAsStateWithLifecycle()

    val activeProfile: ChatProfile? = appPrefs.selectedProfileId?.let { id -> profiles.find { it.id == id } }

    CompositionLocalProvider(LocalToolControls provides ToolControls(mcpServers, activeProfile, toolSettings, providers.find { it.id == appPrefs.selectedProviderId }?.config?.modelConfigs?.get(appPrefs.selectedModelId)?.supportsToolCalls == true, viewModel::setSystemTool, viewModel::setQuickMcp)) {
        ModalNavigationDrawer(
            drawerState = drawerState,
            drawerContent = {
                ConversationsDrawer(
                    conversations = conversations,
                    currentConversationId = currentConv?.id,
                    selectedProfile = activeProfile,
                    profiles = profiles,
                    onSelectConversation = {
                        viewModel.selectConversation(it)
                        navigate(AppDestination.CHAT)
                    },
                    onNewChat = {
                        viewModel.startNewChat()
                        navigate(AppDestination.CHAT)
                    },
                    onRenameConversation = { id, newTitle ->
                        viewModel.renameConversation(id, newTitle)
                    },
                    onDeleteConversation = {
                        viewModel.deleteConversation(it)
                    },
                    onSelectProfile = { profile ->
                        viewModel.selectProfile(profile.id)
                    },
                    onNavigateToProfiles = {
                        navigate(AppDestination.PROFILES)
                    },
                    onCloseDrawer = {
                        coroutineScope.launch { drawerState.close() }
                    }
                )
            }
        ) {
            Box(modifier = Modifier.fillMaxSize()) {
                NavHost(navController = navController, startDestination = AppDestination.CHAT.route) {
                    composable(AppDestination.CHAT.route) {
                        ChatScreen(
                            conversation = currentConv,
                            selectedProfile = activeProfile,
                            isGenerating = isGenerating,
                            generatingConversationId = generatingConversationId,
                            chatError = chatError,
                            providers = providers,
                            selectedProviderId = appPrefs.selectedProviderId,
                            selectedModelName = appPrefs.selectedModelId.ifBlank { "gpt-4o" },
                            onSendMessage = { text, files ->
                                viewModel.sendMessage(text, files)
                            },
                            onStopGenerating = {
                                viewModel.stopGeneration()
                            },
                            onOpenDrawer = {
                                coroutineScope.launch { drawerState.open() }
                            },
                            onOpenEndDrawer = {
                                showEndMenuSheet = true
                            },
                            onRegenerate = { id ->
                                viewModel.regenerateMessage(id)
                            },
                            onEditMessage = { id, content ->
                                viewModel.editMessage(id, content)
                            },
                            onDeleteMessage = { id ->
                                viewModel.deleteMessage(id)
                            },
                            onSwitchVersion = { id, idx ->
                                viewModel.switchMessageVersion(id, idx)
                            },
                            onSaveModelConfig = configurationViewModel::saveModelConfiguration,
                            onSelectModel = { provId, modelId ->
                                viewModel.selectModel(provId, modelId)
                            },
                            onReadMessage = { text ->
                                viewModel.speakText(text)
                            },
                            onFetchOllamaModels = { url ->
                                configurationViewModel.fetchOllamaModels(url)
                            }
                        )
                    }

                    composable(AppDestination.PROFILES.route) {
                        ProfileScreen(
                            profiles = profiles,
                            mcpServers = mcpServers,
                            discoverTools = { configurationViewModel.discoverTools(it) },
                            selectedProfileId = appPrefs.selectedProfileId,
                            onSelectProfile = { viewModel.selectProfile(it) },
                            onSaveProfile = { configurationViewModel.saveProfile(it) },
                            onDeleteProfile = { configurationViewModel.deleteProfile(it) },
                            onBack = { navController.popBackStack() }
                        )
                    }

                    composable(AppDestination.PROVIDERS.route) {
                        ProviderScreen(
                            providers = providers,
                            onSaveProvider = { configurationViewModel.saveProvider(it) },
                            onDeleteProvider = { configurationViewModel.deleteProvider(it) },
                            onTestConnection = { prov -> configurationViewModel.testConnection(prov) },
                            onFetchModels = { provider -> configurationViewModel.fetchProviderModels(provider) },
                            onBack = { navController.popBackStack() }
                        )
                    }

                    composable(AppDestination.MCP.route) {
                        McpScreen(
                            mcpServers = mcpServers,
                            onSaveMcpServer = { configurationViewModel.saveMcpServer(it) },
                            onDeleteMcpServer = { configurationViewModel.deleteMcpServer(it) },
                            onDiscoverTools = { configurationViewModel.discoverTools(it) },
                            onBack = { navController.popBackStack() }
                        )
                    }

                    composable(AppDestination.SPEECH.route) {
                        SpeechScreen(
                            speechServices = speechServices,
                            onSaveService = { configurationViewModel.saveSpeechService(it) },
                            onDeleteService = { configurationViewModel.deleteSpeechService(it) },
                            onTestVoice = { text, speed, pitch ->
                                viewModel.testVoice(text, speed, pitch)
                            },
                            onBack = { navController.popBackStack() }
                        )
                    }

                    composable(AppDestination.SYSTEM_TOOLS.route) { SystemToolsScreen(providers, toolSettings, viewModel::setSystemTool) { navController.popBackStack() } }
                    composable(AppDestination.STORAGE.route) { StorageScreen(toolFiles) { navController.popBackStack() } }
                    composable(AppDestination.SETTINGS.route) {
                        SettingsScreen(
                            appPreferences = appPrefs,
                            conversationCount = conversations.size,
                            profileCount = profiles.size,
                            providerCount = providers.size,
                            onThemeChange = { mode ->
                                settingsViewModel.setThemeMode(mode)
                            },
                            onDynamicColorChange = { use ->
                                settingsViewModel.setUseDynamicColor(use)
                            },
                            onColorSchemeChange = { scheme ->
                                settingsViewModel.setColorSchemeName(scheme)
                            },
                            onContinueLastConversationChange = { value ->
                                settingsViewModel.setContinueLastConversation(value)
                            },
                            onPersistChatSelectionChange = { value ->
                                settingsViewModel.setPersistChatSelection(value)
                            },
                            onEnableVibrationChange = { value ->
                                settingsViewModel.setEnableVibration(value)
                            },
                            onHideStatusBarChange = { value ->
                                settingsViewModel.setHideStatusBar(value)
                            },
                            onDebugModeChange = { value ->
                                settingsViewModel.setDebugMode(value)
                            },
                            onClearAllConversations = {
                                viewModel.clearAllConversations()
                            },
                            onResetAllData = {
                                viewModel.deleteAllUserData()
                            },
                            onBack = { navController.popBackStack() }
                        )
                    }
                }

                // Right-side Menu bottom sheet
                if (showEndMenuSheet) {
                    ModalBottomSheet(
                        onDismissRequest = { showEndMenuSheet = false },
                        sheetState = rememberModalBottomSheetState(skipPartiallyExpanded = true)
                    ) {
                        MenuView(
                            selectedProfile = activeProfile,
                            onNavigateToProfiles = {
                                navigate(AppDestination.PROFILES)
                                showEndMenuSheet = false
                            },
                            onEditProfile = {
                                navigate(AppDestination.PROFILES)
                                showEndMenuSheet = false
                            },
                            onNavigateToProviders = {
                                navigate(AppDestination.PROVIDERS)
                                showEndMenuSheet = false
                            },
                            onNavigateToMcp = {
                                navigate(AppDestination.MCP)
                                showEndMenuSheet = false
                            },
                            onNavigateToSpeech = {
                                navigate(AppDestination.SPEECH)
                                showEndMenuSheet = false
                            },
                            onNavigateToSystemTools = { navigate(AppDestination.SYSTEM_TOOLS); showEndMenuSheet = false },
                            onNavigateToStorage = { navigate(AppDestination.STORAGE); showEndMenuSheet = false },
                            onNavigateToSettings = {
                                navigate(AppDestination.SETTINGS)
                                showEndMenuSheet = false
                            },
                            onCloseMenu = {
                                showEndMenuSheet = false
                            },
                            modifier = Modifier.fillMaxWidth()
                        )
                    }
                }
            }
        }
    }
    BackHandler(enabled = drawerState.isOpen) {
        coroutineScope.launch { drawerState.close() }
    }
}
