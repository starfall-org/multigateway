package org.starfall.multigateway.data.service

import android.content.Context
import android.media.MediaPlayer
import java.io.File

class SpeechAudioPlayer(private val context: Context) {
    private var player: MediaPlayer? = null
    private var currentFile: File? = null

    fun play(audio: ByteArray) {
        stop()
        val file = File.createTempFile("multigateway_tts_", ".mp3", context.cacheDir)
        file.writeBytes(audio)
        currentFile = file

        player = MediaPlayer().apply {
            setDataSource(file.absolutePath)
            setOnPreparedListener { it.start() }
            setOnCompletionListener {
                it.release()
                if (player === it) player = null
                currentFile?.delete()
                currentFile = null
            }
            setOnErrorListener { mediaPlayer, _, _ ->
                mediaPlayer.release()
                if (player === mediaPlayer) player = null
                currentFile?.delete()
                currentFile = null
                true
            }
            prepareAsync()
        }
    }

    fun stop() {
        player?.runCatching {
            if (isPlaying) stop()
            release()
        }
        player = null
        currentFile?.delete()
        currentFile = null
    }

    fun shutdown() = stop()
}
