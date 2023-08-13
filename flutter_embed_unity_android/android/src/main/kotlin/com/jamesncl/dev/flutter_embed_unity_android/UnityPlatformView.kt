package com.jamesncl.dev.flutter_embed_unity_android


import android.content.Context
import android.graphics.Color
import android.view.View
import android.view.ViewGroup
import android.widget.FrameLayout
import com.jamesncl.dev.flutter_embed_unity_android.Constants.Companion.logTag
import io.flutter.Log
import io.flutter.plugin.platform.PlatformView

class UnityPlatformView (private val unityPlayerManager: UnityPlayerManager,
    context: Context, id: Int) : PlatformView {

    private val view: FrameLayout

    init {
        views.add(this)
        view = FrameLayout(context)
        view.setBackgroundColor(Color.TRANSPARENT)
        attach()
    }

    companion object {
        val views: MutableList<UnityPlatformView> = mutableListOf()
    }

    override fun getView(): View {
        return view
    }

    override fun dispose() {
        remove()
    }

    private fun remove() {
        views.remove(this)
        if (unityPlayerManager.player?.parent === view) {
            if (views.isEmpty()) {
                Log.d(logTag, "All UnityPlatformViews disposed, pausing Unity player")
                view.removeView(unityPlayerManager.player)
                unityPlayerManager.player?.pause()
                unityPlayerManager.resetScreenOrientation()
            } else {
                Log.d(logTag, "UnityPlatformView disposed, reattaching next view from list of ${views.size}")
                views[views.size - 1].reattach()
            }
        }
    }

    private fun attach() {
        Log.d(logTag, "Attaching new UnityPlatformView and resuming UnityPlayer ${unityPlayerManager.player}")
        if (unityPlayerManager.player?.parent != null) {
            (unityPlayerManager.player?.parent as ViewGroup).removeView(unityPlayerManager.player)
        }
        view.addView(unityPlayerManager.player)
        unityPlayerManager.player?.windowFocusChanged(unityPlayerManager.player!!.requestFocus())
        unityPlayerManager.player?.resume()
    }

    private fun reattach() {
        if (unityPlayerManager.player?.parent !== view) {
            attach()
        }
    }
}
