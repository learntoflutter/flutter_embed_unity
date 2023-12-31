import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_embed_unity/src/unity_message_listener.dart';
import 'package:flutter_embed_unity/src/unity_message_listeners.dart';
import 'package:flutter_embed_unity_platform_interface/flutter_embed_constants.dart';

/// Embed Unity into your Flutter app and listen for messages from your Unity scripts.
///
/// Unity will be rendered within the bounds of the widget.
/// Only 1 instance of the widget should be shown on a screen.
class EmbedUnity extends StatefulWidget {
  /// Listen to messages sent from Unity via `SendToFlutter.cs`.
  final Function(String)? onMessageFromUnity;

  const EmbedUnity({this.onMessageFromUnity, super.key});

  @override
  State<EmbedUnity> createState() => _EmbedUnityState();
}

class _EmbedUnityState extends State<EmbedUnity> implements UnityMessageListener {
  @override
  void initState() {
    UnityMessageListeners.instance.addListener(this);
    super.initState();
  }

  @override
  void dispose() {
    UnityMessageListeners.instance.removeListener(this);
    super.dispose();
  }

  @override
  void onMessageFromUnity(String data) {
    widget.onMessageFromUnity?.call(data);
  }

  @override
  Widget build(BuildContext context) {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return AndroidView(
          viewType: FlutterEmbedConstants.uniqueIdentifier,
          onPlatformViewCreated: (int id) {
            debugPrint('FlutterEmbed: onPlatformViewCreated($id)');
          },
        );
      case TargetPlatform.iOS:
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
