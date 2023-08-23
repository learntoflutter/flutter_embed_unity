using System;
using System.Runtime.InteropServices;
using UnityEngine;
using UnityEngine.SceneManagement;

public class SendToFlutter
{
    public static void Send(string data) {
        if (Application.platform == RuntimePlatform.Android)
        {
            // Use reflection to call the relevant static Kotlin method in the Android plugin
            using (AndroidJavaClass sendToFlutterClass = new AndroidJavaClass("com.jamesncl.dev.flutter_embed_unity_android.SendToFlutter"))
            {
                sendToFlutterClass.CallStatic("sendToFlutter", data);
            }
        }
        else
        {
#if UNITY_IOS
            // Call an obj-C function name
            FlutterEmbedUnityIosSendToFlutter(data);
#endif
        }
    }

#if UNITY_IOS
    // On iOS plugins are statically linked into
    // the executable, so we have to use __Internal as the
    // library name.
    [DllImport("__Internal")]
    // This function is defined in flutter_embed_unity_2022_3_ios/ios/Classes/FlutterEmbedUnityIosSendToFlutter.m
    private static extern void FlutterEmbedUnityIosSendToFlutter(string data);
#endif
}
