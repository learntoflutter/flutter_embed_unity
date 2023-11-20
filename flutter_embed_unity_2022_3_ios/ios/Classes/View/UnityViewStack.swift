//
//  UnityViewStack.swift
//  flutter_embed_unity_ios
//
//  Created by James Allen on 28/08/2023.
//

import Foundation


// This class is responsible for making sure that Unity is only ever attached to the
// topmost view in the stack. Unity cannot be attached to more than one view, so there
// should only ever be one EmbedUnity widget on a Flutter screen - however we still
// need to account for the fact that when pushing a new Flutter route / screen onto
// the Navigator stack, both screens are still alive and so we can end up with more
// than one PlatformView at the same time (but only the top one will be visible)
// See https://developer.apple.com/documentation/uikit/uiviewcontroller
// See https://developer.apple.com/documentation/uikit/uiview
// See https://developer.apple.com/documentation/swift/using-key-value-observing-in-swift
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
        
        // Add view to the stack
        viewStack.append(viewController)
        NSLog("UnityViewStack: pushed Unity view \(viewController.viewId) onto stack")
        
        
        // ---------------------------------------------
        // TODO: find a simpler way to achieve the below
        // The following isn't ideal. The reason is that I couldn't find an
        // obvious way to reliably detect when the viewController is destroyed.
        // FlutterPlatformView doesn't provide a `dispose` method
        // to override (like the Android equivalent does), classes in Swift
        // don't seem to provide a dispose or dealloc method to override, and
        // I can't find anything useful in UIViewController or UIView to detect
        // being destroyed. There is probably some easy way to do this but I just
        // can't figure it out yet.
        // So instead this is a bit of a workaround using viewDidDisappear
        // on UIViewController, which is called if the view is destroyed, OR
        // also if the view is simply being obscured by another view ontop (eg if a
        // Flutter PageRoute is pushed onto the stack). Therefore the below logic
        // needs to handle both cases:
        
        // If it disappears, it MAY have been destroyed, so remove from stack
        viewController.viewDidDisappear = { viewId in
            NSLog("UnityViewStack: Unity view \(viewController.viewId) disappeared, removing from stack")
            self.popView(viewController)
        }
        
        // However it may reappear if it wasn't destroyed (eg it was obscured underneath
        // another screen, and now has reappeared), in which case push it back onto the stack
        viewController.viewDidAppear = { viewId in
            if !self.viewStack.contains(where: {$0.viewId == viewId}) {
                NSLog("UnityViewStack: View \(viewId) has reappeared, pushing back onto stack")
                self.pushView(viewController)
            }
        }
        // ---------------------------------------------
        
        
        // Resume unity
        unityPlayerSingleton.pause(false)
    }

    private func popView(_ viewController: UnityViewController) {
        // Detatch Unity from the view
        viewController.detachUnity()
        // Remove from the stack
        viewStack = viewStack.filter { $0 != viewController }
        NSLog("Detached Unity from popped view")

        let unityPlayerSingleton = UnityPlayerSingleton.getInstance()
        
        if(!viewStack.isEmpty) {
            // If there are any remaining views in the stack, attach Unity to the last view to be
            // added to the stack
            viewStack.last?.attachUnity(unityPlayerSingleton)
            NSLog("Reattached Unity to existing view")
            // I don't know why, but when Unity is reattached to an existing view
            // we need to pause AND resume (even though Unity was never paused?):
            unityPlayerSingleton.pause(true)
            unityPlayerSingleton.pause(false)
        }
        else {
            // No more Unity views, so pause
            NSLog("No more EmbedUnity widgets in stack, pausing Unity")
            unityPlayerSingleton.pause(true)
        }
    }
}
