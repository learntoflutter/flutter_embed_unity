import Flutter
import Foundation
import UnityFramework

class UnityView : NSObject, FlutterPlatformView, IUnityViewStackable {
    
    private var unityRootView: UIView? = nil
    private let baseView: UIView = UIView()
    
    init(
        frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?,
        binaryMessenger messenger: FlutterBinaryMessenger?
    ) {
        // This might help debugging: if the user reports seeing
        // green, they are seeing the base view:
        baseView.backgroundColor = UIColor.green
        super.init()
    }
    
    func attachUnity(_ unityPlayerSingleton: UnityFramework) {
        baseView.addSubview(unityPlayerSingleton.appController().rootView)
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
