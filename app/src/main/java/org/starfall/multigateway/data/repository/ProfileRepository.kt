package org.starfall.multigateway.data.repository

import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.map
import kotlinx.serialization.encodeToString
import org.starfall.multigateway.data.local.db.AppDatabase
import org.starfall.multigateway.data.local.db.SecretCipher
import org.starfall.multigateway.data.local.db.entities.*
import org.starfall.multigateway.data.model.*

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

    suspend fun reorderProfiles(ids: List<String>) {
        ids.forEachIndexed { index, id -> dao.updateSortOrder(id, index) }
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
            config = config,
            sortOrder = entity.sortOrder
        )
    }

    private fun modelToEntity(profile: ChatProfile): ChatProfileEntity {
        return ChatProfileEntity(
            id = profile.id,
            name = profile.name,
            icon = profile.icon,
            configJson = json.encodeToString(profile.config),
            activeMcpJson = "[]",
            activeModelToolsJson = "[]",
            sortOrder = profile.sortOrder
        )
    }
}

