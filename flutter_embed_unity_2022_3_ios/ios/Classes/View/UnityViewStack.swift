//
//  UnityViewStack.swift
//  flutter_embed_unity_ios
//
//  Created by James Allen on 28/08/2023.
//

import Foundation

/**
 * This class is responsible for making sure that Unity is only ever attached to the
 * topmost view in the stack. Unity cannot be attached to more than one view, so there
 * should only ever be one EmbedUnity widget on a Flutter screen - however we still
 * need to account for the fact that when pushing a new Flutter route / screen onto
 * the Navigator stack, both screens are still alive and so we can end up with more
 * than one PlatformView at the same time (but only the top one will be visible)
 *  See https://developer.apple.com/documentation/uikit/uiviewcontroller
 *  See https://developer.apple.com/documentation/uikit/uiview
 *  See https://developer.apple.com/documentation/swift/using-key-value-observing-in-swift
 */
class UnityViewStack: NSObject {
    // This could possibly be implemented as a Queue / Stack collection, but it may
    // be possible that a view which isn't the topmost one gets disposed (eg during
    // a Navigator.of(contect).pushAndRemoveUntil ?) so safest just to use a list
    private var viewStack = [UnityViewController]()
    
    func pushView(_ viewController: UnityViewController) {
        // Unity can only be attached to one view at a time. Therefore, check
        // if there are any other active views, and detatch Unity from them first
        viewStack.forEach { existingViewController in
            existingViewController.detachUnity()
        }
        
        // attach Unity to the new view
        let unityPlayerSingleton = UnityPlayerSingleton.getInstance()
        viewController.attachUnity(unityPlayerSingleton)
        debugPrint("Attached Unity to new view")
        
        // When the view is dismissed, we need to detatch Unity from the
        // view and, if there are any views left in the stack, reattach
        // it to the topmost view
        viewController.onDismissed = {
            self.popView(viewController)
        }
        
        // Resume unity
        unityPlayerSingleton.pause(false)
        
        // Add view to the stack
        viewStack.append(viewController)
    }

    private func popView(_ viewController: UnityViewController) {
        // Detatch Unity from the view
        viewController.detachUnity()
        // Remove from the stack
        viewStack = viewStack.filter { $0 != viewController }
        debugPrint("Detached Unity from popped view")

        let unityPlayerSingleton = UnityPlayerSingleton.getInstance()
        
        if(!viewStack.isEmpty) {
            // If there are any remaining views in the stack, attach Unity to the last view to be
            // added to the stack
            viewStack.last?.attachUnity(unityPlayerSingleton)
            debugPrint("Reattached Unity to existing view")
            // I don't know why, but when Unity is reattached to an existing view
            // we need to pause AND resume (even though Unity was never paused?):
            unityPlayerSingleton.pause(true)
            unityPlayerSingleton.pause(false)
        }
        else {
            // No more Unity views, so pause
            unityPlayerSingleton.pause(true)
        }
    }
}
