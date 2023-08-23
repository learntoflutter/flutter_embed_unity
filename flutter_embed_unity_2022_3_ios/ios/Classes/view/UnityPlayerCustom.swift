//
//  UnityPlayerCustom.swift
//  flutter_embed_unity_ios
//
//  Created by James Allen on 23/08/2023.
//

import Foundation
import UnityFramework

class UnityPlayerCustom {
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
            
            // This is needed to allow touch events to work
            // I have no idea why touches do not work, what this does and
            // why it resolves the problem: got this hack from
            // https://github.com/juicycleff/flutter-unity-view-widget/blob/master/ios/Classes/UnityPlayerUtils.swift
            // appController window level is UIWindow.Level.normal (rawValue: 0),
            // so this makes it -1
            unityFramework.appController()?.window?.windowLevel = UIWindow.Level(UIWindow.Level.normal.rawValue - 1)
            
            self.unityFramework = unityFramework
            return unityFramework
        }
    }
}
