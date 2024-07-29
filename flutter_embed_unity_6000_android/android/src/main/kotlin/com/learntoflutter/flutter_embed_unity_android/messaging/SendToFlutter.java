package com.learntoflutter.flutter_embed_unity_android.messaging;

import static com.learntoflutter.flutter_embed_unity_android.constants.FlutterEmbedConstants.logTag;
import static com.learntoflutter.flutter_embed_unity_android.constants.FlutterEmbedConstants.methodNameSendToFlutter;

import android.os.Handler;
import android.os.Looper;

import androidx.annotation.Keep;

import io.flutter.Log;
import io.flutter.plugin.common.MethodChannel;

/**
 * DO NOT change the name of this class, it's package location or function names: they are
 * referenced in C# Unity scripts (<unity project>/Assets/FlutterEmbed/SendToFlutter/SendToFlutter.cs)
 * using reflection, so changing names or location will break people's projects. This also
 * means this class must be Java, not Kotlin, because Kotlin companion object methods do not compile
 * to Java static methods.
 */

// IMPORTANT: Do not remove @Keep annotations, they tell the minifier not to remove or rename
// these elements during compilation so that refection from Unity C# does not break on release build
@Keep
public class SendToFlutter {
   public static MethodChannel methodChannel = null;

   // IMPORTANT: Do not remove @Keep annotations, they tell the minifier not to remove or rename
   // these elements during compilation so that refection from Unity C# does not break on release build
   @Keep
   public static void sendToFlutter(String data) {
      new Handler(Looper.getMainLooper()).post(() -> {
         if(methodChannel != null) {
            methodChannel.invokeMethod(methodNameSendToFlutter, data);
         }
         else {
            Log.e(logTag, "Couldn't send message from Android to Flutter: method channel not registered");
         }
      });
   }
}
