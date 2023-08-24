library flutter_embed_unity;

import 'package:flutter_embed_unity_platform_interface/flutter_embed_unity_platform_interface.dart';

export 'src/embed_unity.dart' show EmbedUnity;
export 'package:flutter_embed_unity/flutter_embed_unity.dart' show sendToUnity, pauseUnity, resumeUnity;

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