# flutter_embed_unity_example

Demonstrates how to use the flutter_embed_unity plugin.

## Getting Started

- Checkout this repository
- Create a folder called `unityLibrary` at:
  - `flutter_embed_unity/flutter_embed_unity/example/android/unityLibrary` for Android or
  - `flutter_embed_unity/flutter_embed_unity/example/ios/unityLibrary` for iOS
- Install Unity 2022.3 LTS
- Open [the example Unity project](https://github.com/jamesncl/flutter_embed_unity/tree/main/example_unity_2022_3_project)
- In Unity, go to `Flutter Embed -> Export project to Flutter app` (iOS or Android), and choose the export folder you created earlier
- For iOS: open the `flutter_embed_unity/flutter_embed_unity/example/ios/Runner.xcworkspace` in Xcode. In project navigator, expand the Unity-iPhone project, and select the Data folder. In the Inspector, under Target Membership, change the target membership to UnityFramework. Then select the Unity-iPhone project, then in the editor select the Unity-iPhone project under PROJECTS, then select the Build Settings tab. In the Build Settings tab, find the 'Other linker Flags' setting (you can use the search box to help you find it). Add the following : '-Wl,-U,_FlutterEmbedUnityIos_sendToFlutter'. See [the README](https://github.com/jamesncl/flutter_embed_unity/tree/main/flutter_embed_unity) for full details.
- Now open the example project `flutter_embed_unity/flutter_embed_unity/example` in Android studio and run the project
