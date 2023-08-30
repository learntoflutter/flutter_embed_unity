import Flutter
import Foundation
import UnityFramework

class UnityView : NSObject, FlutterPlatformView {
    
    private var unityRootView: UIView? = nil
    private let baseView: UIView
    
    init(
        frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?,
        binaryMessenger messenger: FlutterBinaryMessenger?
    ) {
        baseView = UIView(frame: frame)
        // This might help debugging: if the user reports seeing
        // green, they are seeing the base view:
        baseView.backgroundColor = UIColor.green
        super.init()
    }
    
    func attachUnity(_ unityPlayerSingleton: UnityFramework) {
        let unityRootView = unityPlayerSingleton.appController().rootView!
        unityRootView.frame = baseView.bounds
        unityRootView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        baseView.addSubview(unityRootView)
    }
    
    func detachUnity() {
        baseView.subviews.forEach { subview in
            subview.removeFromSuperview()
        }
    }

    func view() -> UIView {
        return baseView
    }
}
