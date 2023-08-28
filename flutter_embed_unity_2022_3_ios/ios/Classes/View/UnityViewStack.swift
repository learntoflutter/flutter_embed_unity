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
 */
class UnityViewStack: NSObject {
    // This could possibly be implemented as a Queue / Stack collection, but it may
    // be possible that a view which isn't the topmost one gets disposed (eg during
    // a Navigator.of(contect).pushAndRemoveUntil ?) so safest just to use a list
    private var viewStack = [IUnityViewStackable]()
    
    private var isObservingUnityControllerIsDisposing = false
    @objc private var unityViewController: UIViewController? = nil
    private var             isBeingDismissedObservation: NSKeyValueObservation? = nil
    
    func pushView(view: IUnityViewStackable) {
        // Unity can only be attached to one view at a time. Therefore, check
        // if there are any other active views, and detatch Unity from them first
        viewStack.forEach { existingView in
            existingView.detachUnity()
        }

        
        let unityPlayerSingleton = UnityPlayerSingleton.getInstance()
        // If this is the first time unity player has been created,
        // start observing the view controller's dismissed
        if(!isObservingUnityControllerIsDisposing) {
            unityViewController = unityPlayerSingleton.appController().rootViewController
            isBeingDismissedObservation = observe(\.unityViewController?.isBeingDismissed) { object, change in
                if(change.newValue != nil && change.newValue!!) {
                    debugPrint("Unity view is being dismissed")
                    self.popView(view)
                }
            }
            isObservingUnityControllerIsDisposing = true
        }
        
        // Then attach Unity to the new view
        view.attachUnity(unityPlayerSingleton)
        
        
        debugPrint("Attached Unity to new view")
        
        // Resume unity
        UnityPlayerSingleton.getInstance().pause(false)
        
        

        // Register for onDispose event so we can pop the stack when this view is disposed
//        view.onDispose = {
//            popView(view)
//        }

        // Add view to the stack
        viewStack.append(view)
    }

    private func popView(_ view: IUnityViewStackable) {
        
        got up to here
//        // Detatch Unity from the view
//        view.detachUnity()
//
//        // Remove from the stack
//        viewStack.remove(view)
//
//        if(viewStack.isNotEmpty()) {
//            // If there are any remaining views in the stack, attach Unity to the last view to be
//            // added to the stack
//            val unityPlayerSingleton = UnityPlayerSingleton.getInstance()
//            if(unityPlayerSingleton != null) {
//                viewStack.last().attachUnity(unityPlayerSingleton)
//                Log.i(logTag, "Reattached Unity to existing view")
//                // I don't know why, but when Unity is reattached to an existing view
//                // we need to pause AND resume (even though Unity was never paused?):
////                unityPlayerSingleton.windowFocusChanged(unityPlayerSingleton.requestFocus())
//                unityPlayerSingleton.pause()
//                unityPlayerSingleton.resume()
//            }
//            else {
//                Log.e(logTag, "Unity hasn't been reattached to the last view in the " +
//                        "stack because UnityPlayer was null")
//            }
//        }
//        else {
//            // No more Unity views, so pause
//            UnityPlayerSingleton.getInstance()?.pause()
//            // DO NOT call unityPlayerCustom.destroy(). UnityPlayer will also kill the process it is
//            // running in, because it was designed to be run within it's own activity launched in it's
//            // own process. We can't make FlutterActivity launch in it's own process, because it's the
//            // main (and usually the only) activity.
//        }
    }

}
