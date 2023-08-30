import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_embed_unity/src/orientation_change_notifier.dart';
import 'package:flutter_embed_unity/src/unity_message_listener.dart';
import 'package:flutter_embed_unity/src/unity_message_listeners.dart';
import 'package:flutter_embed_unity_platform_interface/flutter_embed_constants.dart';


class EmbedUnity extends StatefulWidget {

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
  void onMessageFromUnity(String data ) {
    widget.onMessageFromUnity?.call(data);
  }

  @override
  Widget build(BuildContext context) {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        // For Android only, we need to notify the platform of orientation change
        // because I couldn't figure out how to do it on native side (see
        // OrientationChangeNotifier documentation)
        // TODO: is there a way to detect orientation change on native side?
        return OrientationChangeNotifier(
          child: AndroidView(
            viewType: FlutterEmbedConstants.uniqueIdentifier,
            onPlatformViewCreated: (int id) {
              debugPrint('FlutterEmbed: onPlatformViewCreated($id)');
            },
          ),
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
