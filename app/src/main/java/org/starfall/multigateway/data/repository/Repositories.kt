package org.starfall.multigateway.data.repository

import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.map
import kotlinx.serialization.encodeToString
import kotlinx.serialization.json.Json
import org.starfall.multigateway.data.local.db.AppDatabase
import org.starfall.multigateway.data.local.db.SecretCipher
import org.starfall.multigateway.data.local.db.entities.*
import org.starfall.multigateway.data.model.*

private val json = Json {
    ignoreUnknownKeys = true
    encodeDefaults = true
}

class ConversationRepository(private val db: AppDatabase) {
    private val dao = db.conversationDao()

    val allConversations: Flow<List<Conversation>> = dao.getAllConversations().map { entities ->
        entities.map { entityToModel(it) }
    }

    suspend fun getById(id: String): Conversation? {
        val entity = dao.getConversationById(id) ?: return null
        return entityToModel(entity)
    }

    suspend fun saveConversation(conversation: Conversation) {
        dao.insertOrUpdate(modelToEntity(conversation))
    }

    suspend fun deleteConversation(id: String) {
        dao.deleteById(id)
    }

    suspend fun deleteAll() {
        dao.deleteAll()
    }

    private fun entityToModel(entity: ConversationEntity): Conversation {
        val messages: List<StoredMessage> = try {
            json.decodeFromString(entity.messagesJson)
        } catch (e: Exception) {
            emptyList()
        }
        return Conversation(
            id = entity.id,
            title = entity.title,
            createdAt = entity.createdAt,
            updatedAt = entity.updatedAt,
            messages = messages.map { message -> message.copy(versions = message.versions.map { version ->
                version.copy(toolActivity = version.toolActivity.map { activity ->
                    if(activity.status == "running") activity.copy(status = "interrupted", summary = "The previous run did not finish.") else activity
                })
            }) },
            tokenCount = entity.tokenCount,
            providerId = entity.providerId,
            modelId = entity.modelId,
            profileId = entity.profileId
        )
    }

    private fun modelToEntity(conversation: Conversation): ConversationEntity {
        return ConversationEntity(
            id = conversation.id,
            title = conversation.title,
            createdAt = conversation.createdAt,
            updatedAt = conversation.updatedAt,
            messagesJson = json.encodeToString(conversation.messages),
            tokenCount = conversation.tokenCount,
            providerId = conversation.providerId,
            modelId = conversation.modelId,
            profileId = conversation.profileId
        )
    }
}

class ProfileRepository(private val db: AppDatabase) {
    private val dao = db.chatProfileDao()

    val allProfiles: Flow<List<ChatProfile>> = dao.getAllProfiles().map { entities ->
        entities.map { entityToModel(it) }
    }

    suspend fun getById(id: String): ChatProfile? {
        val entity = dao.getProfileById(id) ?: return null
        return entityToModel(entity)
    }

    suspend fun saveProfile(profile: ChatProfile) {
        dao.insertOrUpdate(modelToEntity(profile))
    }

    suspend fun deleteProfile(id: String) {
        dao.deleteById(id)
    }

    private fun entityToModel(entity: ChatProfileEntity): ChatProfile {
        val config: LlmChatConfig = try {
            json.decodeFromString(entity.configJson)
        } catch (e: Exception) {
            LlmChatConfig()
        }
        return ChatProfile(
            id = entity.id,
            name = entity.name,
            icon = entity.icon,
            config = config
        )
    }

    private fun modelToEntity(profile: ChatProfile): ChatProfileEntity {
        return ChatProfileEntity(
            id = profile.id,
            name = profile.name,
            icon = profile.icon,
            configJson = json.encodeToString(profile.config),
            activeMcpJson = "[]",
            activeModelToolsJson = "[]"
        )
    }
}

class LlmRepository(private val db: AppDatabase) {
    private val providerDao = db.llmProviderDao()
    private val modelsDao = db.llmModelsDao()

    val allProviders: Flow<List<LlmProviderInfo>> = providerDao.getAllProviders().map { entities ->
        entities.map { providerEntityToModel(it) }
    }

    suspend fun getProviderById(id: String): LlmProviderInfo? {
        val entity = providerDao.getProviderById(id) ?: return null
        return providerEntityToModel(entity)
    }

    suspend fun saveProvider(provider: LlmProviderInfo) {
        providerDao.insertOrUpdate(providerModelToEntity(provider))
    }

    suspend fun deleteProvider(id: String) {
        providerDao.deleteById(id)
    }

    suspend fun getModelsForProvider(providerId: String): LlmProviderModels? {
        val entity = modelsDao.getModelsForProvider(providerId) ?: return null
        val models: List<LlmModel> = try {
            json.decodeFromString(entity.modelsJson)
        } catch (e: Exception) {
            emptyList()
        }
        return LlmProviderModels(id = entity.id, models = models)
    }

