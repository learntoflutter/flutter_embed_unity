package com.jamesncl.dev.flutter_embed_unity_android

import com.jamesncl.dev.flutter_embed_unity_android.Constants.Companion.logTag
import com.jamesncl.dev.flutter_embed_unity_android.Constants.Companion.methodChannelIdentifier
import com.jamesncl.dev.flutter_embed_unity_android.Constants.Companion.uniqueViewIdentifier
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodChannel
import io.flutter.Log

/**
 * The plugin implements ActivityAware so that it can respond to Android activity-related events.
 * See https://docs.flutter.dev/release/breaking-changes/plugin-api-migration#uiactivity-plugin
 * and https://api.flutter.dev/javadoc/io/flutter/embedding/engine/plugins/activity/ActivityAware.html
 * */
class FlutterEmbedUnityAndroidPlugin: FlutterPlugin, ActivityAware {
  /// The MethodChannel that will the communication between Flutter and native Android
  private lateinit var channel : MethodChannel
//  private lateinit var pluginBinding: FlutterPlugin.FlutterPluginBinding
  private val methodCallHandler = FlutterMethodCallHandler()
  private val bindFlutterActivityToViewFactory = BindFlutterActivityToViewFactory()

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
        // The view factory needs access to the Flutter view, because it needs to be
        // passed to the UnityPlayer which the view creates. However the activity is
        // not available yet (it is only available when onAttachedToActivity is
        // called). Therefore pass this intermediary which will be updated later
        UnityViewFactory(bindFlutterActivityToViewFactory)
      )
  }


  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    Log.d(logTag, "onDetachedFromEngine")
    channel.setMethodCallHandler(null)
  }

  // ActivityAware
  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    Log.d(logTag, "onAttachedToActivity")
    bindFlutterActivityToViewFactory.flutterActivity = binding.activity
  }

  // ActivityAware
  override fun onDetachedFromActivityForConfigChanges() {
    Log.d(logTag, "onDetachedFromActivityForConfigChanges")
    bindFlutterActivityToViewFactory.flutterActivity = null
  }

  // ActivityAware
  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    Log.d(logTag, "onReattachedToActivityForConfigChanges")
    bindFlutterActivityToViewFactory.flutterActivity = binding.activity
  }

  // ActivityAware
  override fun onDetachedFromActivity() {
    Log.d(logTag, "onDetachedFromActivity")
    bindFlutterActivityToViewFactory.flutterActivity = null
  }
}
