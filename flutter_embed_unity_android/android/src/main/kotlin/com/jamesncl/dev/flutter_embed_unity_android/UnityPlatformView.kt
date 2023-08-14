package com.jamesncl.dev.flutter_embed_unity_android

import android.content.Context
import android.graphics.Color
import android.view.View
import android.widget.FrameLayout
import com.jamesncl.dev.flutter_embed_unity_android.Constants.Companion.logTag
import io.flutter.Log
import io.flutter.plugin.platform.PlatformView
import io.flutter.util.ViewUtils.getActivity

// UnityPlayerCustom extends UnityPlayer, which is itself a View. So in theory we could
// just use UnityPlayerCustom as the view returned from this PlatformView. However there
// a couple of problems:
//
// - UnityPlayer expects to be passed a context which is an Activity. It will crash during
//   resume() if it isn't (NullPointerException: Attempt to invoke virtual method
//   'android.content.ContentResolver android.content.Context.getContentResolver()' on a null
//   object reference)
//
// - The view returned by PlatformView must be the same context which is passed to the
//   PlatformViewFactory onCreate method, otherwise we get this warning:
//   "Unexpected platform view context for view ID 0; some functionality may not work correctly.
//   When constructing a platform view in the factory, ensure that the view returned from
//   PlatformViewFactory#create returns the provided context from getContext()"
//
// The solution used here to resolve these conflicting requirements is to use an intermediate
// View (a FrameLayout) which sits between the PlatformView and UnityView. Then we can construct
// the FrameLayout using the context from the view factory, and add the UnityPlayer which is
// constructed from the activity (which is retrieved from the context)
class UnityPlatformView(viewFactoryContext: Context) : PlatformView {

    private val baseView: FrameLayout = FrameLayout(viewFactoryContext)
    private var player: UnityPlayerCustom? = null

    init {
        val activity = getActivity(viewFactoryContext)
        if (activity != null) {
            val player = UnityPlayerCustom(activity)
            baseView.addView(player)
            // It's important to call windowFocusChanged, otherwise unity will not start
            // (not sure why - UnityPlayer is undocumented)
            player.windowFocusChanged(player.requestFocus())
            this.player = player
        }
        else {
            Log.e(logTag,"Error constructing player: could not get Activity from view factory context")
        }
    }

    // PlatformView
    override fun getView(): View {
        // The view returned by PlatformView must be the same context which is passed to the
        // PlatformViewFactory onCreate method
        return baseView
    }

    // PlatformView
    override fun onFlutterViewAttached(flutterView: View) {
        super.onFlutterViewAttached(flutterView)
        Log.d(logTag, "UnityPlayerCustom onFlutterViewAttached, resuming Unity")
        player?.resume()  // UnityPlayer
    }

    // PlatformView
    override fun onFlutterViewDetached() {
        Log.d(logTag, "UnityPlayerCustom onFlutterViewDetached, pausing Unity")
        player?.pause()  // UnityPlayer
        super.onFlutterViewDetached()
    }

    // PlatformView
    override fun dispose() {
        Log.d(logTag, "UnityPlayerCustom dispose, destroying Unity")
        player?.destroy()  // UnityPlayer
    }
}