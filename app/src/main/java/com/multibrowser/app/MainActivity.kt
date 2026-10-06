package com.multibrowser.app

import android.annotation.SuppressLint
import android.content.Context
import android.graphics.Typeface
import android.net.Uri
import android.os.Bundle
import android.view.View
import android.view.ViewGroup
import android.view.inputmethod.EditorInfo
import android.webkit.WebChromeClient
import android.webkit.WebSettings
import android.webkit.WebView
import android.webkit.WebViewClient
import android.widget.EditText
import android.widget.ImageButton
import android.widget.LinearLayout
import android.widget.ProgressBar
import android.widget.TextView
import androidx.appcompat.app.AppCompatActivity
import org.json.JSONArray
import org.json.JSONObject

class MainActivity : AppCompatActivity() {

    private data class Profile(
        var name: String = "",
        var url: String = "",
        var userAgent: String = ""
    )

    private class Slot(
        val urlEt: EditText,
        val uaEt: EditText,
        val web: WebView
    )

    private val profiles = MutableList(4) { Profile() }
    private val slots = mutableListOf<Slot>()

    private val prefs by lazy {
        getSharedPreferences("multibrowser", Context.MODE_PRIVATE)
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        loadProfiles()
        setContentView(buildUi())
    }

    /* ---------------- UI ---------------- */

    private fun buildUi(): View {
        val root = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            setBackgroundColor(0xFF0B0D12.toInt())
        }

        // Header
        val header = LinearLayout(this).apply {
            orientation = LinearLayout.HORIZONTAL
            setPadding(dp(14), dp(12), dp(14), dp(12))
            setBackgroundColor(0xFF10141D.toInt())
            layoutParams = LinearLayout.LayoutParams(MATCH, WRAP)
        }
        val title = TextView(this).apply {
            text = "MultiBrowser"
            setTextColor(0xFFE6EAF2.toInt())
            textSize = 16f
            setTypeface(typeface, Typeface.BOLD)
        }
        val tag = TextView(this).apply {
            text = "  4 PROFILES"
            setTextColor(0xFF8B95A7.toInt())
            textSize = 10f
            setTypeface(typeface, Typeface.BOLD)
        }
        header.addView(title)
        header.addView(tag)
        root.addView(header)

