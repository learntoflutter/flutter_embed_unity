library flutter_embed_unity;

import 'package:flutter_embed_unity_platform_interface/flutter_embed_unity_platform_interface.dart';

export 'src/flutter_embed.dart' show FlutterEmbed;

FlutterEmbedUnityPlatform get _platform => FlutterEmbedUnityPlatform.instance;

Future<bool> canLaunch(String url) async {
  return await _platform.canLaunch(url);
}