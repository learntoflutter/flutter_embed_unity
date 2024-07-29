package com.learntoflutter.flutter_embed_unity_android.platformView

import android.view.WindowManager
import com.learntoflutter.flutter_embed_unity_android.constants.FlutterEmbedConstants.Companion.logTag
import com.learntoflutter.flutter_embed_unity_android.unity.UnityPlayerSingleton
import io.flutter.Log
import io.flutter.util.ViewUtils

/**
 * This class is responsible for making sure that Unity is only ever attached to the
 * topmost view in the stack. Unity cannot be attached to more than one view, so there
 * should only ever be one EmbedUnity widget on a Flutter screen - however we still
 * need to account for the fact that when pushing a new Flutter route / screen onto
 * the Navigator stack, both screens are still alive and so we can end up with more
 * than one PlatformView at the same time (but only the top one will be visible)
 */
class UnityViewStack {
    // This could possibly be implemented as a Queue / Stack collection, but it may
    // be possible that a view which isn't the topmost one gets disposed (eg during
    // a Navigator.of(contect).pushAndRemoveUntil ?) so safest just to use a list
    private val viewStack = ArrayList<IUnityViewStackable>()

    fun pushView(view: IUnityViewStackable) {
        // Unity can only be attached to one view at a time. Therefore, check
        // if there are any other active views, and detatch Unity from them first
        for(existingView in viewStack) {
            existingView.detachUnity()
        }

        // Then attach Unity to the new view
        val unityPlayerSingleton = UnityPlayerSingleton.getOrCreateInstance()
        if(unityPlayerSingleton != null) {
            view.attachUnity(unityPlayerSingleton)

            // It's important to call windowFocusChanged, otherwise unity will not start
            // (not sure why - UnityPlayer is undocumented)
            unityPlayerSingleton.windowFocusChanged(unityPlayerSingleton.getFrameLayout().requestFocus())
            // I don't know why, but when Unity is detached from an existing view and
            // added to a new view, we need to pause AND resume instead of just resume:
            unityPlayerSingleton.pause()
            unityPlayerSingleton.resume()

            // Unity on Android always forces hiding the status bar.
            // See https://forum.unity.com/threads/status-bar-always-hidden-on-android.362779
            // See https://github.com/Over17/UnityShowAndroidStatusBar
            // This is a workaround to show the status bar:
            // TODO: FLAG_FULLSCREEN is deprecated, what to replace it with?
            // unityEngineSingleton.windowInsetsController?.show(WindowInsets.Type.statusBars()) doesn't seem to work...
            ViewUtils.getActivity(unityPlayerSingleton.context)?.window?.clearFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN)

            Log.i(logTag, "Attached Unity to new view")
        }
        else {
            Log.e(logTag, "Unity hasn't been attached to the view because UnityPlayer " +
                    "couldn't be created")
        }

        // Register for onDispose event so we can pop the stack when this view is disposed
        view.onDispose = {
            popView(view)
        }

        // Add view to the stack
        viewStack.add(view)
    }

    private fun popView(view: IUnityViewStackable) {
        // Detatch Unity from the view
        view.detachUnity()

        // Remove from the stack
        viewStack.remove(view)

        if(viewStack.isNotEmpty()) {
            // If there are any remaining views in the stack, attach Unity to the last view to be
            // added to the stack
            val unityPlayerSingleton = UnityPlayerSingleton.getInstance()
            if(unityPlayerSingleton != null) {
                viewStack.last().attachUnity(unityPlayerSingleton)
                Log.i(logTag, "Reattached Unity to existing view")
                // I don't know why, but when Unity is reattached to an existing view
                // we need to pause AND resume (even though Unity was never paused?):
//                unityPlayerSingleton.windowFocusChanged(unityPlayerSingleton.getFrameLayout().requestFocus())
                unityPlayerSingleton.pause()
                unityPlayerSingleton.resume()
            }
            else {
                Log.e(logTag, "Unity hasn't been reattached to the last view in the " +
                        "stack because UnityPlayer was null")
            }
        }
        else {
            // No more Unity views, so pause
            Log.i(logTag, "No more EmbedUnity views in stack, pausing Unity")
            UnityPlayerSingleton.getInstance()?.pause()
            // DO NOT call unityPlayerCustom.destroy(). UnityPlayer will also kill the process it is
            // running in, because it was designed to be run within it's own activity launched in it's
            // own process. We can't make FlutterActivity launch in it's own process, because it's the
            // main (and usually the only) activity.
        }
    }
}
