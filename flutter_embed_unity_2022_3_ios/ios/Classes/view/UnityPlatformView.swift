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
        self.unityAppController = UnityPlayerCustom.getInstance().appController()
        super.init()
    }

    func view() -> UIView {
        return unityAppController.rootView
    }
}
