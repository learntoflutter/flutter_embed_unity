package com.jamesncl.dev.flutter_embed_unity_android

import android.app.Activity
import android.content.pm.ActivityInfo
import android.util.Log

class UnityPlayerManager {
    private var currentActivity: Activity? = null
    private var initialActivityRequestedOrientation = ActivityInfo.SCREEN_ORIENTATION_PORTRAIT
    var player: UnityPlayerCustom? = null

    fun resetScreenOrientation() {
        Log.d(Constants.logTag, "resetScreenOrientation")
        currentActivity?.requestedOrientation = initialActivityRequestedOrientation
    }

    fun activityDetached() {
        currentActivity = null
        player?.destroy()
        player = null
    }

    fun activityAttached(activity: Activity) {
        initialActivityRequestedOrientation = activity.requestedOrientation
        currentActivity = activity

        try{
            player = UnityPlayerCustom(activity)
            Log.d(Constants.logTag, "created player: $player")
        }
        catch(e: NoClassDefFoundError) {
            Log.e(
                Constants.logTag, "NoClassDefFoundError error creating Unity player: ${e.message}. This is " +
                    "usually because the unityLibrary export has not been correctly linked to your " +
                    "project. Check all the steps in the plugin's readme, paying particular attention " +
                    "to the modifications needed to your build.gradle and settings.gradle")
            throw e
        }
    }
}