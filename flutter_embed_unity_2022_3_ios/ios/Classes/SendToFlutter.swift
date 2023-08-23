//
//  SendToFlutter.swift
//  flutter_embed_unity_ios
//
//  Created by James Allen on 23/08/2023.
//

import Foundation


@objc class SendToFlutter: NSObject {

    @objc static func test(_ key: String) {
        debugPrint("Swifty swifty swift " + key)
    }
}
