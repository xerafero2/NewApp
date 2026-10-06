package com.multibrowser.app

import android.content.Context
import android.view.View
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.platform.PlatformView
import org.mozilla.geckoview.GeckoRuntime
import org.mozilla.geckoview.GeckoSession
import org.mozilla.geckoview.GeckoSessionSettings
import org.mozilla.geckoview.GeckoView

class GeckoViewPlatformView(
    context: Context,
    messenger: BinaryMessenger,
    id: Int,
    params: Map<String, Any?>
) : PlatformView {

    private val geckoView: GeckoView = GeckoView(context)
    private val session: GeckoSession
    private val channel: MethodChannel = MethodChannel(messenger, "com.multibrowser/geckoview_$id")

    init {
        val runtime = GeckoRuntime.getDefault(context)
        session = GeckoSession()

        val settings = session.settings
        settings.userAgentMode = GeckoSessionSettings.USER_AGENT_MODE_MOBILE
        settings.usePrivateMode = false

        val ua = params["userAgent"] as? String
        if (!ua.isNullOrBlank()) {
            settings.userAgentOverride = ua
        }

        session.open(runtime)
        geckoView.setSession(session)

        channel.setMethodCallHandler { call, result ->
            when (call.method) {
                "load" -> {
                    val url = call.argument<String>("url") ?: ""
                    if (url.isNotBlank()) session.loadUri(url)
                    result.success(null)
                }
                "reload" -> {
                    session.reload()
                    result.success(null)
                }
                "back" -> {
                    session.goBack()
                    result.success(null)
                }
                "forward" -> {
                    session.goForward()
                    result.success(null)
                }
                "setUserAgent" -> {
                    val newUa = call.argument<String>("ua") ?: ""
                    settings.userAgentOverride = if (newUa.isBlank()) null else newUa
                    session.reload()
                    result.success(null)
                }
                "evaluateJS" -> {
                    val js = call.argument<String>("js") ?: ""
                    session.evaluateJS(js)
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }

        val url = params["url"] as? String
        if (!url.isNullOrBlank()) {
            session.loadUri(url)
        }
    }

    override fun getView(): View = geckoView

    override fun dispose() {
        channel.setMethodCallHandler(null)
        session.close()
    }
}
