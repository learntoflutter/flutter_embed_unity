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
        let view = UnityView(
            frame: frame,
            viewIdentifier: viewId,
            arguments: args,
            binaryMessenger: messenger)
        
        viewStack.pushView(view)
        
        return view
    }
}
