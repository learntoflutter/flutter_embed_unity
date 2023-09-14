package com.learntoflutter.flutter_embed_unity_android.unity;

/**
 * Unity code assumes that UnityPlayer is only ever run inside
 * UnityPlayerActivity.java (you can find the source for this
 * class in unityLibrary/src/main/java/com/unity3d/player),
 * Unfortunately, native Unity code therefore assumes it can
 * find a property called mUnityPlayer in the Activity which
 * UnityPlayer runs inside. If it doesn't find this, it will
 * crash (usually when attempting to launch XR features). To
 * work around this issue, we need to add a property named
 * mUnityPlayer in the Flutter main activity. At runtime, the
 * plugin will check if your MainActivity implements this
 * interface: if it does, it will pass an instance of
 * UnityPlayer to be stored in mUnityPlayer. If your Unity
 * export uses XR, your app's Flutter activity MUST implement
 * this interface and MUST store the given object in a member
 * variable called mUnityPlayer.
 */
public interface IFakeUnityPlayerActivity {
    void setmUnityPlayer(Object mUnityPlayer);
}
