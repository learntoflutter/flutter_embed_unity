package com.jamesncl.dev.flutter_embed_unity_android

import android.annotation.SuppressLint
import android.app.Activity
import android.content.Context
import android.content.Intent
import android.content.res.Configuration
import android.os.Bundle
import android.view.InputDevice
import android.view.KeyEvent
import android.view.MotionEvent
import android.view.View
import android.view.Window
import com.jamesncl.dev.flutter_embed_unity_android.Constants.Companion.logTag
import com.unity3d.player.IUnityPlayerLifecycleEvents
import com.unity3d.player.MultiWindowSupport
import com.unity3d.player.UnityPlayer
import io.flutter.Log
import io.flutter.plugin.platform.PlatformView


class UnityPlayerCustom(activity: Activity) :
    UnityPlayer(activity) {

    // IUnityPlayerLifecycleEvents
    override fun onUnityPlayerUnloaded() {
        Log.d(logTag, "UnityPlayerCustom onUnityPlayerUnloaded")
    }

    // IUnityPlayerLifecycleEvents
    // Callback before Unity player process is killed
    override fun onUnityPlayerQuitted() {
        Log.d(logTag, "UnityPlayerCustom onUnityPlayerQuitted")
    }

    // This ensures the layout will be correct.
    override fun onConfigurationChanged(newConfig: Configuration?) {
        super.onConfigurationChanged(newConfig)
        Log.d(logTag, "UnityPlayerCustom onConfigurationChanged")
        configurationChanged(newConfig)
    }

    // Notify Unity of the focus change.
    override fun onWindowFocusChanged(hasFocus: Boolean) {
        super.onWindowFocusChanged(hasFocus)
        Log.d(logTag, "UnityPlayerCustom onWindowFocusChanged")
        windowFocusChanged(hasFocus)
    }


//    override fun onTouchEvent(event: MotionEvent): Boolean {
//        return onTouchEvent(event)
//    }
//
//    override fun onGenericMotionEvent(event: MotionEvent): Boolean {
//        return onGenericMotionEvent(event)
//    }


}
