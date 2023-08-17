library flutter_embed_unity;

import 'package:flutter_embed_unity_platform_interface/flutter_embed_unity_platform_interface.dart';

export 'src/flutter_embed.dart' show FlutterEmbed;

FlutterEmbedUnityPlatform get _platform => FlutterEmbedUnityPlatform.instance;

void sendToUnity(String gameObjectName, String methodName, String data) {
  _platform.sendToUnity(gameObjectName, methodName, data);
}

void orientationChanged() {
  _platform.orientationChanged();
}