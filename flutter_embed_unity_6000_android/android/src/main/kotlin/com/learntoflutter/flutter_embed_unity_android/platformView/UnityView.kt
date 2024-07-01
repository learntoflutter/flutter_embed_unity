package com.learntoflutter.flutter_embed_unity_android.platformView

import android.content.Context
import android.graphics.Color
import android.view.View
import android.widget.FrameLayout
import com.learntoflutter.flutter_embed_unity_android.constants.FlutterEmbedConstants.Companion.logTag
import com.learntoflutter.flutter_embed_unity_android.unity.UnityPlayerSingleton
import io.flutter.Log
import io.flutter.plugin.platform.PlatformView


class UnityView(viewFactoryContext: Context) : PlatformView, IUnityViewStackable {

    // UnityPlayerCustom extends UnityPlayer, which is itself a View. So in theory we could
    // just use UnityPlayerCustom as the view returned from this PlatformView. However there
    // is a problem:
    //
    // - The view returned by PlatformView must be the same context which is passed to the
    //   PlatformViewFactory onCreate method, otherwise we get this warning:
    //   "Unexpected platform view context for view ID 0; some functionality may not work correctly.
    //   When constructing a platform view in the factory, ensure that the view returned from
    //   PlatformViewFactory#create returns the provided context from getContext()"
    // - The unityEngineSingleton is created using the activity returned from the flutter
    //   binding. This is not the same context, so adding the unityEngineSingleton directly
    //   results in the warning above
    //
    // The solution used here is to use an intermediate View (a FrameLayout) which sits between
    // the PlatformView and UnityPlayerCustom. Then we can construct the FrameLayout using the
    // context from the view factory, and add the UnityPlayer to that
    private val baseView: FrameLayout = FrameLayout(viewFactoryContext)

    override var onDispose: (() -> Unit)? = null

    override fun attachUnity(unityPlayerSingleton: UnityPlayerSingleton) {
        baseView.addView(unityPlayerSingleton)
        Log.i(logTag, "Attached Unity to view")
    }

    override fun detachUnity() {
        if(baseView.childCount > 0) {
            baseView.removeViewAt(0)
            Log.i(logTag, "Detached Unity from view")
        }
        else {
            // This might happen (but probably not desirable) if a view lower down
            // on the stack is being disposed
            Log.w(logTag, "Detached called on view, but couldn't find Unity")
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
        Log.d(logTag, "UnityPlatformView onFlutterViewAttached")
    }

    // PlatformView
    override fun onFlutterViewDetached() {
        Log.d(logTag, "UnityPlayerCustom onFlutterViewDetached")
        UnityPlayerSingleton.getInstance()?.pause()
        super.onFlutterViewDetached()
    }

    // PlatformView
    override fun dispose() {
        Log.d(logTag, "UnityPlatformView dispose")
        onDispose?.invoke()
    }
}