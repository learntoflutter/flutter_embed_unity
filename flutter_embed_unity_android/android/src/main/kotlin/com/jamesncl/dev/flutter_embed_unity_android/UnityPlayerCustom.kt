package com.jamesncl.dev.flutter_embed_unity_android

import android.annotation.SuppressLint
import android.content.Context
import android.util.Log
import android.view.InputDevice
import android.view.MotionEvent
import com.jamesncl.dev.flutter_embed_unity_android.Constants.Companion.logTag
import com.unity3d.player.UnityPlayer


class UnityPlayerCustom(context: Context) : UnityPlayer(context) {
    @SuppressLint("ClickableViewAccessibility")
    override fun onTouchEvent(motionEvent: MotionEvent): Boolean {
        Log.d(logTag, "onTouchEvent")
        motionEvent.source = InputDevice.SOURCE_TOUCHSCREEN
        return super.onTouchEvent(motionEvent)
    }
}