    suspend fun saveModelsForProvider(providerModels: LlmProviderModels) {
        modelsDao.insertOrUpdate(
            LlmModelsEntity(
                id = providerModels.id,
                modelsJson = json.encodeToString(providerModels.models)
            )
        )
    }

    private fun providerEntityToModel(entity: LlmProviderEntity): LlmProviderInfo {
        val type = try {
            ProviderType.valueOf(entity.type)
        } catch (e: Exception) {
            ProviderType.OPENAI
        }
        val authJson = SecretCipher.decrypt(entity.authJson)
        val configJson = SecretCipher.decrypt(entity.configJson)
        val auth: Authorization = try {
            json.decodeFromString(authJson)
        } catch (e: Exception) {
            Authorization()
        }
        val config: ProviderConfiguration = try {
            json.decodeFromString(configJson)
        } catch (e: Exception) {
            ProviderConfiguration()
        }
        return LlmProviderInfo(
            id = entity.id,
            name = entity.name,
            type = type,
            auth = auth,
            icon = entity.icon,
            baseUrl = SecretCipher.decrypt(entity.baseUrl),
            config = config
        )
    }

    private fun providerModelToEntity(provider: LlmProviderInfo): LlmProviderEntity {
        return LlmProviderEntity(
            id = provider.id,
            name = provider.name,
            type = provider.type.name,
            baseUrl = SecretCipher.encrypt(provider.baseUrl),
            authJson = SecretCipher.encrypt(json.encodeToString(provider.auth)),
            configJson = SecretCipher.encrypt(json.encodeToString(provider.config)),
            icon = provider.icon
        )
    }
}

class McpRepository(private val db: AppDatabase) {
    private val dao = db.mcpServerDao()

    val allServers: Flow<List<McpInfo>> = dao.getAllServers().map { entities ->
        entities.map { entityToModel(it) }
    }

    suspend fun getById(id: String): McpInfo? {
        val entity = dao.getServerById(id) ?: return null
        return entityToModel(entity)
    }

    suspend fun saveServer(server: McpInfo) {
        dao.insertOrUpdate(modelToEntity(server))
    }

    suspend fun deleteServer(id: String) {
        dao.deleteById(id)
    }

    private fun entityToModel(entity: McpServerEntity): McpInfo {
        val savedProtocol = runCatching { McpProtocol.valueOf(entity.protocol) }.getOrNull()
        val protocol = savedProtocol ?: McpProtocol.STREAMABLE_HTTP
        val headers: Map<String, String>? = entity.headersJson?.let(SecretCipher::decrypt)?.let {
            try {
                json.decodeFromString(it)
            } catch (e: Exception) {
                null
            }
        }
        return McpInfo(
            id = entity.id,
            name = entity.name,
            protocol = protocol,
            // Preserve obsolete server records for editing, but never treat a saved command as a URL.
            url = entity.url?.let(SecretCipher::decrypt).takeIf { savedProtocol != null },
            headers = headers
        )
    }

    private fun modelToEntity(server: McpInfo): McpServerEntity {
        return McpServerEntity(
            id = server.id,
            name = server.name,
            protocol = server.protocol.name,
            url = server.url?.let(SecretCipher::encrypt),
            headersJson = server.headers?.let { SecretCipher.encrypt(json.encodeToString(it)) }
        )
    }
}

class SpeechRepository(private val db: AppDatabase) {
    private val dao = db.speechServiceDao()

    val allServices: Flow<List<SpeechService>> = dao.getAllSpeechServices().map { entities ->
        entities.map { entityToModel(it) }
    }

    suspend fun getById(id: String): SpeechService? {
        val entity = dao.getServiceById(id) ?: return null
        return entityToModel(entity)
    }

    suspend fun saveService(service: SpeechService) {
        dao.insertOrUpdate(modelToEntity(service))
    }

    suspend fun deleteService(id: String) {
        dao.deleteById(id)
    }

    private fun entityToModel(entity: SpeechServiceEntity): SpeechService {
        return SpeechService(
            id = entity.id,
            name = entity.name,
            provider = entity.provider,
            voice = entity.voice,
            speed = entity.speed,
            pitch = entity.pitch,
            apiKey = SecretCipher.decrypt(entity.apiKey)
        )
    }

    private fun modelToEntity(service: SpeechService): SpeechServiceEntity {
        return SpeechServiceEntity(
            id = service.id,
            name = service.name,
            provider = service.provider,
            voice = service.voice,
            speed = service.speed,
            pitch = service.pitch,
            apiKey = SecretCipher.encrypt(service.apiKey)
        )
    }
}
