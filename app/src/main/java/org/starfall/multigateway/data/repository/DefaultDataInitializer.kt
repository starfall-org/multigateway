package org.starfall.multigateway.data.repository

import kotlinx.coroutines.flow.first
import org.starfall.multigateway.data.local.preferences.AppPreferencesRepository
import org.starfall.multigateway.data.model.*

/** Runs once per application process; existing records retain their persisted format. */
class DefaultDataInitializer(
    private val llmRepo: LlmRepository,
    private val profileRepo: ProfileRepository,
    private val speechRepo: SpeechRepository,
    private val prefsRepo: AppPreferencesRepository,
) {
    suspend fun initialize() {
        llmRepo.allProviders.first().let { currentProviders ->
            if (currentProviders.isEmpty()) {
                initDefaultProviders()
            } else {
                val existingOllama = currentProviders.find { it.type == ProviderType.OLLAMA }
                if (existingOllama != null && (
                        existingOllama.baseUrl.contains("108.181.196.208") ||
                        existingOllama.baseUrl.contains("10.0.2.2") ||
                        existingOllama.baseUrl.contains("localhost")
                    )) {
                    llmRepo.saveProvider(
                        existingOllama.copy(
                            name = "Ollama",
                            baseUrl = "https://ollama.com/api"
                        )
                    )
                }
            }
        }

        profileRepo.allProfiles.first().let { currentProfiles ->
            if (currentProfiles.isEmpty()) {
                initDefaultProfiles()
            }
        }

        speechRepo.allServices.first().let { currentServices ->
            if (currentServices.isEmpty()) {
                initDefaultSpeechServices()
            }
        }
    }

    private suspend fun initDefaultProviders() {
        val openAi = LlmProviderInfo(
            id = "openai",
            name = "OpenAI",
            type = ProviderType.OPENAI,
            baseUrl = "https://api.openai.com/v1",
            auth = Authorization(method = AuthMethod.BEARER_TOKEN, key = "")
        )
        val google = LlmProviderInfo(
            id = "google",
            name = "Google Gemini",
            type = ProviderType.GOOGLE,
            baseUrl = "https://generativelanguage.googleapis.com/v1beta",
            auth = Authorization(method = AuthMethod.QUERY_PARAM, key = "")
        )
        val anthropic = LlmProviderInfo(
            id = "anthropic",
            name = "Anthropic",
            type = ProviderType.ANTHROPIC,
            baseUrl = "https://api.anthropic.com/v1",
            auth = Authorization(method = AuthMethod.CUSTOM_HEADER, key = "")
        )
        val ollama = LlmProviderInfo(
            id = "ollama",
            name = "Ollama",
            type = ProviderType.OLLAMA,
            baseUrl = "https://ollama.com/api",
            auth = Authorization(method = AuthMethod.OTHER, key = "")
        )

        llmRepo.saveProvider(openAi)
        llmRepo.saveProvider(google)
        llmRepo.saveProvider(anthropic)
        llmRepo.saveProvider(ollama)

        prefsRepo.setSelectedModel("ollama", "llama3.2:latest")
    }

    private suspend fun initDefaultProfiles() {
        val general = ChatProfile(
            id = "profile_general",
            name = "General Assistant",
            config = LlmChatConfig(
                systemPrompt = "You are a helpful, capable, and thoughtful AI assistant. Respond clearly and accurately."
            )
        )
        val coding = ChatProfile(
            id = "profile_coding",
            name = "Code Architect",
            config = LlmChatConfig(
                systemPrompt = "You are an expert software engineer and system architect. Provide clean, modular, and idiomatic code with explanations."
            )
        )
        val writer = ChatProfile(
            id = "profile_creative",
            name = "Creative Writer",
            config = LlmChatConfig(
                systemPrompt = "You are an imaginative creative writer, editor, and storyteller. Help users craft engaging stories, prose, and content."
            )
        )

        profileRepo.saveProfile(general)
        profileRepo.saveProfile(coding)
        profileRepo.saveProfile(writer)

        prefsRepo.setSelectedProfileId("profile_general")
    }

    private suspend fun initDefaultSpeechServices() {
        val systemTts = SpeechService(
            id = "system_tts",
            name = "Android System TTS",
            provider = "system",
            voice = "Default",
            speed = 1.0f,
            pitch = 1.0f
        )
        speechRepo.saveService(systemTts)
    }

}
