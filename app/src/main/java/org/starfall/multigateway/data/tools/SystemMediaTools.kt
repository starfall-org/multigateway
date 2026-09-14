package org.starfall.multigateway.data.tools

import kotlinx.coroutines.*
import kotlinx.serialization.json.*
import okhttp3.MultipartBody
import org.starfall.multigateway.data.model.*

class SystemMediaTools(private val http: ToolHttp) {
    suspend fun generate(kind: String, provider: LlmProviderInfo, model: String, prompt: String): JsonObject {
        require(prompt.isNotBlank() && prompt.length <= 16000) { "A prompt of 1–16000 characters is required" }
        val base = providerBase(provider)
        val response = when(provider.type) {
            ProviderType.OPENAI -> if(kind == "generate_image") {
                http.post("$base/images/generations", obj("model" to str(model), "prompt" to str(prompt), "n" to JsonPrimitive(1)), provider)
            } else {
                var job = http.json(http.request("$base/videos", provider).post(MultipartBody.Builder().setType(MultipartBody.FORM)
                    .addFormDataPart("model",model).addFormDataPart("prompt",prompt).build()).build())
                val id = job.text("id")
                if (id.isNotBlank() && job.text("status") !in listOf("completed", "failed")) {
                    job = withTimeout(15*60*1000L) {
                        var state = job
                        while(state.text("status") !in listOf("completed","failed","cancelled")) {
                            delay(3000)
                            state = http.json(http.request("$base/videos/$id",provider).get().build())
                        }
                        state
                    }
                }
                check(job.text("status") !in listOf("failed","cancelled")) { "Video generation failed" }
                if (id.isNotBlank() && job.text("status") == "completed") {
                    obj("file" to str("tool-file:" + http.download("$base/videos/$id/content",provider)))
                } else job
            }
            ProviderType.GOOGLE -> {
                val root = if(Regex("/v1(?:beta|alpha)?$").containsMatchIn(base)) base else "$base/v1beta"
                if(kind == "generate_image") {
                    if(model.contains("imagen",ignoreCase = true)) http.post("$root/models/$model:predict",obj(
                        "instances" to JsonArray(listOf(obj("prompt" to str(prompt)))), "parameters" to obj("sampleCount" to JsonPrimitive(1))),provider)
                    else http.post("$root/models/$model:generateContent",obj(
                        "contents" to JsonArray(listOf(obj("parts" to JsonArray(listOf(obj("text" to str(prompt))))))),
                        "generationConfig" to obj("responseModalities" to JsonArray(listOf(str("TEXT"),str("IMAGE"))))),provider)
                } else {
                    var job = http.post("$root/models/$model:predictLongRunning",obj("instances" to JsonArray(listOf(obj("prompt" to str(prompt))))),provider)
                    val name = job.text("name")
                    require(name.matches(Regex("[A-Za-z0-9_./-]+")) && !name.contains("..")) { "Invalid video operation" }
                    job = withTimeout(15*60*1000L) {
                        var state = job
                        while((state["done"] as? JsonPrimitive)?.booleanOrNull != true) {
                            delay(3000); state = http.json(http.request("$root/$name",provider).get().build())
                        }; state
                    }
                    check(job["error"] == null) { "Video generation failed" }
                    job
                }
            }
            else -> error("This provider has no supported image/video generation API. Use an OpenAI-compatible or Google provider.")
        }
        val names = mutableListOf<String>()
        suspend fun collect(value: JsonElement, key: String = "") {
            when(value) {
                is JsonObject -> value.forEach { (k,v) -> collect(v,k) }
                is JsonArray -> value.forEach { collect(it,key) }
                is JsonPrimitive -> {
                    val s = value.contentOrNull.orEmpty()
                    if(s.startsWith("tool-file:")) names += s.removePrefix("tool-file:")
                    else if(key in listOf("url","uri") && s.startsWith("http")) {
                        check(names.size < 8) { "Too many media files in response" }
                        val sameOrigin = runCatching { java.net.URI(s).host == java.net.URI(base).host }.getOrDefault(false)
                        names += http.download(s, if(sameOrigin) provider else null)
                    }
                }
                else -> Unit
            }
        }
        collect(response)
        check(names.isNotEmpty()) { "Provider returned no supported media. Check the selected model and endpoint." }
        return obj("files" to JsonArray(names.distinct().map { str("tool-file:$it") }), "message" to str("Media saved and displayed to the user."))
    }
}
