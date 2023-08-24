import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_embed_unity/src/orientation_change_notifier.dart';
import 'package:flutter_embed_unity/src/pause_on_view_dispose_notifier.dart';
import 'package:flutter_embed_unity_platform_interface/flutter_embed_constants.dart';

class EmbedUnity extends StatefulWidget {

  final Function(String)? onMessageFromUnity;

  const EmbedUnity({this.onMessageFromUnity, super.key});

  @override
  State<EmbedUnity> createState() => _EmbedUnityState();
}

class _EmbedUnityState extends State<EmbedUnity> {

  static const MethodChannel _channel = MethodChannel(FlutterEmbedConstants.uniqueIdentifier);

  @override
  void initState() {
    _channel.setMethodCallHandler(_methodCallHandler);
    super.initState();
  }

  Future<dynamic> _methodCallHandler(MethodCall call) async {
    if(call.method == FlutterEmbedConstants.methodNameSendToFlutter) {
      widget.onMessageFromUnity?.call(call.arguments.toString());
    }
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
        // For iOS only, pause Unity when view is disposed,
        // because I couldn't figure out how to detect view disposal on native side
        // TODO: is there a way to pause Unity on view disposal on native side?
        return PauseOnViewDisposeNotifier(
          child: UiKitView(
            viewType: FlutterEmbedConstants.uniqueIdentifier,
            onPlatformViewCreated: (int id) {
              debugPrint('FlutterEmbed: onPlatformViewCreated($id)');
            },
          ),
        );
      default:
        throw UnsupportedError('Unsupported platform: $defaultTargetPlatform');
    }
  }
}
