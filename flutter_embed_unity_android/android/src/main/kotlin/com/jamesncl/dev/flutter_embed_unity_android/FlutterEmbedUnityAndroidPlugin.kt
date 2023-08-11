package com.jamesncl.dev.flutter_embed_unity_android

import android.app.Activity
import android.content.pm.ActivityInfo
import android.util.Log
import android.view.WindowManager
import com.jamesncl.dev.flutter_embed_unity_android.Constants.Companion.LOG_TAG
import com.jamesncl.dev.flutter_embed_unity_android.Constants.Companion.VIEW_TYPE
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
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel

  private lateinit var pluginBinding: FlutterPlugin.FlutterPluginBinding

  private val methodCallHandler = FlutterMethodCallHandler()
  private var currentActivity: Activity? = null
  private var initialActivityRequestedOrientation = ActivityInfo.SCREEN_ORIENTATION_PORTRAIT
  internal var player: CustomUnityPlayer? = null

  companion object {
    val views: MutableList<UnityPlatformView> = mutableListOf()
  }

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    pluginBinding = flutterPluginBinding
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "com.jamesncl.dev/flutter_embed_unity")
    channel.setMethodCallHandler(methodCallHandler)

    Log.d(LOG_TAG, "onAttachedToEngine")

    flutterPluginBinding
      .platformViewRegistry
      .registerViewFactory(
        VIEW_TYPE,
        UnityViewFactory(this)
      )
  }


  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  // ActivityAware
  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    Log.d(LOG_TAG, "onAttachedToActivity")
    activityAttached(binding.activity)
  }

  // ActivityAware
  override fun onDetachedFromActivityForConfigChanges() {
    io.flutter.Log.d(this.toString(), "onDetachedFromActivityForConfigChanges")
    activityDetached()
  }

  // ActivityAware
  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    io.flutter.Log.d(this.toString(), "onReattachedToActivityForConfigChanges")
    activityAttached(binding.activity)
  }

  // ActivityAware
  override fun onDetachedFromActivity() {
    io.flutter.Log.d(this.toString(), "onDetachedFromActivity")
    activityDetached()
  }

  fun resetScreenOrientation() {
    currentActivity?.requestedOrientation = initialActivityRequestedOrientation
  }

  private fun activityDetached() {
    currentActivity = null
    player?.destroy()
    player = null
  }
  private fun activityAttached(activity: Activity) {
    initialActivityRequestedOrientation = activity.requestedOrientation
    currentActivity = activity
    player = CustomUnityPlayer(activity)
    activity.window.clearFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN)
  }
}
