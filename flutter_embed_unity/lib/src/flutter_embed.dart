import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'constants.dart';

class FlutterEmbed extends StatefulWidget {

  const FlutterEmbed({super.key});

  @override
  State<FlutterEmbed> createState() => _FlutterEmbedState();
}

class _FlutterEmbedState extends State<FlutterEmbed> {

  @override
  void dispose() {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      // TODO: Handle disposal on ios
      //controller?._channel?.invokeMethod('dispose');
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return AndroidView(
          viewType: Constants.uniqueViewIdentifier,
          onPlatformViewCreated: (int id) {
            debugPrint('FlutterEmbed: onPlatformViewCreated($id)');
          },
        );
      case TargetPlatform.iOS:
        return UiKitView(
          viewType: Constants.uniqueViewIdentifier,
          onPlatformViewCreated: (int id) {
            debugPrint('FlutterEmbed: onPlatformViewCreated($id)');
          },
        );
      default:
        throw UnsupportedError('Unsupported platform: $defaultTargetPlatform');
    }
  }
}
