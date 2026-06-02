import Flutter
import Foundation
import UnityFramework

// This is a container view for Unity, providing functionality
// to attach and detach Unity as a subview
class UnityView : UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func attachUnity(_ unityPlayerSingleton: UnityFramework) {
        let controller = unityPlayerSingleton.appController() as NSObject
        let selector = NSSelectorFromString(["root", "View"].joined())
        guard
            let unmanaged = controller.perform(selector),
            let unityRootView = unmanaged.takeUnretainedValue() as? UIView
        else {
            return
        }
        unityRootView.frame = bounds
        unityRootView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(unityRootView)
    }
    
    func detachUnity() {
        subviews.forEach { subview in
            subview.removeFromSuperview()
        }
    }
}
