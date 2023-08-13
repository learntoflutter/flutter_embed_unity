package com.jamesncl.dev.flutter_embed_unity_android

import android.util.Log
import com.jamesncl.dev.flutter_embed_unity_android.Constants.Companion.logTag
import com.jamesncl.dev.flutter_embed_unity_android.Constants.Companion.methodChannelIdentifier
import com.jamesncl.dev.flutter_embed_unity_android.Constants.Companion.uniqueViewIdentifier
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodChannel

/**
 * The plugin implements ActivityAware so that it can respond to Android activity-related events.
 * See https://docs.flutter.dev/release/breaking-changes/plugin-api-migration#uiactivity-plugin
 * and https://api.flutter.dev/javadoc/io/flutter/embedding/engine/plugins/activity/ActivityAware.html
 * */
class FlutterEmbedUnityAndroidPlugin: FlutterPlugin, ActivityAware {
  /// The MethodChannel that will the communication between Flutter and native Android
  private lateinit var channel : MethodChannel
//  private lateinit var pluginBinding: FlutterPlugin.FlutterPluginBinding
  private val unityPlayerManager = UnityPlayerManager()
  private val methodCallHandler: FlutterMethodCallHandler = FlutterMethodCallHandler()

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    Log.d(logTag, "onAttachedToEngine")
//    pluginBinding = flutterPluginBinding
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, methodChannelIdentifier)
    channel.setMethodCallHandler(methodCallHandler)

    // Register a view factory
    // On the Flutter side, when we create a PlatformView with our unique identifier:
    //
    // AndroidView(
    //    viewType: Constants.uniqueViewIdentifier,
    // )
    //
    // the UnityViewFactory will be invoked to create a UnityPlatformView:
    flutterPluginBinding
      .platformViewRegistry
      .registerViewFactory(
        uniqueViewIdentifier,
        UnityViewFactory(unityPlayerManager)
      )
  }


  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    Log.d(logTag, "onDetachedFromEngine")
    channel.setMethodCallHandler(null)
  }

  // ActivityAware
  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    Log.d(logTag, "onAttachedToActivity")
    unityPlayerManager.activityAttached(binding.activity)
  }

  // ActivityAware
  override fun onDetachedFromActivityForConfigChanges() {
    Log.d(logTag, "onDetachedFromActivityForConfigChanges")
    unityPlayerManager.activityDetached()
  }

  // ActivityAware
  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    Log.d(logTag, "onReattachedToActivityForConfigChanges")
    unityPlayerManager.activityAttached(binding.activity)
  }

  // ActivityAware
  override fun onDetachedFromActivity() {
    Log.d(logTag, "onDetachedFromActivity")
    unityPlayerManager.activityDetached()
  }
}
