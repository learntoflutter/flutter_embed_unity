

import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'method_channel_flutter_embed_unity.dart';

/// The interface that implementations of flutter_embed_unity must implement.
///
/// Platform implementations should extend this class rather than implement it as `flutter_embed_unity`
/// does not consider newly added methods to be breaking changes. Extending this class
/// (using `extends`) ensures that the subclass will get the default implementation, while
/// platform implementations that `implements` this interface will be broken by newly added
/// [FlutterEmbedUnityPlatform] methods.
abstract class FlutterEmbedUnityPlatform extends PlatformInterface {
  /// Constructs a FlutterEmbedUnityPlatform.
  FlutterEmbedUnityPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterEmbedUnityPlatform _instance = MethodChannelFlutterEmbedUnity();

  /// The default instance of [FlutterEmbedUnityPlatform] to use,
  /// defaults to [FlutterEmbedUnityPlatformUnsupported].
  static FlutterEmbedUnityPlatform get instance => _instance;

  /// Platform-specific plugins should set this with their own platform-specific
  /// class that extends [FlutterEmbedUnityPlatform] when they register themselves.
  static set instance(FlutterEmbedUnityPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  void sendToUnity(String gameObjectName, String methodName, String data) {
    throw UnimplementedError('sendToUnity() has not been implemented.');
  }

  void orientationChanged() {
    throw UnimplementedError('orientationChanged() has not been implemented.');
  }

  void pauseUnity() {
    throw UnimplementedError('pauseUnity() has not been implemented.');
  }

  void resumeUnity() {
    throw UnimplementedError('resumeUnity() has not been implemented.');
  }
}