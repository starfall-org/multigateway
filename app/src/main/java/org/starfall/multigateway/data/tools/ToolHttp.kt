package org.starfall.multigateway.data.tools

import kotlinx.coroutines.*
import okhttp3.*
import okhttp3.MediaType.Companion.toMediaType
import okhttp3.RequestBody.Companion.toRequestBody
import kotlinx.serialization.json.*
import org.starfall.multigateway.data.model.*
import java.util.concurrent.TimeUnit
import kotlin.coroutines.resumeWithException

internal fun obj(vararg pairs: Pair<String, JsonElement>) = JsonObject(mapOf(*pairs))
internal fun str(value: String) = JsonPrimitive(value)
internal fun JsonObject.text(key: String) = (get(key) as? JsonPrimitive)?.contentOrNull.orEmpty()
internal fun providerBase(p: LlmProviderInfo): String {
    var base = p.baseUrl.trim().trimEnd('/')
    listOf("/chat/completions", "/responses", "/messages", "/models", "/chat").forEach { base = base.removeSuffix(it) }
    return base
}
class ToolHttp(val files: ToolFiles? = null) {
    val client = OkHttpClient.Builder().connectTimeout(30, TimeUnit.SECONDS).readTimeout(180, TimeUnit.SECONDS)
        .callTimeout(5, TimeUnit.MINUTES).followRedirects(false).build()
    suspend fun execute(request: Request): Response = suspendCancellableCoroutine { cont ->
        val call = client.newCall(request)
        cont.invokeOnCancellation { call.cancel() }
        call.enqueue(object: Callback {
            override fun onFailure(call: Call, e: java.io.IOException) { if (cont.isActive) cont.resumeWithException(e) }
            override fun onResponse(call: Call, response: Response) {
                cont.resume(response) { response.close() }
            }
        })
    }
    fun request(url: String, provider: LlmProviderInfo? = null): Request.Builder {
        val builder = Request.Builder().url(url)
        provider?.let { p ->
            val auth = p.auth
            val token = auth.key?.takeIf { it.isNotBlank() } ?: auth.value.orEmpty()
            when (auth.method) {
                AuthMethod.CUSTOM_HEADER -> auth.key?.takeIf { it.isNotBlank() }?.let { builder.header(it, auth.value.orEmpty()) }
                AuthMethod.QUERY_PARAM -> builder.url(builder.build().url.newBuilder().setQueryParameter(auth.key ?: "key", auth.value.orEmpty()).build())
                else -> if (token.isNotBlank()) when (p.type) {
                    ProviderType.GOOGLE -> builder.header("x-goog-api-key", token)
                    ProviderType.ANTHROPIC -> builder.header("x-api-key", token)
                    else -> builder.header("Authorization", "Bearer $token")
                }
            }
            if (p.type == ProviderType.ANTHROPIC) builder.header("anthropic-version", "2023-06-01")
            p.config.headers.forEach { (k,v) -> builder.header(k,v) }
        }
        return builder
    }
    suspend fun json(request: Request): JsonObject = withContext(Dispatchers.IO) {
        execute(request).use { response ->
            check(response.isSuccessful) { "HTTP ${response.code}: ${response.message}" }
            val body = response.body ?: error("Empty response")
            val text = files?.sanitize(body.charStream()) ?: body.charStream().use { r ->
                val buffer = CharArray(8192); val out = StringBuilder()
                while (true) { val n = r.read(buffer); if(n<0) break; out.append(buffer,0,n); check(out.length <= 2*1024*1024) { "Response too large" } }
                out.toString()
            }
            Json.parseToJsonElement(text).jsonObject
        }
    }
    suspend fun post(url: String, data: JsonObject, provider: LlmProviderInfo? = null) =
        json(request(url, provider).post(data.toString().toRequestBody("application/json".toMediaType())).build())
    suspend fun download(url: String, provider: LlmProviderInfo? = null): String = withContext(Dispatchers.IO) {
        var request = request(url, provider).get().build()
        repeat(5) {
            execute(request).use { response ->
                if (response.isRedirect) {
                    val target = response.header("Location")?.let { request.url.resolve(it) } ?: error("Invalid download redirect")
                    check(target.scheme == "https" || target.host == request.url.host) { "Unsafe media redirect" }
                    // Never forward provider credentials to a CDN or signed download URL.
                    request = Request.Builder().url(target).build()
                } else {
                    check(response.isSuccessful) { "Media download failed: HTTP ${response.code}" }
                    return@withContext files!!.save(response.body!!.byteStream(), response.header("Content-Type"))
                }
            }
        }
        error("Too many media redirects")
    }
}
