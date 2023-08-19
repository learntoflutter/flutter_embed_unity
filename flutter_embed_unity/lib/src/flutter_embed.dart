import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_embed_unity/flutter_embed_unity.dart';
import 'package:flutter_embed_unity/src/orientation_change_notifier.dart';
import 'package:flutter_embed_unity_platform_interface/flutter_embed_constants.dart';

class FlutterEmbed extends StatefulWidget {

  final Function(String)? onMessageFromUnity;

  const FlutterEmbed({this.onMessageFromUnity, super.key});

  @override
  State<FlutterEmbed> createState() => _FlutterEmbedState();
}

class _FlutterEmbedState extends State<FlutterEmbed> {

  static const MethodChannel _channel = MethodChannel(FlutterEmbedConstants.uniqueIdentifier);

  @override
  void initState() {
    _channel.setMethodCallHandler(_methodCallHandler);
    super.initState();
  }

  @override
  void dispose() {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      // TODO: Handle disposal on ios?
      //controller?._channel?.invokeMethod('dispose');
    }
    super.dispose();
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
        // For Android only, we need to notify the platform of orientation change.
        // See OrientationChangeNotifier documentation
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
