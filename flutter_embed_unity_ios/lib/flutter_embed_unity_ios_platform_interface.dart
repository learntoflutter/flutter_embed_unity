import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_embed_unity_platform_interface/flutter_embed_unity_platform_interface.dart';

const MethodChannel _channel = MethodChannel('com.jamesncl.dev/flutter_embed_unity');

/// An implementation of [FlutterEmbedUnityPlatform] for Android.
class FlutterEmbedUnityIos extends FlutterEmbedUnityPlatform {
  /// Registers this class as the default instance of [FlutterEmbedUnityPlatform].
  static void registerWith() {
    FlutterEmbedUnityPlatform.instance = FlutterEmbedUnityIos();
  }

  @override
  Future<bool> canLaunch(String url) async {
    return _channel.invokeMethod<bool>(
      'canLaunch',
      <String, Object>{'url': url},
    ).then((bool? value) => value ?? false);
  }
}