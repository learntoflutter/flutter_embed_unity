## 2.1.0-dev.1

August 2026

* Migrated build from Groovy to Kotlin DSL
* Bumped example Gradle / AGP / Kotlin versions


## 2.0.0

### ⚠️ Breaking changes!

#### Migration steps for Android

The flutter_embed_unity_6000_0_android package is now the default implementation for Android, which means you will need to make a change to your app's pubspec.yaml.

If you are targeting Unity 2022.3, you now need to explicitly override the default implementation for android from Unity 6 to Unity 2022.3 by adding flutter_embed_unity_2022_3_android as a dependency:

```yaml
dependencies:
  ...
  flutter_embed_unity: ^2.0.0
  flutter_embed_unity_2022_3_android: ^1.1.5  # <-- If using Unity 2022.3, add this
```

If you are targeting Unity 6, you will already have an override for flutter_embed_unity_6000_0_android in your app's pubspec. You can now remove it:

```yaml
dependencies:
  ...
  flutter_embed_unity: ^2.0.0
  # flutter_embed_unity_6000_0_android: ^1.2.3  # <-- If using Unity 6 LTS, this can be removed
```

### New features

* Support for installing required Unity scripts as a Unity Package Manager package via Git URL (thanks [@timbotimbo](https://github.com/timbotimbo)). See [Unity docs](https://docs.unity3d.com/6000.3/Documentation/Manual/upm-ui-giturl.html):
  * For Unity 2022.3: `https://github.com/learntoflutter/flutter_embed_unity.git?path=example_unity_2022_3_project/Assets/FlutterEmbed`
  * For Unity 6000.0 / 6000.3: `https://github.com/learntoflutter/flutter_embed_unity.git?path=example_unity_6000_0_project/Assets/FlutterEmbed`

### Other changes

* Increased minimum Flutter version to 3.35 due to problems with Unity, Xcode 26 and Flutter JIT. Fixes [#73](https://github.com/learntoflutter/flutter_embed_unity/issues/73)
* Example Unity 6 project updated to Unity 6000.3.11f1
* Bump all platform implementation package and platform interface dependencies to 2.0.0
* Increased Android minSdk to 25 in example app, which is required for Unity 6000.3


## 1.1.5

27 Sep 2025

* Upgraded example project to use Kotlin 2.1.21 instead of 1.8.22 (which will not be supported in future versions of Flutter)


## 1.1.4

24 June 2025

* Merged [#45](https://github.com/learntoflutter/flutter_embed_unity/pull/45): fixes touch events for Unity 6
* Merged [#46](https://github.com/learntoflutter/flutter_embed_unity/pull/46): fixes messages from Unity not arriving in Flutter when using other plugins which create background Flutter engines


## 1.1.3

22 May 2025

Updated example project to support Flutter 3.29, Gradle 8 Java 11, updated native plugin project's gradle to use Kotlin DSL, Java 11, Gradle 8.9, AGP 8.7, compile SDK 35


## 1.1.2

21 May 2025

Production release of 1.1.2: Destroy UnityPlayer when the main activity is detached from the plugin to prevent crash when re-opening the app. Fixes [#39](https://github.com/learntoflutter/flutter_embed_unity/issues/39)


## 1.1.2-beta.2

27 March 2025

* ~~Unload~~ Destroy UnityPlayer when the main activity is detached from the plugin to prevent crash when re-opening the app. Fixes [#39](https://github.com/learntoflutter/flutter_embed_unity/issues/39) in more scenarios (including when EmbedUnity widget is not at the bottom of the route stack)


## 1.1.2-beta.1

26 March 2025

* Unload UnityPlayer when the main activity is detached from the plugin to prevent crash when re-opening the app. Fixes [#39](https://github.com/learntoflutter/flutter_embed_unity/issues/39)


## 1.1.1

31 July 2024

* Lowered Dart SDK constraint to 2.18+


## 1.1.0

29 March 2024

* New Unity input system touches works on Android


## 1.1.0-beta1

13 March 2024

* New Unity input system touches works on Android


## 1.0.1

20 November 2023

* Minor change to debug logs


## 1.0.0

12 October 2023

* First production release


## 0.0.7-beta

3 October 2023

* Removed green placeholder when Unity is detached from `EmbedUnity`


## 0.0.6-beta

28 September 2023

* Fix [issue #5](https://github.com/learntoflutter/flutter_embed_unity/issues/5) (Unity freezing on hot reload and widget rebuild)


## 0.0.5-beta

* Fix [issue #3](https://github.com/learntoflutter/flutter_embed_unity/issues/3): plugin not working when R8 / minification enabled on Android


## 0.0.4-beta

* Update dependencies


## 0.0.3-beta

* Minor changes to the README


## 0.0.2-beta

* **Breaking change:** due to a change in namespace, you MUST upgrade the `SendToFlutter.cs` script in your Unity project to use the new version from [the v0.0.2-beta release assets flutter_embed_unity_2022_3.unitypackage](https://github.com/learntoflutter/flutter_embed_unity/releases). Alternatively you can review [the source for SendToFlutter.cs](https://github.com/learntoflutter/flutter_embed_unity/blob/main/example_unity_2022_3_project/Assets/FlutterEmbed/SendToFlutter/SendToFlutter.cs) and make the change to the `AndroidJavaClass` package namespace manually.


## 0.0.1-beta

* Initial beta release