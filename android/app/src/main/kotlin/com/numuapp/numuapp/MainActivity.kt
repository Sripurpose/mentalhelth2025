package com.numuapp.numuapp

import android.content.Intent
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.numuapp.share/channel"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        handleShareIntent(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        handleShareIntent(intent)
    }

    private fun handleShareIntent(intent: Intent?) {
        if (intent?.action == Intent.ACTION_SEND) {
            when {
                intent.type?.startsWith("text/") == true -> {
                    val sharedText = intent.getStringExtra(Intent.EXTRA_TEXT)
                    sharedText?.let {
                        sendToFlutter("text", it)
                    }
                }
                intent.type?.startsWith("image/") == true -> {
                    val imageUri = intent.getParcelableExtra<android.net.Uri>(Intent.EXTRA_STREAM)
                    imageUri?.let {
                        sendToFlutter("image", it.toString())
                    }
                }
                intent.type?.startsWith("video/") == true -> {
                    val videoUri = intent.getParcelableExtra<android.net.Uri>(Intent.EXTRA_STREAM)
                    videoUri?.let {
                        sendToFlutter("video", it.toString())
                    }
                }
            }
        } else if (intent?.action == Intent.ACTION_SEND_MULTIPLE) {
            val uris = intent.getParcelableArrayListExtra<android.net.Uri>(Intent.EXTRA_STREAM)
            uris?.let {
                val list = it.map { uri -> uri.toString() }
                sendToFlutter("multiple", list.joinToString(","))
            }
        }
    }

    private fun sendToFlutter(type: String, data: String) {
        flutterEngine?.let { engine ->
            MethodChannel(engine.dartExecutor.binaryMessenger, CHANNEL)
                .invokeMethod("onShareReceived", mapOf("type" to type, "data" to data))
        }
    }
}
