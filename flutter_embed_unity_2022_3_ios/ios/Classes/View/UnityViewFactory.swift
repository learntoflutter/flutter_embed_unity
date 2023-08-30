import Flutter
import Foundation

class UnityViewFactory : NSObject, FlutterPlatformViewFactory {
    
    private var messenger: FlutterBinaryMessenger
    private let viewStack = UnityViewStack()

    init(messenger: FlutterBinaryMessenger) {
        self.messenger = messenger
        super.init()
    }

    func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?) -> FlutterPlatformView {
        // In order to detect when the platform view is dismissed
        // (so we can detatch unity from the view and possibly
        // reattach to another view lower down in the stack)
        // we need a UIViewController (these are responsible for
        // handling the lifecycle of UIViews). So, nest UnityView
        // inside a UnityViewController, give that to our custom
        // PlatformView which will return the controller's view
        // to Flutter for display
        let unityViewController = UnityViewController(frame)
        let unityPlatformView = UnityPlatformView(unityViewController)
        // Push it onto the stack so we can handle multiple views
        viewStack.pushView(unityViewController)
        return unityPlatformView
    }
}
