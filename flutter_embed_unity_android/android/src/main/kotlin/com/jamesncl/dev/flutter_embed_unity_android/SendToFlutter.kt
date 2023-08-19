package com.jamesncl.dev.flutter_embed_unity_android

import androidx.annotation.Keep
import com.jamesncl.dev.flutter_embed_unity_android.FlutterEmbedConstants.Companion.logTag
import com.jamesncl.dev.flutter_embed_unity_android.FlutterEmbedConstants.Companion.methodNameSendToFlutter
import io.flutter.Log
import io.flutter.plugin.common.MethodChannel
import org.json.JSONObject

/**
 * DO NOT change the name of this class, it's package location or function names: they are
 * referenced in C# Unity scripts (<unity project>/Assets/FlutterEmbed/SendToFlutter/SendToFlutter.cs)
 * using reflection, so changing names or location will break people's projects
 */

// IMPORTANT: Do not remove @Keep annotations, they tell the minifier not to remove or rename
// these elements during compilation so that refection from Unity C# does not break on release build
@Keep
class SendToFlutter {
    companion object {

        var methodChannel: MethodChannel? = null

        // IMPORTANT: Do not remove @Keep annotations, they tell the minifier not to remove or rename
        // these elements during compilation so that refection from Unity C# does not break on release build
        @Keep
        fun sendToFlutter(data: String) {
            Log.d(logTag, "Android received message from Unity")
            methodChannel.let { methodChannel ->
                if(methodChannel != null) {
                    methodChannel.invokeMethod(methodNameSendToFlutter, data)
                }
                else {
                    Log.e(logTag, "Couldn't send message from Android to Flutter: method channel not registered")
                }
            }
        }
    }
}