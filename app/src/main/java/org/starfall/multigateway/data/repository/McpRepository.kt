package org.starfall.multigateway.data.repository

import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.map
import kotlinx.serialization.encodeToString
import org.starfall.multigateway.data.local.db.AppDatabase
import org.starfall.multigateway.data.local.db.SecretCipher
import org.starfall.multigateway.data.local.db.entities.*
import org.starfall.multigateway.data.model.*
import org.starfall.multigateway.data.service.McpService

class McpRepository(private val db: AppDatabase, private val service: McpService) {
    suspend fun discoverTools(server: McpInfo) = service.discover(server)

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

