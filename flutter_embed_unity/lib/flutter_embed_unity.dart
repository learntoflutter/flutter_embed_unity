library flutter_embed_unity;

import 'package:flutter_embed_unity_platform_interface/flutter_embed_unity_platform_interface.dart';

export 'src/flutter_embed.dart' show FlutterEmbed;
export 'package:flutter_embed_unity/flutter_embed_unity.dart' show sendToUnity;

FlutterEmbedUnityPlatform get _platform => FlutterEmbedUnityPlatform.instance;

void sendToUnity(String gameObjectName, String methodName, String data) {
  _platform.sendToUnity(gameObjectName, methodName, data);
}

void pauseUnity() {
  _platform.pauseUnity();
}

void resumeUnity() {
  _platform.resumeUnity();
}