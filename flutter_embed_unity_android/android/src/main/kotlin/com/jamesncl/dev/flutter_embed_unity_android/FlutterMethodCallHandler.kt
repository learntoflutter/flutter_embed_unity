package com.jamesncl.dev.flutter_embed_unity_android

import com.jamesncl.dev.flutter_embed_unity_android.FlutterEmbedConstants.Companion.logTag
import com.unity3d.player.UnityPlayer
import io.flutter.Log
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class FlutterMethodCallHandler(private val platformViewRegistry: PlatformViewRegistry): MethodChannel.MethodCallHandler {

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "sendToUnity" -> {
    //            Log.i(logTag, "sendToUnity")
                val gameObjectMethodNameData = (call.arguments as List<*>).filterIsInstance<String>()
                UnityPlayer.UnitySendMessage(
                    gameObjectMethodNameData[0], // Unity game object name
                    gameObjectMethodNameData[1], // Game object method name
                    gameObjectMethodNameData[2]) // Data
            }
            "orientationChanged" -> {
                Log.i(logTag, "orientationChanged")
                platformViewRegistry.activePlatformView?.orientationChanged()
            }
            else -> {
                result.notImplemented()
            }
        }
    }

}