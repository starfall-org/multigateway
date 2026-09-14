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
import org.starfall.multigateway.ui.viewmodel.MainViewModel
import org.starfall.multigateway.ui.tools.*

enum class Screen {
    CHAT,
    PROFILES,
    PROVIDERS,
    MCP,
    SPEECH,
    SETTINGS,
    SYSTEM_TOOLS,
    STORAGE
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun MainScreen(viewModel: MainViewModel) {
    val drawerState = rememberDrawerState(initialValue = DrawerValue.Closed)
    val coroutineScope = rememberCoroutineScope()

    var currentScreen by remember { mutableStateOf(Screen.CHAT) }
    var showEndMenuSheet by remember { mutableStateOf(false) }

    val conversations: List<Conversation> by viewModel.conversations.collectAsStateWithLifecycle()
    val currentConv: Conversation? by viewModel.currentConversation.collectAsStateWithLifecycle()
    val isGenerating: Boolean by viewModel.isGenerating.collectAsStateWithLifecycle()
    val generatingConversationId by viewModel.generatingConversationId.collectAsStateWithLifecycle()
    val chatError by viewModel.chatError.collectAsStateWithLifecycle()
    val appPrefs: AppPreferences by viewModel.appPreferences.collectAsStateWithLifecycle()
    val profiles: List<ChatProfile> by viewModel.profiles.collectAsStateWithLifecycle()
    val providers: List<LlmProviderInfo> by viewModel.providers.collectAsStateWithLifecycle()
    val mcpServers: List<McpInfo> by viewModel.mcpServers.collectAsStateWithLifecycle()
    val speechServices: List<SpeechService> by viewModel.speechServices.collectAsStateWithLifecycle()

    val toolSettings by viewModel.toolSettings.collectAsStateWithLifecycle()

    val activeProfile: ChatProfile? = appPrefs.selectedProfileId?.let { id -> profiles.find { it.id == id } }

    CompositionLocalProvider(LocalToolControls provides ToolControls(mcpServers, activeProfile, toolSettings, viewModel::setSystemTool, viewModel::setQuickMcp)) {
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
                    currentScreen = Screen.CHAT
                },
                onNewChat = {
                    viewModel.startNewChat()
                    currentScreen = Screen.CHAT
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
                    currentScreen = Screen.PROFILES
                },
                onCloseDrawer = {
                    coroutineScope.launch { drawerState.close() }
                }
            )
        }
    ) {
        Box(modifier = Modifier.fillMaxSize()) {
            when (currentScreen) {
                Screen.CHAT -> {
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
                        onSaveModelConfig = viewModel::saveModelConfiguration,
                        onSelectModel = { provId, modelId ->
                            viewModel.selectModel(provId, modelId)
                        },
                        onReadMessage = { text ->
                            viewModel.speakText(text)
                        },
                        onFetchOllamaModels = { url ->
                            viewModel.fetchOllamaModels(url)
                        }
                    )
                }

                Screen.PROFILES -> {
                    ProfileScreen(
                        profiles = profiles,
                        mcpServers = mcpServers,
                        discoverTools = { viewModel.mcpService.discover(it) },
                        selectedProfileId = appPrefs.selectedProfileId,
                        onSelectProfile = { viewModel.selectProfile(it) },
                        onSaveProfile = { viewModel.saveProfile(it) },
                        onDeleteProfile = { viewModel.deleteProfile(it) },
                        onBack = { currentScreen = Screen.CHAT }
                    )
                }

                Screen.PROVIDERS -> {
                    ProviderScreen(
                        providers = providers,
                        onSaveProvider = { viewModel.saveProvider(it) },
                        onDeleteProvider = { viewModel.deleteProvider(it) },
                        onTestConnection = { prov -> viewModel.testConnection(prov) },
                        onFetchModels = { provider -> viewModel.fetchProviderModels(provider) },
                        onBack = { currentScreen = Screen.CHAT }
                    )
                }

                Screen.MCP -> {
                    McpScreen(
                        mcpServers = mcpServers,
                        onSaveMcpServer = { viewModel.saveMcpServer(it) },
                        onDeleteMcpServer = { viewModel.deleteMcpServer(it) },
                        onBack = { currentScreen = Screen.CHAT }
                    )
                }

                Screen.SPEECH -> {
                    SpeechScreen(
                        speechServices = speechServices,
                        onSaveService = { viewModel.saveSpeechService(it) },
                        onDeleteService = { viewModel.deleteSpeechService(it) },
                        onTestVoice = { text, speed, pitch ->
                            viewModel.ttsHelper.speak(text, speed, pitch)
                        },
                        onBack = { currentScreen = Screen.CHAT }
                    )
                }

                Screen.SYSTEM_TOOLS -> SystemToolsScreen(providers, toolSettings, viewModel::setSystemTool) { currentScreen = Screen.CHAT }
                Screen.STORAGE -> StorageScreen(viewModel.toolFiles) { currentScreen = Screen.CHAT }
                Screen.SETTINGS -> {
                    SettingsScreen(
                        appPreferences = appPrefs,
                        conversationCount = conversations.size,
                        profileCount = profiles.size,
                        providerCount = providers.size,
                        onThemeChange = { mode ->
                            coroutineScope.launch { viewModel.prefsRepo.setThemeMode(mode) }
                        },
                        onDynamicColorChange = { use ->
                            coroutineScope.launch { viewModel.prefsRepo.setUseDynamicColor(use) }
                        },
                        onColorSchemeChange = { scheme ->
                            coroutineScope.launch { viewModel.prefsRepo.setColorSchemeName(scheme) }
                        },
                        onContinueLastConversationChange = { value ->
                            coroutineScope.launch { viewModel.prefsRepo.setContinueLastConversation(value) }
                        },
                        onPersistChatSelectionChange = { value ->
                            coroutineScope.launch { viewModel.prefsRepo.setPersistChatSelection(value) }
                        },
                        onEnableVibrationChange = { value ->
                            coroutineScope.launch { viewModel.prefsRepo.setEnableVibration(value) }
                        },
                        onHideStatusBarChange = { value ->
                            coroutineScope.launch { viewModel.prefsRepo.setHideStatusBar(value) }
                        },
                        onDebugModeChange = { value ->
                            coroutineScope.launch { viewModel.prefsRepo.setDebugMode(value) }
                        },
                        onClearAllConversations = {
                            viewModel.clearAllConversations()
                        },
                        onResetAllData = {
                            viewModel.deleteAllUserData()
                        },
                        onBack = { currentScreen = Screen.CHAT }
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
                            currentScreen = Screen.PROFILES
                            showEndMenuSheet = false
                        },
                        onEditProfile = {
                            currentScreen = Screen.PROFILES
                            showEndMenuSheet = false
                        },
                        onNavigateToProviders = {
                            currentScreen = Screen.PROVIDERS
                            showEndMenuSheet = false
                        },
                        onNavigateToMcp = {
                            currentScreen = Screen.MCP
                            showEndMenuSheet = false
                        },
                        onNavigateToSpeech = {
                            currentScreen = Screen.SPEECH
                            showEndMenuSheet = false
                        },
                        onNavigateToSystemTools = { currentScreen = Screen.SYSTEM_TOOLS; showEndMenuSheet = false },
                        onNavigateToStorage = { currentScreen = Screen.STORAGE; showEndMenuSheet = false },
                        onNavigateToSettings = {
                            currentScreen = Screen.SETTINGS
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
}
