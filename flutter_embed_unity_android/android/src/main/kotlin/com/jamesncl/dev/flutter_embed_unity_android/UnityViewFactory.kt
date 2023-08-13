package com.jamesncl.dev.flutter_embed_unity_android

import com.jamesncl.dev.flutter_embed_unity_android.FlutterEmbedUnityAndroidPlugin
import android.content.Context
import io.flutter.Log
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory


class UnityViewFactory (private val unityPlayerManager: UnityPlayerManager) :
    PlatformViewFactory(null) {

    override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
        Log.d(this.toString(), "UnityViewFactory creating view $viewId")
        return UnityPlatformView(unityPlayerManager, context, viewId)
    }
}
