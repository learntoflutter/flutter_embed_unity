package com.jamesncl.dev.flutter_embed_unity_android

import android.annotation.SuppressLint
import android.content.Context
import android.util.Log
import android.view.InputDevice
import android.view.MotionEvent
import com.unity3d.player.UnityPlayer


class CustomUnityPlayer(context: Context) : UnityPlayer(context) {
    @SuppressLint("ClickableViewAccessibility")
    override fun onTouchEvent(motionEvent: MotionEvent): Boolean {
        Log.d(this.toString(), "onTouchEvent")
        motionEvent.source = InputDevice.SOURCE_TOUCHSCREEN
        return super.onTouchEvent(motionEvent)
    }
}
