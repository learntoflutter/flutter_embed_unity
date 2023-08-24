import Foundation
import UnityFramework

class UnityEngineSingleton{
    private static let dataBundleId: String = "com.unity3d.framework"
    private static let frameworkPath: String = "/Frameworks/UnityFramework.framework"
    
    // We must use a singleton Unity instance, because it was never designed to be
    // reused in multiple views. The workaround is to only
    // create Unity once, and keep it alive when the view is disposed
    // so it can be reattach onto the next view.
    static private var unityFramework : UnityFramework?
    
    static var isInitialised: Bool {
        get {
            return self.unityFramework != nil
        }
    }
    
    static func getInstance() -> UnityFramework {
        if let unityFramework = self.unityFramework {
            return unityFramework
        }
        else {
            // Load the Unity engine
            let bundlePath = Bundle.main.bundlePath.appending(frameworkPath)
            let unityBundle = Bundle.init(path: bundlePath)!
            let unityFramework = unityBundle.principalClass!.getInstance()!
            unityFramework.setDataBundleId(dataBundleId)
            unityFramework.runEmbedded(
                withArgc: CommandLine.argc,
                argv: CommandLine.unsafeArgv,
                appLaunchOpts: nil
            )
            
            // Got this hack from
            // https://github.com/juicycleff/flutter-unity-view-widget/blob/master/ios/Classes/UnityPlayerUtils.swift
            // Without this, touches do not register in Flutter. Not sure why - I think the Unity
            // view is set to a level above Flutter and captures all touches?
            // There are 3 defined levels:
            // UIWindow.Level.normal (rawValue: 0.0)
            // UIWindow.Level.statusBar (rawValue: 1000.0)
            // UIWindow.Level.alert (rawValue: 2000.0)
            // appController window level is UIWindow.Level.normal (rawValue: 0.0),
            // so setting to -1 should put it to a level underneath normal?
            unityFramework.appController()?.window?.windowLevel = UIWindow.Level(-1)

            self.unityFramework = unityFramework
            return unityFramework
        }
    }
}
