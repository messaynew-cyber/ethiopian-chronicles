package com.adwa.chronicles

import android.speech.tts.TextToSpeech
import android.speech.tts.UtteranceProgressListener
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.*

class MainActivity : FlutterActivity() {
    private var tts: TextToSpeech? = null
    private val CHANNEL = "com.adwa.chronicles/tts"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)

        channel.setMethodCallHandler { call, result ->
            when (call.method) {
                "speak" -> {
                    val text = call.argument<String>("text") ?: ""
                    val language = call.argument<String>("language") ?: "en"
                    speak(text, language) { channel.invokeMethod("onDone", null) }
                    result.success(true)
                }
                "stop" -> {
                    tts?.stop()
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun speak(text: String, language: String, onDone: () -> Unit) {
        tts = TextToSpeech(this) { status ->
            if (status == TextToSpeech.SUCCESS) {
                val locale = if (language == "am") Locale("am", "ET") else Locale.US
                tts?.language = locale
                tts?.setSpeechRate(0.7f)
                tts?.setOnUtteranceProgressListener(object : UtteranceProgressListener() {
                    override fun onDone(utteranceId: String?) { onDone() }
                    override fun onError(utteranceId: String?) { onDone() }
                    override fun onStart(utteranceId: String?) {}
                })
                tts?.speak(text, TextToSpeech.QUEUE_FLUSH, null, "chronicles_tts")
            }
        }
    }

    override fun onDestroy() {
        tts?.stop()
        tts?.shutdown()
        super.onDestroy()
    }
}
