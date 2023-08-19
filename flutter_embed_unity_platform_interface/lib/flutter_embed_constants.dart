class FlutterEmbedConstants {
  // A unique identifier used by the PlatformViewFactory to identify the Unity Player view,
  // and as the unique name of the method channel used for communication between Flutter and native
  // Should be the same value in flutter_embed_unity_android/android/src/main/kotlin/com/jamesncl/dev/flutter_embed_unity_android/flutter_embed_constants.kt
  static const uniqueIdentifier = "com.jamesncl.dev/flutter_embed_unity";
  static const methodNameSendToUnity = "sendToUnity";
  static const methodNameSendToFlutter = "sendToFlutter";
  static const methodNameOrientationChanged = "orientationChanged";
}