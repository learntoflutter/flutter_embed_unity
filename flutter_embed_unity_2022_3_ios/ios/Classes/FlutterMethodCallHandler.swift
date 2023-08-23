import Flutter

class FlutterMethodCallHandler {
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
            switch call.method {
            case FlutterEmbedConstants.methodNameSendToUnity:
                let gameObjectMethodNameData = call.arguments as! [String]
                if(UnityPlayerCustom.isInitialised) {
                    UnityPlayerCustom.getInstance().sendMessageToGO(
                        withName: gameObjectMethodNameData[0],
                        functionName: gameObjectMethodNameData[2],
                        message: gameObjectMethodNameData[3])
                    result(true)
                }
                else {
                    debugPrint("Dropped message to Unity: Unity is not loaded yet")
                    result(false)
                }
            default:
              result(FlutterMethodNotImplemented)
            }
    }
}
