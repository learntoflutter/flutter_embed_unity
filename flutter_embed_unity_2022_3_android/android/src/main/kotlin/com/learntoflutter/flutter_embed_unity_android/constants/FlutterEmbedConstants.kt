package com.learntoflutter.flutter_embed_unity_android.constants

class FlutterEmbedConstants {
    companion object {
        const val logTag = "FlutterEmbedLog"
        // A unique identifier used by the PlatformViewFactory to identify the Unity Player view,
        // and as the unique name of the method channel used for communication between Flutter and native
        // Should be the same value in flutter_embed_unity/flutter_embed_unity_platform_interface/lib/flutter_embed_constants.dart
        const val uniqueIdentifier = "com.learntoflutter/flutter_embed_unity"
        const val methodNameSendToUnity = "sendToUnity"
        const val methodNameSendToFlutter = "sendToFlutter"
        const val methodNamePauseUnity = "pauseUnity"
        const val methodNameResumeUnity = "resumeUnity"
    }
}