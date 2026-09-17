package org.starfall.multigateway.data.tools

import kotlinx.coroutines.*
import kotlinx.coroutines.flow.*
import kotlinx.serialization.json.*
import org.starfall.multigateway.data.model.*
import org.starfall.multigateway.data.service.*
import java.util.UUID

/** Native structured tool calls, bounded rounds, no executable text extracted from answers. */
class ToolChat(private val http: ToolHttp, private val mcp: McpService, private val llm: LlmService) {
    fun generate(provider: LlmProviderInfo, model: String, messages: List<StoredMessage>, prompt: String,
                 servers: List<McpInfo>, providers: List<LlmProviderInfo>,
                 access: () -> Map<String,McpAccess>, settings: () -> ToolSettings): Flow<GenerationEvent> = channelFlow {
        if(provider.config.modelConfigs[model]?.supportsToolCalls != true) {
            llm.streamContent(provider,model,messages,prompt).collect { send(GenerationEvent.Text(it)) }; return@channelFlow
        }
        val sessions = mutableMapOf<String,McpSession>()
        val tools = mutableListOf<ToolDefinition>()
        try {
            servers.filter { access()[it.id]?.enabled == true && settings().quickMcp[it.id] != false }.forEach { server ->
                val activity = ToolActivity(UUID.randomUUID().toString(), "${server.name}: connect")
                send(GenerationEvent.Tool(activity))
                try {
                    val session = mcp.session(server); sessions[server.id] = session
                    tools += session.tools().filter { toolAllowed(access()[server.id],settings().quickMcp[server.id],it.originalName) }
                    send(GenerationEvent.Tool(activity.copy(status="success",summary="Tools ready")))
                } catch(e: CancellationException) { send(GenerationEvent.Tool(activity.copy(status="cancelled"))); throw e }
                catch(e: Exception) { send(GenerationEvent.Tool(activity.copy(status="error",summary=e.message.orEmpty().take(500)))) }
            }
            listOf("generate_image","generate_video").forEach { name ->
                if(settings().system[name]?.enabled == true) tools += ToolDefinition(name,
                    if(name == "generate_image") "Generate an image from a detailed prompt. The app displays the saved image." else "Generate a video from a detailed prompt. The app displays the saved video.",
                    obj("type" to str("object"),"properties" to obj("prompt" to obj("type" to str("string"))),"required" to JsonArray(listOf(str("prompt")))))
            }
            if(tools.isEmpty()) { llm.streamContent(provider,model,messages,prompt).collect { send(GenerationEvent.Text(it)) }; return@channelFlow }
            http.requireFiles()
            val history = mutableListOf<JsonObject>()
            if(provider.type != ProviderType.GOOGLE && prompt.isNotBlank()) history += obj("role" to str("system"),"content" to str(prompt))
            messages.forEach { message ->
                val text = message.content + message.activeVersion.toolActivity.filter { it.status != "running" }.joinToString("\n",prefix="\n") { "Tool ${it.name}: ${it.status}. ${it.summary.take(2000)}" }
                history += obj("role" to str(if(message.role == ChatRole.MODEL) "assistant" else "user"),"content" to str(text))
            }
            val budget = ToolBudget()
            repeat(12) {
                currentCoroutineContext().ensureActive()
                val allowed = tools.filter { t -> if(t.serverId == null) settings().system[t.name]?.enabled == true else toolAllowed(access()[t.serverId],settings().quickMcp[t.serverId],t.originalName) }
                val turn = request(provider,model,history,allowed,prompt) { send(GenerationEvent.Text(it)) }
                val content = turn.text("content")
                if(content.isNotBlank() && !provider.streamEnabledFor(model)) send(GenerationEvent.Text(content))
                val calls = turn["tool_calls"] as? JsonArray ?: JsonArray(emptyList())
                if(calls.isEmpty()) return@channelFlow
                check(calls.size <= 16) { "Too many tool calls in a single response" }
                history += turn
                calls.forEach { value ->
                    val call = value.jsonObject
                    val function = call.requireObject("function")
                    val name = function.text("name")
                    val tool = allowed.find { it.name == name }
                    val activity = ToolActivity(UUID.randomUUID().toString(),tool?.let { t -> servers.find { it.id == t.serverId }?.let { "${it.name} / ${t.originalName}" } ?: t.originalName } ?: name)
                    send(GenerationEvent.Tool(activity))
                    var result: JsonObject
                    try {
                        require(tool != null) { "Tool is not enabled" }
                        budget.consume(if (tool.serverId == null) name else null)
                        val args = toolArguments(function["arguments"])
                        if(tool.serverId != null) {
                            check(toolAllowed(access()[tool.serverId],settings().quickMcp[tool.serverId],tool.originalName)) { "MCP tool disabled" }
                            result = (sessions[tool.serverId] ?: error("MCP session unavailable")).call(tool.originalName,args)
                        } else {
                            val cfg = settings().system[name] ?: error("System tool is not configured")
                            check(cfg.enabled) { "System tool disabled" }
                            val mediaProvider = providers.find { it.id == cfg.providerId } ?: error("Select a provider for this system tool")
                            val kind = if(name == "generate_image") ModelType.IMAGE_GENERATION else ModelType.VIDEO_GENERATION
                            check(mediaProvider.config.modelConfigs[cfg.modelId]?.modelType == kind && mediaProvider.config.modelIds?.contains(cfg.modelId) != false) { "Select an available media model in System tools" }
                            result = SystemMediaTools(http).generate(name,mediaProvider,cfg.modelId,args.text("prompt"),cfg.imageOptions)
                        }
                        val isError = (result["isError"] as? JsonPrimitive)?.booleanOrNull == true
                        val summary = summarizeToolResult(result, http.requireFiles())
                        result = summary.content
                        send(GenerationEvent.Tool(activity.copy(status=if(isError) "error" else "success",summary=summary.preview,files=summary.files)))
                    } catch(e: CancellationException) { send(GenerationEvent.Tool(activity.copy(status="cancelled",summary="Stopped"))); throw e }
                    catch(e: Exception) {
                        result = obj("error" to str(e.message.orEmpty().take(500)))
                        send(GenerationEvent.Tool(activity.copy(status="error",summary=e.message.orEmpty().take(500))))
                    }
                    history += obj("role" to str("tool"),"tool_call_id" to str(call.text("id")),"name" to str(name),"content" to str(result.toString()))
                }
            }
            error("Stopped after 12 tool rounds. Send another message to continue.")
        } finally { sessions.values.forEach { it.close() } }
    }.flowOn(Dispatchers.IO)

