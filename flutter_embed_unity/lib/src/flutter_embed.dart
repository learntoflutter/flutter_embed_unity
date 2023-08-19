import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_embed_unity/flutter_embed_unity.dart';
import 'package:flutter_embed_unity/src/orientation_change_notifier.dart';
import 'package:flutter_embed_unity_platform_interface/flutter_embed_constants.dart';

class FlutterEmbed extends StatefulWidget {

  const FlutterEmbed({super.key});

  @override
  State<FlutterEmbed> createState() => _FlutterEmbedState();
}

class _FlutterEmbedState extends State<FlutterEmbed> {

  @override
  void dispose() {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      // TODO: Handle disposal on ios?
      //controller?._channel?.invokeMethod('dispose');
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return OrientationChangeNotifier(
          child: AndroidView(
            viewType: FlutterEmbedConstants.uniqueIdentifier,
            onPlatformViewCreated: (int id) {
              debugPrint('FlutterEmbed: onPlatformViewCreated($id)');
            },
          ),
        );
      case TargetPlatform.iOS:
        // TODO: is orientation changed also needed for ios?
        return UiKitView(
          viewType: FlutterEmbedConstants.uniqueIdentifier,
          onPlatformViewCreated: (int id) {
            debugPrint('FlutterEmbed: onPlatformViewCreated($id)');
          },
        );
      default:
        throw UnsupportedError('Unsupported platform: $defaultTargetPlatform');
    }
  }
}
