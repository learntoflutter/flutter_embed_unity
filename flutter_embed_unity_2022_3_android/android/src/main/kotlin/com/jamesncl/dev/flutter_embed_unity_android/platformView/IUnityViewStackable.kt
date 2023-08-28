package com.jamesncl.dev.flutter_embed_unity_android.platformView

import com.jamesncl.dev.flutter_embed_unity_android.unity.UnityPlayerSingleton

interface IUnityViewStackable {
    fun attachUnity(unityPlayerSingleton: UnityPlayerSingleton)
    fun detachUnity()
    var onDispose: (() -> Unit)?
}