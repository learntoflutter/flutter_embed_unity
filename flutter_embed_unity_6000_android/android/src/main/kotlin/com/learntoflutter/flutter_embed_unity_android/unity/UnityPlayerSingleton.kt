package com.learntoflutter.flutter_embed_unity_android.unity

import android.annotation.SuppressLint
import android.app.Activity
import android.view.InputDevice
import android.view.MotionEvent
import android.view.View
import com.learntoflutter.flutter_embed_unity_android.constants.FlutterEmbedConstants.Companion.logTag
import com.unity3d.player.UnityPlayerForActivityOrService
import io.flutter.Log


@SuppressLint("ViewConstructor")
class UnityPlayerSingleton private constructor (activity: Activity) : UnityPlayerForActivityOrService(activity) {
    companion object {
        // We must use a singleton UnityPlayer, because it was never designed to be
        // reused in multiple views. Calling unityPlayer.destroy() will kill the
        // whole process the FlutterActivity runs in. The workaround is to only
        // create UnityPlayer once, and keep it alive when the view is disposed
        // so it can be reattach onto the next view. I think it's okay to suppress
        // warning about static field leak because the UnityPlayer must be kept
        // alive while the app is running
        @SuppressLint("StaticFieldLeak")
        private var singleton: UnityPlayerSingleton? = null

        // The UnityPlayer requires a reference to the activity it is running in
        // when creating it. For Flutter, this means the main Flutter activity.
        // This should be set by the plugin onAttachedToActivity()
        @SuppressLint("StaticFieldLeak")
        var flutterActivity: Activity? = null

        fun getOrCreateInstance() : UnityPlayerSingleton? {
            singleton.let{ singleton ->
                if(singleton != null) {
                    return singleton
                }
                else {
                    flutterActivity.let { flutterActivity ->
                        if(flutterActivity != null) {
                            // UnityPlayerSingleton expects to be passed a context which is an Activity.
                            // UnityPlayer will crash during resume() if it isn't (NullPointerException: Attempt
                            // to invoke virtual method
                            // 'android.content.ContentResolver android.content.Context.getContentResolver()'
                            // on a null object reference)
                            val player = UnityPlayerSingleton(flutterActivity)

                            // This is to work around issue when using Unity AR features
                            // See comments on IUnityPlayerActivity for explanation
                            if(flutterActivity is IFakeUnityPlayerActivity) {
                                flutterActivity.setmUnityPlayer(player)
                            }
                            else {
                                // This is optional: if the user isn't using AR or anything else
                                // which triggers Unity to access mUnityPlayer in the Activity,
                                // this workaround isn't needed, so just continue if not
                                // IFakeUnityPlayerActivity
                            }

                            this.singleton = player
                            return player
                        }
                        else {
                            Log.e(logTag, "Error creating UnityPlatformView: an activity is not available. " +
                                    "Make sure that a UnityPlatformView is only requested after the plugin has " +
                                    "attached to the activity (see FlutterEmbedUnityAndroidPlugin.onAttachedToActivity)")
                            return null
                        }
                    }
                }
            }
        }

        // should only be called after getOrCreateInstance!
        fun getInstance(): UnityPlayerSingleton? {
            return singleton
        }
    }

    // Overriding kill() was an experiment to try to resolve app closing / crashing when
    // player.destroy() is called. It didn't work. The problem is that calling player.destroy() also
    // kills the process it is running in (the entire app, or just the activity if the activity
    // uses a separate process as specified by android:process in AndroidManifest.xml, see
    // https://developer.android.com/guide/topics/manifest/activity-element#proc)
    // So, the idea was to override the kill() function to do nothing. This works, however
    // the next time UnityPlayer is created, you then get an exception:
    //
    // JNI DETECTED ERROR IN APPLICATION: JNI NewGlobalRef called with pending exception
    // java.lang.RuntimeException: PlayAssetDeliveryUnityWrapper.init() should be called only once.
    // Use getInstance() instead.
    // F/android_exampl(31048): java_vm_ext.cc:577]   at com.unity3d.player.PlayAssetDeliveryUnityWrapper
    // com.unity3d.player.PlayAssetDeliveryUnityWrapper.init(android.content.Context)
    //
    // See also: https://forum.unity.com/threads/unityplayer-on-android-using-single-process.847555/
    // https://stackoverflow.com/questions/23467994/errors-managing-the-unityplayer-lifecycle-in-a-native-android-application
    // https://stackoverflow.com/questions/36718387/how-to-keep-android-app-running-and-quit-unity-activity
    // https://forum.unity.com/threads/how-to-restart-unity-player-android.567790/
    //
    // So, abandoned this hack in favour of using a singleton UnityPlayer which is never destroyed

//    override fun kill() {
//        Process.killProcess(Process.myPid())
//    }
}
