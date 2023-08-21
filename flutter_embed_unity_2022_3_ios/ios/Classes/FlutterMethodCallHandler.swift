class FlutterMethodCallHandler {
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case FlutterEmbedConstants.methodNameSendToUnity:
      val gameObjectMethodNameData = (call.arguments as List<*>).filterIsInstance<String>()
                UnityPlayer.UnitySendMessage(
                    gameObjectMethodNameData[0], // Unity game object name
                    gameObjectMethodNameData[1], // Game object method name
                    gameObjectMethodNameData[2]) // Data
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}