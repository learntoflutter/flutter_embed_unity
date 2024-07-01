package com.learntoflutter.flutter_embed_unity_android.platformView

import android.view.InputDevice
import android.view.MotionEvent
import android.content.Context
import android.widget.FrameLayout
import io.flutter.Log
import android.view.View
import com.learntoflutter.flutter_embed_unity_android.constants.FlutterEmbedConstants.Companion.logTag
import com.learntoflutter.flutter_embed_unity_android.unity.UnityPlayerSingleton


public class CustomFrameLayout : FrameLayout  {

    constructor(context: Context) : super(context)

    // TODO: Is this still functional if not on UnityPLayer's own FrameLayout?
    override fun onWindowVisibilityChanged(visibility: Int) {
        Log.d(logTag, "CustomFrameLayout onWindowVisibilityChanged $visibility")

        if(visibility == View.VISIBLE) {
            // For some unknown reason, if window visibility changes quickly from View.VISIBLE
            // to View.GONE and back to View.VISIBLE, Unity UI appears to freeze.
            // This happens, for example, on orientation change, flutter hot reload, and
            // occasionally on widget rebuild if there is a significant change to the widget
            // tree (you can usually see this as a brief flicker of the widget).
            // The underlying UnityPlayer is still active and still responds to messages even
            // though it appears frozen, so it is purely a UI thing. Presumably a bug in Unity.
            // However using UnityPlayer to render in a View like this is not supported so
            // unlikely to be fixed by Unity
            // (see https://docs.unity3d.com/Manual/UnityasaLibrary-Android.html)
            // As a workaround, pause and resume the player unfreezes the UI
            Log.d(logTag, "UnityPlayerSingleton became visible, so pausing and resuming Unity")

            UnityPlayerSingleton.getInstance()?.pause();
            UnityPlayerSingleton.getInstance()?.resume();
           // pause()
           // resume()
        }

        super.onWindowVisibilityChanged(visibility)
    }

    // This is required for Unity's New Input System to receive touch events
    override fun dispatchTouchEvent(motionEvent: MotionEvent): Boolean {
        motionEvent.source = InputDevice.SOURCE_TOUCHSCREEN

         // true for Flutter Virtual Display, false for Hybrid composition.
        if (motionEvent.deviceId == 0) {        
            /* 
              Flutter creates a touchscreen motion event with deviceId 0. (https://github.com/flutter/flutter/blob/34b454f42dd6f8721dfe43fc7de5d215705b5e52/packages/flutter/lib/src/services/platform_views.dart#L639)
              Unity's new Input System package does not detect these touches, copy the motion event to change the immutable deviceId.
            */
            val modifiedEvent = motionEvent.copy(deviceId = -1)
            motionEvent.recycle()
            return super.onTouchEvent(modifiedEvent)
        } else {
            return super.onTouchEvent(motionEvent)
        }
    }

}