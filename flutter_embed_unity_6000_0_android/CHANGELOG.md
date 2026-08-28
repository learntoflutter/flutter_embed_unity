## 2.1.0-dev.1

August 2026

### Gradle 9 compatibility

* Migrated to support Gradle 9 and built-in Kotlin (with backward compatibility for apps using Flutter < 3.44)
* Updated examples for compatibility with Flutter 3.47, Gradle 9, new DSL
* Updated example Unity 6 project to use Unity >= 6000.3.17f1 and ARFoundation >= 6.5.0 for [Gradle 9 compatibility](https://discussions.unity.com/t/android-gradle-9-1-0-agp-9-0-0-update-in-unity-6-0/1709062)
* Migrated build from Groovy to Kotlin DSL


## 2.0.0

April 2026

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


## 1.2.3

27 Sep 2025

* Upgraded example project to use Kotlin 2.1.21 instead of 1.8.22 (which will not be supported in future versions of Flutter)


## 1.2.2

24 June 2025

* Production release of support for Unity 6000.0
* Merged [#45](https://github.com/learntoflutter/flutter_embed_unity/pull/45): fixes touch events for Unity 6
* Merged [#46](https://github.com/learntoflutter/flutter_embed_unity/pull/46): fixes messages from Unity not arriving in Flutter when using other plugins which create background Flutter engines


## 1.2.1-beta.1

* Initial beta release
  Based on `flutter_embed_unity_2022_3_android`.

Thanks to [@timbotimbo](https://github.com/timbotimbo) for creating the Android platform implementation for Unity 6