    private suspend fun request(p: LlmProviderInfo, model: String, history: List<JsonObject>, tools: List<ToolDefinition>, prompt: String, onText: suspend (String) -> Unit): JsonObject {
        val defs = JsonArray(tools.map { obj("type" to str("function"),"function" to obj("name" to str(it.name),"description" to str(it.description),"parameters" to it.schema)) })
        val base = providerBase(p)
        val config = p.config.modelConfigs[model] ?: ModelConfiguration()
        return when(p.type) {
            ProviderType.OPENAI_RESPONSES -> {
                val input = history.flatMap { message ->
                    when {
                        message["responsesOutput"] is JsonArray -> message.requireArray("responsesOutput").toList()
                        message.text("role") == "tool" -> listOf(obj(
                            "type" to str("function_call_output"), "call_id" to str(message.text("tool_call_id")),
                            "output" to str(message.text("content"))
                        ))
                        else -> listOf(message)
                    }
                }
                val response = http.modelResponse("$base/responses", buildJsonObject {
                    put("model", model); put("input", JsonArray(input)); put("store", false)
                    put("include", JsonArray(listOf(str("reasoning.encrypted_content"))))
                    put("max_output_tokens", p.config.maxTokens)
                    config.temperature?.let { put("temperature", it) }
                    config.topP?.let { put("top_p", it) }
                    if (tools.isNotEmpty()) put("tools", JsonArray(tools.map {
                        obj("type" to str("function"), "name" to str(it.name), "description" to str(it.description),
                            "parameters" to it.schema, "strict" to JsonPrimitive(false))
                    }))
                }, p, p.streamEnabledFor(model), onText)
                providerTurn(p.type, response)
            }
            ProviderType.OPENAI, ProviderType.OLLAMA -> {
                val ollama = p.type == ProviderType.OLLAMA
                val request = buildJsonObject {
                    put("model",model); put("messages",JsonArray(if(!ollama) history else history.map { message ->
                        when(message.text("role")) {
                            "tool" -> JsonObject(message + ("tool_name" to str(message.text("name"))))
                            "assistant" -> JsonObject(message + ("tool_calls" to JsonArray((message["tool_calls"] as? JsonArray).orEmpty().map { c ->
                                val call=c.jsonObject;val f=call.requireObject("function")
                                obj("function" to JsonObject(f+("arguments" to (f["arguments"] as? JsonObject ?: Json.parseToJsonElement(f.text("arguments"))))))
                            })))
                            else -> message
                        }
                    })); put("stream",false)
                    if(tools.isNotEmpty()) put("tools",defs)
                    if(ollama) put("options",buildJsonObject { config.temperature?.let { put("temperature",it) }; config.topP?.let { put("top_p",it) }; config.topK?.let { put("top_k",it) }; put("num_predict",p.config.maxTokens) })
                    else { put("max_tokens",p.config.maxTokens); config.temperature?.let { put("temperature",it) }; config.topP?.let { put("top_p",it) } }
                }
                val response = http.modelResponse(if(ollama) base.removeSuffix("/api")+"/api/chat" else "$base/chat/completions",request,p,p.streamEnabledFor(model),onText)
                providerTurn(p.type, response)
            }
            ProviderType.ANTHROPIC -> {
                val native = mutableListOf<JsonObject>()
                history.filter { it.text("role") != "system" }.forEach { message ->
                    val role = message.text("role")
                    val blocks = mutableListOf<JsonElement>()
                    if(role == "tool") blocks += obj("type" to str("tool_result"),"tool_use_id" to str(message.text("tool_call_id")),"content" to str(message.text("content")))
                    else {
                        if(message.text("content").isNotEmpty()) blocks += obj("type" to str("text"),"text" to str(message.text("content")))
                        (message["tool_calls"] as? JsonArray).orEmpty().forEach { c -> val call=c.jsonObject; val f=call.requireObject("function")
                            blocks += obj("type" to str("tool_use"),"id" to str(call.text("id")),"name" to str(f.text("name")),"input" to (f["arguments"] as? JsonObject ?: Json.parseToJsonElement(f.text("arguments")))) }
                    }
                    val targetRole=if(role=="assistant") "assistant" else "user"
                    if(native.lastOrNull()?.text("role")==targetRole) {
                        val last=native.removeAt(native.lastIndex)
                        native += obj("role" to str(targetRole),"content" to JsonArray(last.requireArray("content")+blocks))
                    } else native += obj("role" to str(targetRole),"content" to JsonArray(blocks))
                }
                val response = http.modelResponse(base.removeSuffix("/v1")+"/v1/messages",buildJsonObject {
                    put("model",model); put("max_tokens",p.config.maxTokens); put("system",prompt); put("messages",JsonArray(native))
                    if(tools.isNotEmpty()) put("tools",JsonArray(tools.map { obj("name" to str(it.name),"description" to str(it.description),"input_schema" to it.schema) }))
                    config.temperature?.let { put("temperature",it) }; config.topP?.let { put("top_p",it) }; config.topK?.let { put("top_k",it) }
                },p,p.streamEnabledFor(model),onText)
                providerTurn(p.type, response)
            }
            ProviderType.GOOGLE -> {
                val native=history.map { message ->
                    val role=message.text("role"); val parts=mutableListOf<JsonElement>()
                    if(role=="tool") parts += obj("functionResponse" to obj("name" to str(message.text("name")),"response" to obj("result" to str(message.text("content")))))
                    else {
                        if(message.text("content").isNotBlank()) parts += obj("text" to str(message.text("content")))
                        (message["tool_calls"] as? JsonArray).orEmpty().forEach { c -> val f=c.requireObject().requireObject("function")
                            parts += (c.jsonObject["googlePart"] ?: obj("functionCall" to obj("name" to str(f.text("name")),"args" to (f["arguments"] as? JsonObject ?: Json.parseToJsonElement(f.text("arguments")))))) }
                    }
                    obj("role" to str(if(role=="assistant") "model" else "user"),"parts" to JsonArray(parts))
                }
                val root=if(Regex("/v1(?:beta|alpha)?$").containsMatchIn(base)) base else "$base/v1beta"
                val response=http.modelResponse("$root/models/$model:generateContent",buildJsonObject {
                    put("contents",JsonArray(native)); put("systemInstruction",obj("parts" to JsonArray(listOf(obj("text" to str(prompt))))))
                    if(tools.isNotEmpty()) put("tools",JsonArray(listOf(obj("functionDeclarations" to JsonArray(tools.map { obj("name" to str(it.name),"description" to str(it.description),"parameters" to it.schema) })))))
                    put("generationConfig",buildJsonObject { put("maxOutputTokens",p.config.maxTokens); config.temperature?.let { put("temperature",it) }; config.topP?.let { put("topP",it) }; config.topK?.let { put("topK",it) } })
                },p,p.streamEnabledFor(model),onText)
                providerTurn(p.type, response)
            }
        }
    }
}
