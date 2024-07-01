package com.learntoflutter.flutter_embed_unity_android.platformView

import com.learntoflutter.flutter_embed_unity_android.unity.UnityPlayerSingleton

interface IUnityViewStackable {
    fun attachUnity(unityPlayerSingleton: UnityPlayerSingleton)
    fun detachUnity()
    var onDispose: (() -> Unit)?
}