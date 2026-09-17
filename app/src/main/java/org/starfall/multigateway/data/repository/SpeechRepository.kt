package org.starfall.multigateway.data.repository

import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.map
import kotlinx.serialization.encodeToString
import org.starfall.multigateway.data.local.db.AppDatabase
import org.starfall.multigateway.data.local.db.SecretCipher
import org.starfall.multigateway.data.local.db.entities.*
import org.starfall.multigateway.data.model.*

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
