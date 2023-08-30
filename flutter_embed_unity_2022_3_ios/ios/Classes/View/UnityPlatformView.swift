//
//  UnityPlatformView.swift
//  flutter_embed_unity_ios
//
//  Created by James Allen on 30/08/2023.
//

import Foundation
import Flutter

class UnityPlatformView : NSObject, FlutterPlatformView {
    
    private let unityViewController: UIViewController
    
    init(_ unityViewController: UIViewController) {
        self.unityViewController = unityViewController
    }
    
    func view() -> UIView {
        return unityViewController.view
    }
}
