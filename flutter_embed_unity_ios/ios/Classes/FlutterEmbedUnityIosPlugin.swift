import Flutter
import UIKit

public class FlutterEmbedUnityIosPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "com.jamesncl.dev/flutter_embed_unity", binaryMessenger: registrar.messenger())
    let instance = FlutterEmbedUnityIosPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "canLaunch":
      result(true)
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
