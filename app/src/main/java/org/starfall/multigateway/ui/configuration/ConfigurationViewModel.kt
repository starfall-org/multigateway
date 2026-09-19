package org.starfall.multigateway.ui.configuration

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import kotlinx.coroutines.flow.*
import kotlinx.coroutines.launch
import org.starfall.multigateway.data.local.preferences.AppPreferencesRepository
import org.starfall.multigateway.data.local.preferences.AppPreferences
import org.starfall.multigateway.data.model.*
import org.starfall.multigateway.data.repository.*

class ConfigurationViewModel(
    private val profileRepo: ProfileRepository,
    private val llmRepo: LlmRepository,
    private val mcpRepo: McpRepository,
    private val speechRepo: SpeechRepository,
    private val prefsRepo: AppPreferencesRepository,
) : ViewModel() {
    private val appPreferences = prefsRepo.appPreferencesFlow
        .stateIn(viewModelScope, SharingStarted.Eagerly, AppPreferences())
    val speechServices = speechRepo.allServices
        .stateIn(viewModelScope, SharingStarted.WhileSubscribed(5_000), emptyList())
    suspend fun discoverTools(server: McpInfo) = mcpRepo.discoverTools(server)

    fun saveProfile(profile: ChatProfile) {
        viewModelScope.launch {
            profileRepo.saveProfile(profile)
        }
    }

    fun deleteProfile(profileId: String) {
        viewModelScope.launch {
            profileRepo.deleteProfile(profileId)
            if (appPreferences.value.selectedProfileId == profileId) {
                prefsRepo.setSelectedProfileId(null)
            }
        }
    }

    fun saveModelConfiguration(providerId: String, modelId: String, config: ModelConfiguration) {
        viewModelScope.launch {
            val provider = llmRepo.getProviderById(providerId) ?: return@launch
            llmRepo.saveProvider(provider.copy(config = provider.config.copy(
                modelConfigs = provider.config.modelConfigs + (modelId to config)
            )))
        }
    }

    fun saveProviderModels(providerId: String, modelConfigs: Map<String, ModelConfiguration>) {
        viewModelScope.launch {
            val provider = llmRepo.getProviderById(providerId) ?: return@launch
            val modelIds = modelConfigs.keys.toList()
            llmRepo.saveProvider(provider.copy(config = provider.config.copy(
                modelConfigs = modelConfigs,
                modelIds = modelIds
            )))
            val prefs = appPreferences.value
            if (prefs.selectedProviderId == providerId && prefs.selectedModelId !in modelIds) {
                prefsRepo.setSelectedModel(providerId, modelIds.firstOrNull().orEmpty())
            }
        }
    }

    fun saveProvider(provider: LlmProviderInfo) {
        viewModelScope.launch {
            llmRepo.saveProvider(provider)
            val prefs = appPreferences.value
            val modelIds = provider.config.modelIds
            if (prefs.selectedProviderId == provider.id && modelIds != null && prefs.selectedModelId !in modelIds) {
                prefsRepo.setSelectedModel(provider.id, modelIds.firstOrNull().orEmpty())
            }
        }
    }

    fun deleteProvider(providerId: String) {
        viewModelScope.launch {
            llmRepo.deleteProvider(providerId)
        }
    }

    suspend fun testConnection(provider: LlmProviderInfo, modelId: String): Result<String> {
        return llmRepo.testModel(provider, modelId)
    }

    suspend fun fetchProviderModels(provider: LlmProviderInfo): List<String> =
        llmRepo.fetchProviderModels(provider)

    suspend fun fetchOllamaModels(baseUrl: String): List<String> {
        return llmRepo.fetchOllamaModels(baseUrl)
    }

    fun saveMcpServer(server: McpInfo) {
        viewModelScope.launch {
            mcpRepo.saveServer(server)
        }
    }

    fun deleteMcpServer(serverId: String) {
        viewModelScope.launch {
            mcpRepo.deleteServer(serverId)
        }
    }

    fun saveSpeechService(service: SpeechService) {
        viewModelScope.launch {
            speechRepo.saveService(service)
        }
    }

    fun deleteSpeechService(serviceId: String) {
        viewModelScope.launch {
            speechRepo.deleteService(serviceId)
        }
    }

}
