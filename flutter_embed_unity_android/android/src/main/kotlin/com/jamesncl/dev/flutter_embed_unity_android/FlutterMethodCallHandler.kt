package com.jamesncl.dev.flutter_embed_unity_android

import com.unity3d.player.UnityPlayer
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class FlutterMethodCallHandler: MethodChannel.MethodCallHandler {
    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        if (call.method == "sendToUnity") {
            val gameObjectMethodNameData = (call.arguments as List<*>).filterIsInstance<String>()
            UnityPlayer.UnitySendMessage(
                gameObjectMethodNameData[0], // Unity game object name
                gameObjectMethodNameData[1], // Game object method name
                gameObjectMethodNameData[2]) // Data
        } else {
            result.notImplemented()
        }
    }
}