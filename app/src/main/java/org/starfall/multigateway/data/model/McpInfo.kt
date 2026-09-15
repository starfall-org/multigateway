package org.starfall.multigateway.data.model

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

enum class McpProtocol {
    @SerialName("streamable_http") STREAMABLE_HTTP,
    @SerialName("sse") SSE
}

@Serializable
data class McpInfo(
    val id: String,
    val name: String,
    val protocol: McpProtocol = McpProtocol.SSE,
    val url: String? = null,
    val headers: Map<String, String>? = null
)
