package org.starfall.multigateway.data.model

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

enum class ChatRole {
    @SerialName("user") USER,
    @SerialName("model") MODEL,
    @SerialName("system") SYSTEM
}

@Serializable
data class MessageVersion(
    val content: String = "",
    val timestamp: String = "",
    val files: List<String> = emptyList(),
    val toolActivity: List<ToolActivity> = emptyList(),
    @SerialName("reasoning_content") val reasoningContent: String? = null
)

@Serializable
data class StoredMessage(
    val id: String,
    val role: ChatRole,
    val versions: List<MessageVersion> = emptyList(),
    @SerialName("active_version_index") val activeVersionIndex: Int = 0
) {
    val activeVersion: MessageVersion
        get() {
            if (versions.isEmpty()) return MessageVersion()
            val idx = activeVersionIndex.coerceIn(0, versions.size - 1)
            return versions[idx]
        }

    val content: String
        get() = activeVersion.content

    val files: List<String>
        get() = activeVersion.files

    val reasoningContent: String?
        get() = activeVersion.reasoningContent
}

@Serializable
data class Conversation(
    val id: String,
    val title: String,
    @SerialName("created_at") val createdAt: Long,
    @SerialName("updated_at") val updatedAt: Long,
    val messages: List<StoredMessage> = emptyList(),
    @SerialName("token_count") val tokenCount: Int? = null,
    @SerialName("provider_id") val providerId: String = "",
    @SerialName("model_id") val modelId: String = "",
    @SerialName("profile_id") val profileId: String? = null
)
