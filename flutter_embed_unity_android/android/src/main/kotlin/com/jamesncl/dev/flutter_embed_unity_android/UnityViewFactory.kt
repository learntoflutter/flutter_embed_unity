package com.jamesncl.dev.flutter_embed_unity_android

import com.jamesncl.dev.flutter_embed_unity_android.FlutterEmbedUnityAndroidPlugin
import android.content.Context
import io.flutter.Log
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory


class UnityViewFactory internal constructor(plugin: FlutterEmbedUnityAndroidPlugin) :
    PlatformViewFactory(null) {
    private val plugin: FlutterEmbedUnityAndroidPlugin

    init {
        this.plugin = plugin
    }

    override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
        Log.d(this.toString(), "create: $viewId")
        return UnityPlatformView(plugin, context, viewId)
    }
}
