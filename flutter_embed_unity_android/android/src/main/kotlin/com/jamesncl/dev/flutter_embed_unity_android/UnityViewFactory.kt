package com.jamesncl.dev.flutter_embed_unity_android

import android.content.Context
import android.content.ContextWrapper
import android.view.View
import android.widget.FrameLayout
import com.jamesncl.dev.flutter_embed_unity_android.Constants.Companion.logTag
import io.flutter.Log
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory


class UnityViewFactory(private val bindFlutterActivityToViewFactory: BindFlutterActivityToViewFactory) : PlatformViewFactory(null) {
    override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
        Log.d(this.toString(), "UnityViewFactory creating view $viewId ${context is ContextWrapper}")
        if(bindFlutterActivityToViewFactory.flutterActivity != null) {
            return UnityPlatformView(context, bindFlutterActivityToViewFactory)
        }
        else {
            Log.e(logTag, "UnityViewFactory asked to create a view, but the Flutter activity is unavailable")
            return object : PlatformView {
                override fun getView(): View? { return null }
                override fun dispose() {}
            }
        }
    }
}
