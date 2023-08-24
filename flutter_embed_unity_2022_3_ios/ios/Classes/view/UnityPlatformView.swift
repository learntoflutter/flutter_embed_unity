import Flutter
import Foundation
import UnityFramework

class UnityPlatformView : NSObject, FlutterPlatformView {
    
    private let unityAppController: UnityAppController
    
    init(
        frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?,
        binaryMessenger messenger: FlutterBinaryMessenger?
    ) {
        self.unityAppController = UnityEngineSingleton.getInstance().appController()
        // When the FlutterEmbed widget is disposed, it calls unityPause
        // so that the Unity engine is paused while in the background
        // TODO: is there a way to detect when unityAppController.rootView
        // is dismissed so that we don't have to call unityPause on the Flutter side?
        // Resume Unity:
        UnityEngineSingleton.getInstance().pause(false)
        super.init()
    }

    func view() -> UIView {
        return unityAppController.rootView
    }
}
