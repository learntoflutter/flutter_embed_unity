//
//  IUnityViewStack.swift
//  flutter_embed_unity_ios
//
//  Created by James Allen on 28/08/2023.
//

import Foundation
import UnityFramework

protocol IUnityViewStackable {
    func detachUnity()
    func attachUnity(_ unityPlayerSingleton: UnityFramework)
}
