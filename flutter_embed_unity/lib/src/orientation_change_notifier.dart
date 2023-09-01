import 'package:flutter/material.dart';
import 'package:flutter_embed_unity_platform_interface/flutter_embed_unity_platform_interface.dart';


/// Sends a notification to the platform implementation when the orientation
/// changes.
///
/// This is used to work around a problem with the current Android
/// implementation: when orientation changes, the UnityPlayer needs to be
/// paused / resumed to prevent freezing of Unity rendering. This appears to
/// be a 'bug' in the UnityPlayer, which was never designed to run inside a sub
/// view (it was designed only to run in its own Activity). I couldn't find a
/// way to detect orientation on the Android side (for some reason,
/// View.onConfigurationChanged doesn't seem to be called on the sub view).
/// Also note that we MUST include orientation in android:configChanges (see
/// the plugin README for more details) to prevent the [FlutterActivity] being
/// destroyed, which will cause Unity to quit the app.
/// So as a workaround, detect orientation change in Flutter and send a message
class OrientationChangeNotifier extends StatefulWidget {

  final Widget child;

  const OrientationChangeNotifier({required this.child, super.key});

  @override
  State<OrientationChangeNotifier> createState() => _OrientationChangeNotifierState();
}

class _OrientationChangeNotifierState extends State<OrientationChangeNotifier> {

  Orientation? _previousOrientation;

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
        builder: (context, orientation) {
          if(_previousOrientation == null) {
            _previousOrientation = orientation;
          }
          else if(_previousOrientation != orientation) {
            FlutterEmbedUnityPlatform.instance.orientationChanged();
            _previousOrientation = orientation;
          }
          return widget.child;
        }
    );
  }
}