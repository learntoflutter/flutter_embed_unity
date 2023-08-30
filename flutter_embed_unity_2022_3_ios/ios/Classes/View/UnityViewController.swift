//
//  UnityViewController.swift
//  flutter_embed_unity_ios
//
//  Created by James Allen on 30/08/2023.
//

import Foundation

class UnityViewController : UIViewController {
    
    var unityView: UnityView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        unityView = UnityView(
            frame: frame,
            viewIdentifier: viewId,
            arguments: args,
            binaryMessenger: messenger)
        
        
    }
}
