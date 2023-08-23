import Flutter
import UIKit

public class FlutterEmbedUnityIosPlugin: NSObject, FlutterPlugin {
    
    private let flutterMethodCallHandler = FlutterMethodCallHandler()
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        // Register the method call handler
        let channel = FlutterMethodChannel(
            name: FlutterEmbedConstants.uniqueIdentifier,
            binaryMessenger: registrar.messenger())
        let instance = FlutterEmbedUnityIosPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
        
        // Register with SendToFlutter so it can send messages back to Flutter
        SendToFlutter.methodChannel = channel
        
        // Register a view factory
        // On the Flutter side, when we create a PlatformView with our unique identifier:
        // UiKitView(
        //    viewType: Constants.uniqueViewIdentifier,
        // )
        // the UnityViewFactory will be invoked to create a UnityPlatformView:
        let platformViewFactory = UnityViewFactory(messenger: registrar.messenger())
        registrar.register(
            platformViewFactory,
            withId: FlutterEmbedConstants.uniqueIdentifier,
            gestureRecognizersBlockingPolicy: FlutterPlatformViewGestureRecognizersBlockingPolicyWaitUntilTouchesEnded)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        flutterMethodCallHandler.handle(call, result: result)
    }
}
