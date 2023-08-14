package com.jamesncl.dev.flutter_embed_unity_android

import android.content.Context
import android.graphics.Color
import android.view.View
import android.widget.FrameLayout
import io.flutter.Log
import io.flutter.plugin.platform.PlatformView
import io.flutter.util.ViewUtils.getActivity

class UnityPlatformView(
    viewFactoryContext: Context,
    bindFlutterActivityToViewFactory: BindFlutterActivityToViewFactory,
    val baseView: FrameLayout = FrameLayout(viewFactoryContext),
    val player: UnityPlayerCustom = UnityPlayerCustom(bindFlutterActivityToViewFactory.flutterActivity!!)) : PlatformView {

//    private val baseView: View
//
    init {
        baseView.setBackgroundColor(Color.GREEN)
        baseView.addView(player)
        // It's important to call windowFocusChanged, otherwise unity will not start
        // (not sure why - UnityPlayer is undocumented)
        player.windowFocusChanged(player.requestFocus())
    }

    // PlatformView
    override fun getView(): View {
        return baseView
    }

    // PlatformView
    override fun onFlutterViewAttached(flutterView: View) {
        super.onFlutterViewAttached(flutterView)
        Log.d(Constants.logTag, "UnityPlayerCustom onFlutterViewAttached, resuming Unity")
        player.resume()  // UnityPlayer
    }

    // PlatformView
    override fun onFlutterViewDetached() {
        Log.d(Constants.logTag, "UnityPlayerCustom onFlutterViewDetached, pausing Unity")
        player.pause()  // UnityPlayer
        super.onFlutterViewDetached()
    }

    // PlatformView
    override fun dispose() {
        Log.d(Constants.logTag, "UnityPlayerCustom dispose, destroying Unity")
        player.destroy()  // UnityPlayer
    }
}