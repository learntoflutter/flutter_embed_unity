package com.jamesncl.dev.flutter_embed_unity_android


import android.content.Context
import android.graphics.Color
import android.view.View
import android.view.ViewGroup
import android.widget.FrameLayout
import com.jamesncl.dev.flutter_embed_unity_android.Constants.Companion.LOG_TAG
import io.flutter.Log
import io.flutter.plugin.platform.PlatformView

class UnityPlatformView (
    plugin: FlutterEmbedUnityAndroidPlugin,
    context: Context,
    id: Int
) :
    PlatformView {
    private val plugin: FlutterEmbedUnityAndroidPlugin
    val id: Int
    private val view: FrameLayout

    init {
        FlutterEmbedUnityAndroidPlugin.views.add(this)
        this.plugin = plugin
        this.id = id
        view = FrameLayout(context)
        view.setBackgroundColor(Color.TRANSPARENT)
        attach()
    }

    override fun getView(): View {
        return view
    }

    override fun dispose() {
        remove()
    }

    private fun remove() {
        FlutterEmbedUnityAndroidPlugin.views.remove(this)
        if (plugin.player?.parent === view) {
            if (FlutterEmbedUnityAndroidPlugin.views.isEmpty()) {
                Log.d(LOG_TAG, "All UnityPlatformViews disposed, pausing Unity player")
                view.removeView(plugin.player)
                plugin.player?.pause()
                plugin.resetScreenOrientation()
            } else {
                Log.d(LOG_TAG, "UnityPlatformView disposed, reattaching next view from list of ${FlutterEmbedUnityAndroidPlugin.views.size}")
                FlutterEmbedUnityAndroidPlugin.views[FlutterEmbedUnityAndroidPlugin.views.size - 1].reattach()
            }
        }
    }

    private fun attach() {
        Log.d(LOG_TAG, "Attaching new UnityPlatformView and resuming UnityPlayer")
        if (plugin.player?.parent != null) {
            (plugin.player?.parent as ViewGroup).removeView(plugin.player)
        }
        view.addView(plugin.player)
        plugin.player?.windowFocusChanged(plugin.player!!.requestFocus())
        plugin.player?.resume()
    }

    private fun reattach() {
        if (plugin.player?.parent !== view) {
            attach()
        }
    }
}
