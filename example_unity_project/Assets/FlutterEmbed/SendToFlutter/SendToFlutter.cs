using UnityEngine;

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
            // Call a Swift function name
            FlutterEmbedUnityIosSendToFlutter(data);
#endif
        }
    }

// The Swift function name must exist somewhere in the iOS Flutter Runner project.
// Use The following setting in XCode to make the compiler ignore the fact that this 
// method definition does not exist in the Unity project - it will be linked later
// Linking -> Other Linker Flags -> -Wl,-U,_FlutterEmbedUnityIosSendToFlutter
#if UNITY_IOS
    [DllImport("__Internal")]
    private static extern void FlutterEmbedUnityIosSendToFlutter(string data);
#endif
}
