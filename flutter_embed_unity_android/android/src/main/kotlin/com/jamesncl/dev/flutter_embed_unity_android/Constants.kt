package com.jamesncl.dev.flutter_embed_unity_android

class Constants {
    companion object {
        const val logTag = "FlutterEmbedUnity"
        // The unique identifier used by the PlatformViewFactory to identify the Unity Player view.
        const val uniqueViewIdentifier = "com.jamesncl.dev/embed_unity";
        // Name for the method channel for communication between Flutter and native
        const val methodChannelIdentifier = "com.jamesncl.dev/flutter_embed_unity";
    }
}