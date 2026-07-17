package com.example.truecart_mobile

import android.content.Intent
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val launchChannel = "truecart_mobile/launch"
    private var pendingLaunchPayload: HashMap<String, String>? = null

    override fun onCreate(savedInstanceState: android.os.Bundle?) {
        super.onCreate(savedInstanceState)
        pendingLaunchPayload = extractLaunchPayload(intent)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            launchChannel,
        ).setMethodCallHandler { call, result ->
            if (call.method == "consumeLaunchPayload") {
                result.success(pendingLaunchPayload)
                pendingLaunchPayload = null
            } else {
                result.notImplemented()
            }
        }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        pendingLaunchPayload = extractLaunchPayload(intent)
    }

    private fun extractLaunchPayload(intent: Intent?): HashMap<String, String>? {
        if (intent == null) {
            return null
        }

        val launchSource = intent.getStringExtra("launch_source")
        val productUrl = intent.getStringExtra("product_url")

        if (launchSource.isNullOrBlank() || productUrl.isNullOrBlank()) {
            return null
        }

        return hashMapOf(
            "launch_source" to launchSource,
            "product_url" to productUrl,
        )
    }
}
