package com.jamesncl.dev.flutter_embed_unity_android.messaging

import com.jamesncl.dev.flutter_embed_unity_android.constants.FlutterEmbedConstants.Companion.logTag
import com.jamesncl.dev.flutter_embed_unity_android.constants.FlutterEmbedConstants.Companion.methodNameOrientationChanged
import com.jamesncl.dev.flutter_embed_unity_android.constants.FlutterEmbedConstants.Companion.methodNamePauseUnity
import com.jamesncl.dev.flutter_embed_unity_android.constants.FlutterEmbedConstants.Companion.methodNameResumeUnity
import com.jamesncl.dev.flutter_embed_unity_android.constants.FlutterEmbedConstants.Companion.methodNameSendToUnity
import com.jamesncl.dev.flutter_embed_unity_android.view.PlatformViewRegistry
import com.unity3d.player.UnityPlayer
import io.flutter.Log
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class SendToUnity(private val platformViewRegistry: PlatformViewRegistry): MethodChannel.MethodCallHandler {

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        Log.i(logTag, call.method)

        when (call.method) {
            methodNameSendToUnity -> {
                val gameObjectMethodNameData = (call.arguments as List<*>).filterIsInstance<String>()
                UnityPlayer.UnitySendMessage(
                    gameObjectMethodNameData[0], // Unity game object name
                    gameObjectMethodNameData[1], // Game object method name
                    gameObjectMethodNameData[2]) // Data
            }
            methodNameOrientationChanged -> {
                platformViewRegistry.activePlatformView?.orientationChanged()
            }
            methodNamePauseUnity -> {
                platformViewRegistry.activePlatformView?.pause()
            }
            methodNameResumeUnity -> {
                platformViewRegistry.activePlatformView?.resume()
            }
            else -> {
                result.notImplemented()
            }
        }
    }
}