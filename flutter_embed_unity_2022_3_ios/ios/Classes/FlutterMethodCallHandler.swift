import Flutter

class FlutterMethodCallHandler {
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
            switch call.method {
            case FlutterEmbedConstants.methodNameSendToUnity:
                let gameObjectMethodNameData = call.arguments as! [String]
                if(UnityPlayerCustom.isInitialised) {
                    UnityPlayerCustom.getInstance().sendMessageToGO(
                        withName: gameObjectMethodNameData[0],
                        functionName: gameObjectMethodNameData[1],
                        message: gameObjectMethodNameData[2])
                    result(true)
                }
                else {
                    debugPrint("Dropped message to Unity: Unity is not loaded yet")
                    result(false)
                }
            case FlutterEmbedConstants.methodNamePauseUnity:
                if(UnityPlayerCustom.isInitialised) {
                    UnityPlayerCustom.getInstance().pause(true)
                    result(true)
                }
                else {
                    debugPrint("Didn't pause Unity: Unity is not loaded yet")
                    result(false)
                }
            case FlutterEmbedConstants.methodNameResumeUnity:
                if(UnityPlayerCustom.isInitialised) {
                    UnityPlayerCustom.getInstance().pause(false)
                    result(true)
                }
                else {
                    debugPrint("Didn't resume Unity: Unity is not loaded yet")
                    result(false)
                }
            default:
              result(FlutterMethodNotImplemented)
            }
    }
}
