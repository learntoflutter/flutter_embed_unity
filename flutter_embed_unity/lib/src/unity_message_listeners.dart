import 'package:flutter/services.dart';
import 'package:flutter_embed_unity/src/unity_message_listener.dart';
import 'package:flutter_embed_unity_platform_interface/flutter_embed_constants.dart';

class UnityMessageListeners {

  UnityMessageListeners._internal() {
    _channel.setMethodCallHandler(_methodCallHandler);
  }

  static final instance = UnityMessageListeners._internal();

  final MethodChannel _channel = const MethodChannel(FlutterEmbedConstants.uniqueIdentifier);
  final List<UnityMessageListener> _listeners = [];

  void addListener(UnityMessageListener listener) {
    _listeners.add(listener);
  }

  void removeListener(UnityMessageListener listener) {
    _listeners.remove(listener);
  }

  Future<dynamic> _methodCallHandler(MethodCall call) async {
    if(call.method == FlutterEmbedConstants.methodNameSendToFlutter) {
      for(var listener in _listeners) {
        listener.onMessageFromUnity(call.arguments.toString());
      }
    }
  }
}