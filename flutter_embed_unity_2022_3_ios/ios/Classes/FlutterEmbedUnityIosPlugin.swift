import Flutter
import UIKit

public class FlutterEmbedUnityIosPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    // Register the method call handler
    let channel = FlutterMethodChannel(name: FlutterEmbedConstants.uniqueIdentifier, binaryMessenger: registrar.messenger())
    let methodCallHandler = FlutterMethodCallHandler()
    registrar.addMethodCallDelegate(methodCallHandler, channel: channel)

    // Register a view factory
    // On the Flutter side, when we create a PlatformView with our unique identifier:
    // UiKitView(
    //    viewType: Constants.uniqueViewIdentifier,
    // )
    // the UnityViewFactory will be invoked to create a UnityPlatformView:
    let platformViewFactory = UnityViewFactory(messenger: registrar.messenger())
    registrar.register(fuwFactory, withId: FlutterEmbedConstants.uniqueIdentifier, gestureRecognizersBlockingPolicy: FlutterPlatformViewGestureRecognizersBlockingPolicyWaitUntilTouchesEnded)
  }
}
