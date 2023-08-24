import Foundation
import Flutter


// This is called by Unity script to pass messages from Unity to Flutter
// DO NOT change @_cdecl: it is referenced in C# script
// <unity project>/Assets/FlutterEmbed/SendToFlutter/SendToFlutter.cs
// @_cdecl allows C# to call a top level function by the name specified
@_cdecl("FlutterEmbedUnityIos_sendToFlutter")
public func sendToFlutter(_ dataAsUnsafePointer: UnsafePointer<CChar>) {
    let data = String(cString: UnsafePointer<CChar>(dataAsUnsafePointer))
    SendToFlutter.sendToFlutter(data)
}


public class SendToFlutter {
    static var methodChannel: FlutterMethodChannel? = nil
    
    static func sendToFlutter(_ data: String) {
        if let methodChannel = methodChannel {
            methodChannel.invokeMethod(FlutterEmbedConstants.methodNameSendToFlutter, arguments: data)
        }
        else {
            debugPrint("Couldn't send message from Unity to Flutter: method channel hasn't been initialised")
        }
    }
}
