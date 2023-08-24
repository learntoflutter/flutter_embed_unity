package com.jamesncl.dev.flutter_embed_unity_android.view

import android.app.Activity
import android.content.Context
import android.graphics.Color
import android.os.Build
import android.view.View
import android.view.WindowInsets
import android.view.WindowManager
import android.widget.FrameLayout
import com.jamesncl.dev.flutter_embed_unity_android.constants.FlutterEmbedConstants.Companion.logTag
import com.jamesncl.dev.flutter_embed_unity_android.unity.UnityEngineSingleton
import io.flutter.Log
import io.flutter.plugin.platform.PlatformView
import io.flutter.util.ViewUtils.getActivity


class UnityPlatformView(private val unityEngineSingleton: UnityEngineSingleton, viewFactoryContext: Context) : PlatformView {

    // UnityPlayerCustom extends UnityPlayer, which is itself a View. So in theory we could
    // just use UnityPlayerCustom as the view returned from this PlatformView. However there
    // is a problem:
    //
    // - The view returned by PlatformView must be the same context which is passed to the
    //   PlatformViewFactory onCreate method, otherwise we get this warning:
    //   "Unexpected platform view context for view ID 0; some functionality may not work correctly.
    //   When constructing a platform view in the factory, ensure that the view returned from
    //   PlatformViewFactory#create returns the provided context from getContext()"
    // - The UnityPlayerCustom is created using the activity returned from the flutter
    //   binding. This is not the same context, so adding the UnityPlayerCustom directly
    //   results in the warning above
    //
    // The solution used here is to use an intermediate View (a FrameLayout) which sits between
    // the PlatformView and UnityPlayerCustom. Then we can construct the FrameLayout using the
    // context from the view factory, and add the UnityPlayer to that
    private val baseView: FrameLayout = FrameLayout(viewFactoryContext)

    init {
        // Setting background colour might help when things go wrong: if users report seeing
        // green, they are seeing the base view
        baseView.setBackgroundColor(Color.GREEN)
        baseView.addView(unityEngineSingleton)

        // It's important to call windowFocusChanged, otherwise unity will not start
        // (not sure why - UnityPlayer is undocumented)
        unityEngineSingleton.windowFocusChanged(unityEngineSingleton.requestFocus())
        unityEngineSingleton.resume()  // UnityPlayer

        // Unity on Android always forces hiding the status bar.
        // See https://forum.unity.com/threads/status-bar-always-hidden-on-android.362779
        // See https://github.com/Over17/UnityShowAndroidStatusBar
        // This is a workaround to show the status bar:
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            unityEngineSingleton.windowInsetsController?.show(WindowInsets.Type.statusBars())
        }
        else {
            @Suppress("DEPRECATION")
            getActivity(unityEngineSingleton.context)?.window?.clearFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN);
        }
    }

    // PlatformView
    override fun getView(): View {
        // The view returned by PlatformView must be created from the same context
        // which is passed to the PlatformViewFactory onCreate method
        return baseView
    }

    // PlatformView
    override fun onFlutterViewAttached(flutterView: View) {
        super.onFlutterViewAttached(flutterView)
        Log.d(logTag, "UnityPlatformView onFlutterViewAttached, resuming Unity")
    }

    // PlatformView
    override fun onFlutterViewDetached() {
        Log.d(logTag, "UnityPlayerCustom onFlutterViewDetached, pausing Unity")
        unityEngineSingleton.pause()  // UnityPlayer
        super.onFlutterViewDetached()
    }

    // PlatformView
    override fun dispose() {
        Log.d(logTag, "UnityPlatformView dispose, pausing Unity and detaching from view")
        baseView.removeView(unityEngineSingleton)
//        unityPlayerCustom.removeAllViews()
        unityEngineSingleton.pause()
//        unityPlayerCustom.unload()
        // DO NOT call unityPlayerCustom.destroy(). UnityPlayer will also kill the process it is
        // running in, because it was designed to be run within it's own activity launched in it's
        // own process. We can't make FlutterActivity launch in it's own process, because it's the
        // main (and usually the only) activity.
    }
}