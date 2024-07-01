package com.learntoflutter.flutter_embed_unity_android.unity

import androidx.lifecycle.Lifecycle
import androidx.lifecycle.LifecycleEventObserver
import androidx.lifecycle.LifecycleOwner
import com.learntoflutter.flutter_embed_unity_android.constants.FlutterEmbedConstants.Companion.logTag
import io.flutter.Log


// Sometimes (not always) when the Activity is resumed, Unity appears to be frozen.
// There must be something internal in UnityPlayer which does this?
// So, add a lifecycle observer so we can resume Unity.
class ResumeUnityOnActivityResume : LifecycleEventObserver {
    override fun onStateChanged(source: LifecycleOwner, event: Lifecycle.Event) {
        //Log.d(logTag, "Detected lifecycle change $event")

        if (event == Lifecycle.Event.ON_RESUME) {
            Log.d(logTag, "Activity resumed, resuming Unity")
            // For some reason, we need to pause first, and then resume. Not sure why.
            UnityPlayerSingleton.getInstance()?.pause()
            UnityPlayerSingleton.getInstance()?.resume()
        }
    }
}
