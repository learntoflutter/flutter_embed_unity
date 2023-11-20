//
//  UnityViewController.swift
//  flutter_embed_unity_ios
//
//  Created by James Allen on 30/08/2023.
//

import Foundation
import UnityFramework

// The purpose of this class is simply to provide a way to override
// viewDidDisappear, so we can signal to UnityViewStack that UnityView
// is being disposed, so it can detach Unity from the view, and
// possibly reattach to a different view
class UnityViewController : UIViewController {
    
    private var unityView: UnityView
    let viewId: Int64
    var viewDidAppear: ((Int64) -> Void)? = nil
    var viewDidDisappear: ((Int64) -> Void)? = nil
    
    init(_ frame: CGRect, _ viewId: Int64) {
        unityView = UnityView(frame: frame)
        self.viewId = viewId
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        // Return UnityView as this controller's view
        unityView.frame = self.view.bounds
        unityView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.addSubview(unityView)
        super.viewDidLoad()
    }
    
    func attachUnity(_ unityPlayerSingleton: UnityFramework) {
        unityView.attachUnity(unityPlayerSingleton)
    }
    
    func detachUnity() {
        unityView.detachUnity()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // Pass on this event to UnityViewStack
        if let viewDidAppear = viewDidAppear {
            viewDidAppear(viewId)
        }
        super.viewDidAppear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        // Pass on this event to UnityViewStack
        if let viewDidDisappear = viewDidDisappear {
            viewDidDisappear(viewId)
        }
        super.viewDidDisappear(animated)
    }
}
