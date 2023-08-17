package com.jamesncl.dev.flutter_embed_unity_android

import android.content.Context
import android.view.View
import com.jamesncl.dev.flutter_embed_unity_android.Constants.Companion.logTag
import io.flutter.Log
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory
import io.flutter.util.ViewUtils.getActivity


class UnityViewFactory(private val platformViewRegistry: PlatformViewRegistry) : PlatformViewFactory(null) {
    override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
        Log.d(this.toString(), "UnityViewFactory creating view $viewId")

        // UnityPlayer expects to be passed a context which is an Activity. It will crash during
        // resume() if it isn't (NullPointerException: Attempt to invoke virtual method
        // 'android.content.ContentResolver android.content.Context.getContentResolver()' on a null
        // object reference)
        val activity = getActivity(context)
        if (activity != null) {
            val unityPlayerCustom = UnityPlayerCustom.getInstance(activity)
            val unityPlatformView = UnityPlatformView(unityPlayerCustom, context)
            platformViewRegistry.activePlatformView = unityPlatformView
            return unityPlatformView
        }
        else {
            Log.e(logTag, "Error creating UnityPlatformView: could not get activity from context passed to factory")
            return object : PlatformView {
                override fun getView(): View? { return null }
                override fun dispose() {}
            }
        }
    }
}