        // Grid 2x2
        val grid = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            layoutParams = LinearLayout.LayoutParams(MATCH, 0, 1f)
        }
        val row1 = row()
        val row2 = row()
        grid.addView(row1)
        grid.addView(row2)

        for (i in 0 until 4) {
            val item = layoutInflater.inflate(R.layout.item_profile, grid, false)
            val lp = LinearLayout.LayoutParams(0, MATCH, 1f)
            val m = dp(3)
            lp.setMargins(m, m, m, m)
            item.layoutParams = lp

            slots.add(bindSlot(item, i))
            if (i < 2) row1.addView(item) else row2.addView(item)
        }

        root.addView(grid)
        return root
    }

    private fun row() = LinearLayout(this).apply {
        orientation = LinearLayout.HORIZONTAL
        layoutParams = LinearLayout.LayoutParams(MATCH, 0, 1f)
    }

    /* ---------------- slot binding ---------------- */

    @SuppressLint("SetJavaScriptEnabled")
    private fun bindSlot(item: View, index: Int): Slot {
        val badge = item.findViewById<TextView>(R.id.badge)
        val nameEt = item.findViewById<EditText>(R.id.nameEt)
        val urlEt = item.findViewById<EditText>(R.id.urlEt)
        val uaEt = item.findViewById<EditText>(R.id.uaEt)
        val uaRow = item.findViewById<LinearLayout>(R.id.uaRow)
        val uaToggle = item.findViewById<ImageButton>(R.id.uaToggle)
        val goBtn = item.findViewById<ImageButton>(R.id.goBtn)
        val backBtn = item.findViewById<ImageButton>(R.id.backBtn)
        val reloadBtn = item.findViewById<ImageButton>(R.id.reloadBtn)
        val web = item.findViewById<WebView>(R.id.web)
        val progress = item.findViewById<ProgressBar>(R.id.progress)

        val p = profiles[index]

        badge.text = (index + 1).toString()
        nameEt.setText(p.name)
        urlEt.setText(p.url)
        uaEt.setText(p.userAgent)
        uaRow.visibility = if (p.userAgent.isNotEmpty()) View.VISIBLE else View.GONE

        // WebView settings
        val s: WebSettings = web.settings
        s.javaScriptEnabled = true
        s.domStorageEnabled = true
        s.databaseEnabled = true
        s.loadWithOverviewMode = true
        s.useWideViewPort = true
        s.builtInZoomControls = true
        s.displayZoomControls = false
        s.setSupportZoom(true)
        s.mediaPlaybackRequiresUserGesture = false
        s.cacheMode = WebSettings.LOAD_DEFAULT

        if (p.userAgent.isNotBlank()) s.userAgentString = p.userAgent

        web.webChromeClient = object : WebChromeClient() {
            override fun onProgressChanged(view: WebView?, newProgress: Int) {
                progress.progress = newProgress
                progress.visibility = if (newProgress in 1..99) View.VISIBLE else View.GONE
            }
        }
        web.webViewClient = object : WebViewClient() {
            override fun onPageFinished(view: WebView?, url: String?) {
                super.onPageFinished(view, url)
                progress.visibility = View.GONE
                if (!url.isNullOrBlank()) {
                    profiles[index].url = url
                    if (!urlEt.hasFocus()) urlEt.setText(url)
                    saveProfiles()
                }
            }
        }

        // Profile name
        nameEt.setOnFocusChangeListener { _, hasFocus ->
            if (!hasFocus) {
                val v = nameEt.text.toString().trim().ifBlank { "Profile ${index + 1}" }
                profiles[index].name = v
                nameEt.setText(v)
                saveProfiles()
            }
        }

        // URL navigate
        val doNavigate = {
            var u = urlEt.text.toString().trim()
            if (u.isNotEmpty()) {
                if (!u.startsWith("http://") && !u.startsWith("https://") && !u.startsWith("about:")) {
                    u = if (u.contains(" ") || !u.contains("."))
                        "https://www.google.com/search?q=" + Uri.encode(u)
                    else "https://$u"
                }
                urlEt.setText(u)
                profiles[index].url = u
                saveProfiles()
                web.loadUrl(u)
            }
        }
        urlEt.setOnEditorActionListener { _, actionId, _ ->
            if (actionId == EditorInfo.IME_ACTION_GO) { doNavigate(); true } else false
        }
        goBtn.setOnClickListener { doNavigate() }
        backBtn.setOnClickListener { if (web.canGoBack()) web.goBack() }
        reloadBtn.setOnClickListener { web.reload() }

        // UA toggle
        uaToggle.setOnClickListener {
            uaRow.visibility = if (uaRow.visibility == View.VISIBLE) View.GONE else View.VISIBLE
        }

        // UA apply (on focus loss)
        uaEt.setOnFocusChangeListener { _, hasFocus ->
            if (!hasFocus) {
                val ua = uaEt.text.toString().trim()
                if (ua != profiles[index].userAgent) {
                    profiles[index].userAgent = ua
                    saveProfiles()
                    if (ua.isBlank()) {
                        web.settings.userAgentString = null
                    } else {
                        web.settings.userAgentString = ua
                    }
                    web.reload()
                }
            }
        }

        // Initial load
        web.loadUrl(p.url.ifBlank { "about:blank" })

        return Slot(urlEt, uaEt, web)
    }

    /* ---------------- persistence ---------------- */

    private fun loadProfiles() {
        val raw = prefs.getString("profiles", null)
        if (raw != null) {
            try {
                val arr = JSONArray(raw)
                for (i in 0 until 4) {
                    val o = arr.optJSONObject(i) ?: JSONObject()
                    profiles[i] = Profile(
                        o.optString("name", "Profile ${i + 1}"),
                        o.optString("url", ""),
                        o.optString("userAgent", "")
                    )
                }
                return
            } catch (_: Exception) {}
        }
        profiles[0] = Profile("Personal", "https://www.google.com/", "")
        profiles[1] = Profile("Work", "https://mail.google.com/", "")
        profiles[2] = Profile("Social", "https://x.com/", "")
        profiles[3] = Profile("Research", "https://duckduckgo.com/", "")
    }

    private fun saveProfiles() {
        val arr = JSONArray()
        profiles.forEach { p ->
            arr.put(JSONObject().apply {
                put("name", p.name)
                put("url", p.url)
                put("userAgent", p.userAgent)
            })
        }
        prefs.edit().putString("profiles", arr.toString()).apply()
    }

    /* ---------------- lifecycle ---------------- */

    override fun onPause() {
        super.onPause()
        saveProfiles()
        slots.forEach { it.web.onPause() }
    }

    override fun onResume() {
        super.onResume()
        slots.forEach { it.web.onResume() }
    }

    override fun onDestroy() {
        slots.forEach { runCatching { it.web.destroy() } }
        super.onDestroy()
    }

    private fun dp(v: Int): Int = (v * resources.displayMetrics.density).toInt()

    companion object {
        private const val MATCH = ViewGroup.LayoutParams.MATCH_PARENT
        private const val WRAP = ViewGroup.LayoutParams.WRAP_CONTENT
    }
}
