package com.learntoflutter.flutter_embed_unity_android.platformView

import android.content.Context
import android.graphics.Color
import android.view.View
import android.view.ViewGroup
import android.widget.RelativeLayout
import android.widget.TextView
import com.learntoflutter.flutter_embed_unity_android.constants.FlutterEmbedConstants.Companion.logTag
import com.learntoflutter.flutter_embed_unity_android.unity.UnityPlayerSingleton
import io.flutter.BuildConfig
import io.flutter.Log
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory


class UnityViewFactory : PlatformViewFactory(null) {


    private val unityViewStack = UnityViewStack()

    override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
        Log.d(this.toString(), "UnityViewFactory creating view $viewId")

        try {
            val view = UnityView(context)
            unityViewStack.pushView(view)
            return view
        }
        catch (e: NoClassDefFoundError) {
            val errorMessage = "Unity library not found. Your exported Unity " +
                    "project is not correctly linked to your Android app. Make sure " +
                    "you have followed the required setup steps in the " +
                    "flutter_embed_unity README, in particular the modifications to " +
                    "your project's settings.gradle, properites.gradle, and your " +
                    "app module's build.gradle."
            Log.e(logTag, errorMessage)
            return createErrorView(context, errorMessage)
        }
        catch(e: Throwable) {
            val errorMessage = e.message ?: e.toString()
            Log.e(logTag, errorMessage)
            return createErrorView(context, errorMessage)
        }
    }

    private fun createErrorView(context: Context, errorMessage: String) : PlatformView {
        return object : PlatformView {
            override fun getView(): View {
                val layout = RelativeLayout(context)
                layout.setBackgroundColor(Color.YELLOW)
                if(BuildConfig.DEBUG) {
                    val textView = TextView(context)
                    textView.text = errorMessage
                    textView.setTextColor(Color.BLACK)
                    val params: RelativeLayout.LayoutParams =
                        RelativeLayout.LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT)
                    params.addRule(RelativeLayout.CENTER_IN_PARENT)
                    textView.layoutParams = params
                    layout.addView(textView)
                }
                return layout
            }
            override fun dispose() {}
        }
    }
}
