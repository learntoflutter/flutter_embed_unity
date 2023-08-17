
import 'dart:async';

import 'package:flutter/services.dart';

import 'flutter_embed_unity_platform_interface.dart';

const MethodChannel _channel = MethodChannel('com.jamesncl.dev/flutter_embed_unity');

/// An implementation of [FlutterEmbedUnityPlatform] that uses method channels.
class MethodChannelFlutterEmbedUnity extends FlutterEmbedUnityPlatform {

  @override
  void sendToUnity(String gameObjectName, String methodName, String data) {
    _channel.invokeMethod(
      "sendToUnity",
      [gameObjectName, methodName, data],
    );
  }

  @override
  void orientationChanged() {
    _channel.invokeMethod(
      "orientationChanged",
    );
  }
}
