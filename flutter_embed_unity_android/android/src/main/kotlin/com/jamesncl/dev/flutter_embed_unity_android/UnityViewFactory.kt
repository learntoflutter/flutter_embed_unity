package com.jamesncl.dev.flutter_embed_unity_android

import android.content.Context
import android.view.View
import com.jamesncl.dev.flutter_embed_unity_android.FlutterEmbedConstants.Companion.logTag
import io.flutter.Log
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory


class UnityViewFactory(
    private val flutterActivityRegistry: FlutterActivityRegistry,
    private val platformViewRegistry: PlatformViewRegistry
) : PlatformViewFactory(null) {
    override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
        Log.d(this.toString(), "UnityViewFactory creating view $viewId")

        // UnityPlayer expects to be passed a context which is an Activity. It will crash during
        // resume() if it isn't (NullPointerException: Attempt to invoke virtual method
        // 'android.content.ContentResolver android.content.Context.getContentResolver()' on a null
        // object reference)
        flutterActivityRegistry.activity.let { activity ->
            if (activity != null) {
                val unityPlayerCustom = UnityPlayerCustom.getInstance(activity)
                val unityPlatformView = UnityPlatformView(unityPlayerCustom, context)
                platformViewRegistry.activePlatformView = unityPlatformView
                return unityPlatformView
            }
            else {
                Log.e(logTag, "Error creating UnityPlatformView: an activity is not available")
                return object : PlatformView {
                    override fun getView(): View? { return null }
                    override fun dispose() {}
                }
            }
        }
    }
}
