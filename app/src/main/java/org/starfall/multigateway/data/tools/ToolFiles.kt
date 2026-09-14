package org.starfall.multigateway.data.tools

import android.content.Context
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.ensureActive
import kotlinx.coroutines.withContext
import java.io.*
import java.util.UUID
import kotlin.coroutines.coroutineContext

/** App-private files only; database rows never contain binary data. */
class ToolFiles(val directory: File) {
    constructor(context: Context): this(File(context.filesDir, "tool_media"))
    init {
        directory.mkdirs()
        synchronized(initialized) {
            if(initialized.add(directory.absolutePath)) directory.listFiles()?.filter { it.name.endsWith(".part") }?.forEach { it.delete() }
        }
    }
    companion object { val revision = kotlinx.coroutines.flow.MutableStateFlow(0L); private val initialized = mutableSetOf<String>() }
    private val limit = 256L * 1024 * 1024
    fun resolve(name: String): File? = name.takeIf { it.matches(Regex("[a-zA-Z0-9._-]+")) }
        ?.let { File(directory, it) }?.takeIf { it.isFile && !it.name.endsWith(".part") }
    fun list(): List<File> = directory.listFiles()?.filter { it.isFile && !it.name.endsWith(".part") }?.sortedByDescending { it.lastModified() } ?: emptyList()
    fun delete(names: Collection<String>) { names.forEach { resolve(it)?.delete() }; revision.value++ }
    private fun checkSpace() { check(directory.usableSpace > 64L * 1024 * 1024) { "Not enough storage. Free space in Storage." } }
    suspend fun save(input: InputStream, mime: String? = null): String = withContext(Dispatchers.IO) {
        checkSpace()
        val temp = File(directory, "${UUID.randomUUID()}.part")
        try {
            temp.outputStream().use { out ->
                val buffer = ByteArray(32768)
                var total = 0L
                while (true) {
                    coroutineContext.ensureActive()
                    val n = input.read(buffer)
                    if (n < 0) break
                    total += n
                    if(total % (1024*1024) < n) checkSpace()
                    check(total <= limit) { "File exceeds the 256 MB limit." }
                    out.write(buffer, 0, n)
                }
            }
            check(temp.length() > 0) { "Empty media response" }
            val header = ByteArray(16)
            temp.inputStream().use { it.read(header) }
            val ext = when {
                header[0] == 0x89.toByte() && header[1] == 0x50.toByte() -> "png"
                header[0] == 0xff.toByte() && header[1] == 0xd8.toByte() -> "jpg"
                String(header, 0, 3) == "GIF" -> "gif"
                String(header, 8, 4) == "WEBP" -> "webp"
                String(header, 4, 4) == "ftyp" -> "mp4"
                header[0] == 0x1a.toByte() && header[1] == 0x45.toByte() -> "webm"
                mime == "text/plain" -> "txt"
                else -> "bin"
            }
            val dest = File(directory, "${UUID.randomUUID()}.$ext")
            check(temp.renameTo(dest)) { "Could not save media" }
            revision.value++
            dest.name
        } finally { temp.delete() }
    }
    suspend fun decode(raw: File): String = raw.inputStream().use { source ->
        java.util.Base64.getMimeDecoder().wrap(source).use { save(it) }
    }
    /** Streaming JSON string scanner: large base64 strings are spooled to disk, not held in RAM. */
    suspend fun sanitize(reader: Reader): String = withContext(Dispatchers.IO) {
        val input = PushbackReader(BufferedReader(reader), 2)
        val output = StringBuilder()
        var lastKey = ""
        while (true) {
            coroutineContext.ensureActive()
            val c = input.read()
            if (c < 0) break
            if (c != '"'.code) {
                output.append(c.toChar())
            } else {
                val value = StringBuilder()
                var raw: File? = null
                var spool: Writer? = null
                var escaped = false
                var length = 0L
                try {
                    while (true) {
                        val n = input.read()
                        check(n >= 0) { "Truncated JSON response" }
                        if (!escaped && n == '"'.code) break
                        length++
                        if (length % 32768L == 0L) coroutineContext.ensureActive()
                        check(length <= limit * 2) { "Tool result exceeds file limit" }
                        if (raw == null && value.length >= 16384 && lastKey in setOf("b64_json", "data", "bytesBase64Encoded", "video_base64", "base64", "blob")) {
                            checkSpace()
                            raw = File(directory, "${UUID.randomUUID()}.part")
                            spool = raw.bufferedWriter()
                            spool.write(value.toString())
                            value.setLength(0)
                        }
                        if (spool != null) spool.write(n) else if (value.length < 65536) value.append(n.toChar())
                        escaped = if (escaped) false else n == '\\'.code
                    }
                    spool?.close()
                    var next: Int
                    do { next = input.read() } while (next >= 0 && next.toChar().isWhitespace())
                    if (next >= 0) input.unread(next)
                    if (next == ':'.code) {
                        lastKey = value.toString()
                        output.append('"').append(value).append('"')
                    } else if (raw != null) {
                        val normalized = File(directory, "${UUID.randomUUID()}.part")
                        try {
                            // JSON base64 may escape forward slashes. No media string is materialized.
                            raw.reader().buffered().use { r -> normalized.bufferedWriter().use { w ->
                                var slash = false
                                while (true) {
                                    val v = r.read(); if (v < 0) break
                                    if (slash) { if (v != 'n'.code && v != 'r'.code) w.write(v); slash = false }
                                    else if (v == '\\'.code) slash = true else w.write(v)
                                }
                            } }
                            val name = decode(normalized)
                            output.append('"').append("tool-file:").append(name).append('"')
                        } finally { normalized.delete() }
                    } else {
                        // Small base64 media is also saved, including small previews.
                        val text = value.toString()
                        if (lastKey in setOf("b64_json", "bytesBase64Encoded", "video_base64", "base64", "blob") ||
                            (lastKey == "data" && text.length > 100 && text.matches(Regex("[A-Za-z0-9+/=\\\\]+")))) {
                            val rawSmall = File(directory, "${UUID.randomUUID()}.part")
                            try {
                                rawSmall.writeText(text.replace("\\/", "/"))
                                output.append('"').append("tool-file:").append(decode(rawSmall)).append('"')
                            } finally { rawSmall.delete() }
                        } else {
                            val decoded = runCatching { kotlinx.serialization.json.Json.parseToJsonElement("\"$text\"") }.getOrNull()
                            output.append(decoded?.toString() ?: "\"[Text truncated]\"")
                        }
                    }
                } finally { spool?.close(); raw?.delete() }
            }
            check(output.length <= 2 * 1024 * 1024) { "Tool metadata exceeds 2 MB limit" }
        }
        output.toString()
    }
}
