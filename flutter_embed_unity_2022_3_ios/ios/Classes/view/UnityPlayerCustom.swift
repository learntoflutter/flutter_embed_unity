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
            let bundlePath = Bundle.main.bundlePath.appending(frameworkPath)
            let unityBundle = Bundle.init(path: bundlePath)!
            let unityFramework = unityBundle.principalClass!.getInstance()!
            unityFramework.setDataBundleId(dataBundleId)
            unityFramework.runEmbedded(
                withArgc: CommandLine.argc,
                argv: CommandLine.unsafeArgv,
                appLaunchOpts: nil
            )
            self.unityFramework = unityFramework
            return unityFramework
        }
    }
}
