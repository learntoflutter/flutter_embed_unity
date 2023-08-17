package com.jamesncl.dev.flutter_embed_unity_android

import android.content.Context
import android.content.pm.ActivityInfo
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

//
// - The view returned by PlatformView must be the same context which is passed to the
//   PlatformViewFactory onCreate method, otherwise we get this warning:
//   "Unexpected platform view context for view ID 0; some functionality may not work correctly.
//   When constructing a platform view in the factory, ensure that the view returned from
//   PlatformViewFactory#create returns the provided context from getContext()"
//
// The solution used here to resolve these conflicting requirements is to use an intermediate
// View (a FrameLayout) which sits between the PlatformView and UnityPlayerCustom. Then we can construct
// the FrameLayout using the context from the view factory, and add the UnityPlayer which is
// constructed from the activity (which is retrieved from the context)
class UnityPlatformView(private val unityPlayerCustom: UnityPlayerCustom, viewFactoryContext: Context) : PlatformView, IPlatformViewControl {

    private val baseView: FrameLayout = FrameLayout(viewFactoryContext)

    init {
        baseView.addView(unityPlayerCustom)
        // It's important to call windowFocusChanged, otherwise unity will not start
        // (not sure why - UnityPlayer is undocumented)
        unityPlayerCustom.windowFocusChanged(unityPlayerCustom.requestFocus())
    }

    override fun orientationChanged() {
        Log.d(logTag, "UnityPlatformView orientationChanged: pausing and resuming")
        // For some unknown reason, when orientation changes, Unity rendering appears to
        // freeze (not always, but usually). The underlying UnityPlayer is still active and
        // still responds to messages, so it is purely a UI thing. Presumably a bug, although
        // using UnityPlayer to render in a View is not supported anyway (see
        // https://docs.unity3d.com/Manual/UnityasaLibrary-Android.html)
        // As a workaround, pause and resume the player seems to work
        unityPlayerCustom.pause()
        unityPlayerCustom.resume()
    }

    // PlatformView
    override fun getView(): View {
        Log.d(logTag, "UnityPlatformView getView")
        // The view returned by PlatformView must be created from the same context
        // which is passed to the PlatformViewFactory onCreate method
        return baseView
    }

    // PlatformView
    override fun onFlutterViewAttached(flutterView: View) {
        super.onFlutterViewAttached(flutterView)
        Log.d(logTag, "UnityPlatformView onFlutterViewAttached, resuming Unity")
        unityPlayerCustom.resume()  // UnityPlayer
    }

    // PlatformView
    override fun onFlutterViewDetached() {
        Log.d(logTag, "UnityPlayerCustom onFlutterViewDetached, pausing Unity")
        unityPlayerCustom.pause()  // UnityPlayer
        super.onFlutterViewDetached()
    }

    // PlatformView
    override fun dispose() {
        Log.d(logTag, "UnityPlatformView dispose, pausing Unity and detaching from view")
        baseView.removeView(unityPlayerCustom)
        unityPlayerCustom.removeAllViews()
        unityPlayerCustom.pause()
        // DO NOT call unityPlayerCustom.destroy(). UnityPlayer will also kill the process it is
        // running in, because it was designed to be run within it's own activity launched in it's
        // own process. We can't make FlutterActivity launch in it's own process, because it's the
        // main (and usually the only) activity.
    }
}