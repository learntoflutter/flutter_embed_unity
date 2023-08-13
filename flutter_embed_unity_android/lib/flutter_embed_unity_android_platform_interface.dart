import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_embed_unity_platform_interface/flutter_embed_unity_platform_interface.dart';

const MethodChannel _channel = MethodChannel('com.jamesncl.dev/flutter_embed_unity');

/// An implementation of [FlutterEmbedUnityPlatform] for Android.
class FlutterEmbedUnityAndroid extends FlutterEmbedUnityPlatform {
  /// Registers this class as the default instance of [FlutterEmbedUnityPlatform].
  static void registerWith() {
    FlutterEmbedUnityPlatform.instance = FlutterEmbedUnityAndroid();
  }

  @override
  Future<void> sendToUnity(String gameObjectName, String methodName, String data) async {
    _channel.invokeMethod<bool>(
        'sendToUnity',
        <String>[gameObjectName, methodName, data],
    );
  }
}