package com.jamesncl.dev.flutter_embed_unity_android

import android.content.Context
import android.content.ContextWrapper
import io.flutter.Log
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory


class UnityViewFactory : PlatformViewFactory(null) {
    override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
        Log.d(this.toString(), "UnityViewFactory creating view $viewId")
        return UnityPlatformView(context)
    }
}
