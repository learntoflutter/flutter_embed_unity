import Flutter
import Foundation
import UnityFramework

class UnityPlatformView : NSObject, FlutterPlatformView {
    
    private let unityAppController: UnityAppController
//    private let _view: UIView
    
    
    init(
        frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?,
        binaryMessenger messenger: FlutterBinaryMessenger?
    ) {
        self.unityAppController = UnityPlayerCustom.getInstance().appController()
//        _view = UIView()
        super.init()
    }

    func view() -> UIView {
        return unityAppController.rootView
    }
    
    

//    func createNativeView(view _view: UIView){
//        _view.backgroundColor = UIColor.blue
//        let nativeLabel = UILabel()
//        nativeLabel.text = "Native text from iOS"
//        nativeLabel.textColor = UIColor.white
//        nativeLabel.textAlignment = .center
//        nativeLabel.frame = CGRect(x: 0, y: 0, width: 180, height: 48.0)
//        _view.addSubview(nativeLabel)
//    }
}
