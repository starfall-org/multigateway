package org.starfall.multigateway.data.model

import kotlinx.serialization.Serializable
import kotlinx.serialization.json.JsonObject

@Serializable
data class McpAccess(val enabled: Boolean = false, val tools: Map<String, Boolean> = emptyMap())
@Serializable
data class SystemToolConfig(
    val enabled: Boolean = false,
    val providerId: String = "",
    val modelId: String = "",
    val imageOptionsByModel: Map<String, JsonObject> = emptyMap()
) {
    val imageOptions: JsonObject get() = imageOptionsByModel["$providerId/$modelId"] ?: JsonObject(emptyMap())
    fun withImageOptions(options: JsonObject) = copy(imageOptionsByModel = imageOptionsByModel + ("$providerId/$modelId" to options))
}
@Serializable
data class ToolSettings(val system: Map<String, SystemToolConfig> = emptyMap(), val quickMcp: Map<String, Boolean> = emptyMap())
@Serializable
data class ToolActivity(val id: String, val name: String, val status: String = "running", val summary: String = "", val files: List<String> = emptyList())
data class ToolDefinition(val name: String, val description: String, val schema: JsonObject, val serverId: String? = null, val originalName: String = name)
sealed interface GenerationEvent {
    data class Text(val text: String): GenerationEvent
    data class Tool(val activity: ToolActivity): GenerationEvent
}
fun toolAllowed(access: McpAccess?, quick: Boolean?, name: String): Boolean =
    access?.enabled == true && quick != false && access.tools[name] != false
