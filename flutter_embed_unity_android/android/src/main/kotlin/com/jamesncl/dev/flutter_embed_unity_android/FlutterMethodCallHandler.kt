package com.jamesncl.dev.flutter_embed_unity_android

import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class FlutterMethodCallHandler: MethodChannel.MethodCallHandler {
    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        if (call.method == "canLaunch") {
            result.success(true)
        } else {
            result.notImplemented()
        }
    }
}