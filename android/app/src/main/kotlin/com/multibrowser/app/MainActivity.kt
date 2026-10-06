package com.multibrowser.app

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        flutterEngine.platformViewsController.registry.registerViewFactory(
            "com.multibrowser/geckoview",
            GeckoViewFactory(flutterEngine.dartExecutor.binaryMessenger)
        )
    }
}
