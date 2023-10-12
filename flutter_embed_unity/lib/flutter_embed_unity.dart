library flutter_embed_unity;

import 'package:flutter_embed_unity_platform_interface/flutter_embed_unity_platform_interface.dart';

export 'src/embed_unity.dart' show EmbedUnity;
export 'src/embed_unity_preferences.dart' show EmbedUnityPreferences, MessageFromUnityListeningBehaviour;
export 'package:flutter_embed_unity/flutter_embed_unity.dart' show sendToUnity, pauseUnity, resumeUnity;

FlutterEmbedUnityPlatform get _platform => FlutterEmbedUnityPlatform.instance;

/// Send [data] to a public MonoBehaviour method named [methodName] attached to a
/// Unity game object named [gameObjectName] in the active scene.
///
/// The Unity method must be public and accept a single [String] parameter.
void sendToUnity(String gameObjectName, String methodName, String data) {
  _platform.sendToUnity(gameObjectName, methodName, data);
}

/// Pause time in Unity.
///
/// Unity will remain loaded in memory and still be able to accept messages.
void pauseUnity() {
  _platform.pauseUnity();
}

/// Resume time in Unity.
void resumeUnity() {
  _platform.resumeUnity();
}
