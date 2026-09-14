package org.starfall.multigateway.data.service

import kotlinx.coroutines.*
import kotlinx.coroutines.channels.Channel
import kotlinx.serialization.json.*
import okhttp3.*
import okhttp3.MediaType.Companion.toMediaType
import okhttp3.RequestBody.Companion.toRequestBody
import org.starfall.multigateway.data.model.*
import org.starfall.multigateway.data.tools.*
import java.io.BufferedReader
import java.io.StringReader
import java.util.UUID

class McpService(private val http: ToolHttp = ToolHttp()) {
    suspend fun listTools(info: McpInfo): List<String> = discover(info).map { it.originalName }
    suspend fun discover(info: McpInfo): List<ToolDefinition> = session(info).useSession { it.tools() }
    suspend fun session(info: McpInfo): McpSession {
        require(info.protocol != McpProtocol.STDIO) { "STDIO requires a local process and is not supported on Android. Use HTTP or SSE." }
        val session = McpSession(info, http)
        try { session.initialize(); return session } catch (e: Throwable) { session.close(); throw e }
    }
}
suspend fun <T> McpSession.useSession(block: suspend (McpSession) -> T): T = try { block(this) } finally { close() }

class McpSession(private val info: McpInfo, private val http: ToolHttp) {
    private val endpoint = info.url?.takeIf { it.isNotBlank() } ?: error("MCP URL is missing")
    private var postEndpoint = endpoint
    private var sessionId: String? = null
    private var version: String? = null
    private var legacy = false
    private var stream: Response? = null
    private val scope = CoroutineScope(SupervisorJob() + Dispatchers.IO)
    private val messages = Channel<JsonObject>(32)
    private fun request(url: String) = Request.Builder().url(url).apply {
        info.headers?.forEach { (k,v) -> header(k,v) }
        header("Accept", "application/json, text/event-stream")
        sessionId?.let { header("Mcp-Session-Id", it) }
        version?.let { header("MCP-Protocol-Version", it) }
    }
    suspend fun initialize() {
        if (info.protocol == McpProtocol.SSE) startLegacy()
        val result = rpc("initialize", obj(
            "protocolVersion" to str("2025-06-18"),
            "capabilities" to obj(),
            "clientInfo" to obj("name" to str("MultiGateway"), "version" to str("1.0"))
        ))
        version = result.text("protocolVersion")
        check(version in listOf("2024-11-05", "2025-03-26", "2025-06-18", "2025-11-25")) { "Unsupported MCP protocol: $version" }
        notify("notifications/initialized", obj())
    }
    private suspend fun startLegacy() {
        legacy = true
        val ready = CompletableDeferred<String>()
        scope.launch {
            try {
                val response = http.execute(request(endpoint).header("Accept", "text/event-stream").get().build())
                stream = response
                check(response.isSuccessful) { "MCP SSE HTTP ${response.code}" }
                response.body!!.charStream().buffered().use { reader ->
                    events(reader) { event, data ->
                        if (event == "endpoint") {
                            val original = response.request.url
                            val target = original.resolve(data) ?: error("Invalid MCP endpoint")
                            check(target.host == original.host && target.port == original.port && target.scheme == original.scheme) { "MCP endpoint must have the same origin" }
                            ready.complete(target.toString())
                        } else if (data.startsWith("{")) messages.send(parse(data))
                    }
                }
                error("MCP SSE connection closed")
            } catch (e: Throwable) { ready.completeExceptionally(e); messages.close(e) }
        }
        postEndpoint = withTimeout(30000) { ready.await() }
    }
    suspend fun tools(): List<ToolDefinition> {
        val result = mutableListOf<ToolDefinition>()
        var cursor = ""
        val seen = mutableSetOf<String>()
        do {
            val page = rpc("tools/list", if(cursor.isEmpty()) obj() else obj("cursor" to str(cursor)))
            (page["tools"] as? JsonArray).orEmpty().forEach { entry ->
                val tool = entry.jsonObject
                result += ToolDefinition("mcp_" + UUID.nameUUIDFromBytes((info.id + ":" + tool.text("name")).toByteArray()).toString().replace("-", ""),
                    tool.text("description").take(4000), tool["inputSchema"] as? JsonObject ?: obj("type" to str("object")), info.id, tool.text("name"))
                check(result.size <= 256) { "MCP has more than 256 tools" }
            }
            cursor = page.text("nextCursor")
            check(cursor.isEmpty() || seen.add(cursor)) { "MCP repeated a tools page" }
        } while(cursor.isNotEmpty())
        return result
    }
    suspend fun call(name: String, arguments: JsonObject): JsonObject = rpc("tools/call", obj("name" to str(name), "arguments" to arguments))
    private suspend fun notify(method: String, params: JsonObject) {
        val body = obj("jsonrpc" to str("2.0"), "method" to str(method), "params" to params)
        http.execute(request(postEndpoint).post(body.toString().toRequestBody("application/json".toMediaType())).build()).use {
            check(it.isSuccessful) { "MCP notification failed: HTTP ${it.code}" }
        }
    }
    private suspend fun rpc(method: String, params: JsonObject): JsonObject = withTimeout(180000) {
        val id = UUID.randomUUID().toString()
        val body = obj("jsonrpc" to str("2.0"), "id" to str(id), "method" to str(method), "params" to params)
        try {
            val answer = withContext(Dispatchers.IO) {
                http.execute(request(postEndpoint).post(body.toString().toRequestBody("application/json".toMediaType())).build()).use { response ->
                    check(response.isSuccessful) { "MCP HTTP ${response.code}. Reconnect before retrying." }
                    response.header("Mcp-Session-Id")?.let { sessionId = it }
                    if (legacy) {
                        var message = messages.receive()
                        while (message.text("id") != id) message = messages.receive()
                        message
                    } else if (response.header("Content-Type").orEmpty().contains("text/event-stream")) {
                        var matched: JsonObject? = null
                        try {
                            events(response.body!!.charStream().buffered()) { _, data ->
                                if (data.startsWith("{")) {
                                    val message = parse(data)
                                    if (message.text("id") == id) { matched = message; throw EndEvent() }
                                }
                            }
                        } catch (_: EndEvent) { }
                        matched ?: error("MCP stream ended without a result")
                    } else {
                        val text = http.files?.sanitize(response.body!!.charStream()) ?: response.body!!.string().also { check(it.length < 2*1024*1024) }
                        Json.parseToJsonElement(text).jsonObject
                    }
                }
            }
            check(answer.text("id") == id) { "MCP response ID mismatch" }
            check(answer["error"] == null) { "MCP error: ${answer["error"].toString().take(500)}" }
            answer["result"] as? JsonObject ?: error("Missing MCP result")
        } catch (e: CancellationException) {
            withContext(NonCancellable) { withTimeoutOrNull(2000) { runCatching { notify("notifications/cancelled", obj("requestId" to str(id), "reason" to str("Cancelled by user"))) } } }
            throw e
        }
    }
    private suspend fun parse(data: String) = Json.parseToJsonElement(http.files?.sanitize(StringReader(data)) ?: data).jsonObject
    suspend fun close() {
        stream?.close(); scope.cancel(); messages.close()
        if (!legacy && sessionId != null) withContext(NonCancellable) {
            withTimeoutOrNull(2000) { runCatching { http.execute(request(endpoint).delete().build()).close() } }
        }
    }
    private class EndEvent: Exception()
    private suspend fun events(reader: BufferedReader, block: suspend (String,String) -> Unit) {
        var event = "message"
        val data = StringBuilder()
        while(true) {
            currentCoroutineContext().ensureActive()
            val line = StringBuilder()
            while(true) {
                val c = reader.read()
                if(c < 0) { if(data.isNotEmpty()) block(event,data.toString().trimEnd()); return }
                if(c == 10) break
                if(c != 13) line.append(c.toChar())
                check(line.length <= 2*1024*1024) { "MCP SSE event exceeds 2 MB; use a file URL for large output" }
            }
            when {
                line.isEmpty() -> { if(data.isNotEmpty()) block(event,data.toString().trimEnd()); data.setLength(0); event = "message" }
                line.startsWith("event:") -> event = line.substring(6).trim()
                line.startsWith("data:") -> { data.append(line.substring(5).trimStart()).append('\n'); check(data.length<=2*1024*1024) }
            }
        }
    }
}
