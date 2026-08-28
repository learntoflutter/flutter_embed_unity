## 2.1.0-dev.1

August 2026

### Gradle 9 compatibility

* Migrated flutter_embed_unity_6000_0_android to support Gradle 9 and built-in Kotlin (with backward compatibility for apps using Flutter < 3.44)
* Updated examples for compatibility with Flutter 3.47, Gradle 9, new DSL
* Updated example Unity 6 project to use Unity >= 6000.3.17f1 and ARFoundation >= 6.5.0 for [Gradle 9 compatibility](https://discussions.unity.com/t/android-gradle-9-1-0-agp-9-0-0-update-in-unity-6-0/1709062)
* Migrated android implementation packages build from Groovy to Kotlin DSL

> Note that Unity 2022.3 LTS is now unsupported without an extended industry license and [currently does not have support for Gradle 9](https://docs.unity3d.com/2022.3/Documentation/Manual/android-gradle-overview.html)

### Xcode 26 compatibility

Fixed [#81](https://github.com/learntoflutter/flutter_embed_unity/issues/81) which caused a build error when using the latest Xcode and SPM:

> Undefined symbol: OBJC_CLASS$_UnityFramework


## 2.0.0

April 2026

### ⚠️ Breaking changes!

#### Migration steps for iOS

Due to structural changes required to support Swift Package Manager, you now need to add UnityFramework.framework from your exported Unity-iPhone to your Runner target's list of embedded frameworks in Xcode:

* In Xcode, open `<your project root>/ios/Runner.xcworkspace`
* Select 'Runner' in the project navigator
* Under Targets, select 'Runner'
* In the General tab, scroll down to 'Frameworks, Libraries, and Embedded Content'
* Click on `+` and choose Workspace -> Unity-iPhone -> UnityFramework.framework

After adding UnityFramework.framework, you may encounter a build error `Cycle inside Runner; building could produce unreliable results`. To solve this, in Xcode, again select the Runner target, and go to the Build phases tab. Drag the Thin Binary build phase downwards until it is below the Embed Frameworks build phase. If this does not resolve the issue, look for any custom Run Script phases you may have added which contain variables pointing to paths in the final built product (eg $TARGET_BUILD_DIR) and move them down also.

You may also need to run `flutter clean` before rebuilding your project.

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

* Support for [Swift Package Manager](https://docs.flutter.dev/packages-and-plugins/swift-package-manager/for-app-developers) (you can now use SPM instead of Cocoapods to install flutter_embed_unity) (thanks [@timbotimbo](https://github.com/timbotimbo)). Closes [#29](https://github.com/learntoflutter/flutter_embed_unity/issues/29)
* Support for installing required Unity scripts as a Unity Package Manager package via Git URL (thanks [@timbotimbo](https://github.com/timbotimbo)). See [Unity docs](https://docs.unity3d.com/6000.3/Documentation/Manual/upm-ui-giturl.html):
  * For Unity 2022.3: `https://github.com/learntoflutter/flutter_embed_unity.git?path=example_unity_2022_3_project/Assets/FlutterEmbed`
  * For Unity 6000.0 / 6000.3: `https://github.com/learntoflutter/flutter_embed_unity.git?path=example_unity_6000_0_project/Assets/FlutterEmbed`

### Other changes

* Increased minimum Flutter version to 3.35 due to problems with Unity, Xcode 26 and Flutter JIT. Fixes [#73](https://github.com/learntoflutter/flutter_embed_unity/issues/73)
* Example Unity 6 project updated to Unity 6000.3.11f1
* Bump all platform implementation package and platform interface dependencies to 2.0.0
* Increased Android minSdk to 25 in example app, which is required for Unity 6000.3


## 1.5.0

26 March 2026

* Bug fix: Removed flutter_embed_unity_6000_0_android from the list of default / officially endorsed implementations in the package pubspec.yaml. Fixes [#54](https://github.com/learntoflutter/flutter_embed_unity/issues/54)

Having both flutter_embed_unity_2022_3_android and flutter_embed_unity_6000_0_android caused build conflicts in certain scenarios. Users who were not affected by these issues should not notice any change, and no modifications are needed to your app pubspec: if you are targeting Unity 6, you should already have flutter_embed_unity_6000_0_android added to your app's pubspec.yaml. If you experience build errors after upgrading to this version please [report them](https://github.com/learntoflutter/flutter_embed_unity/issues).


## 1.4.0

27 Sep 2025

* New feature: export Unity project from command line (thanks [@timbotimbo](https://github.com/timbotimbo)). See (Advanced: Export from the command line)[https://pub.dev/packages/flutter_embed_unity#advanced-export-from-the-command-line]
* Fix (#56)[https://github.com/learntoflutter/flutter_embed_unity/issues/56]: Could not get unknown property 'unity.androidNdkPath' for project ':unityLibrary'
* Fix (#51)[https://github.com/learntoflutter/flutter_embed_unity/issues/51]: EntryPointNotFoundException in SendToFlutter in Unity Editor play mode
* Upgraded example Unity 6 project to 6000.0.58
* Updated README with clarifications on what Unity versions are supported given that 16KB page sizes becoming mandatory when targeting Android 15+
* Bump flutter_embed_unity_2022_3_android to 1.1.5 and flutter_embed_unity_6000_0_android to 1.2.3

Building from command line and fixes for #56 and #51 require updating your .cs scripts in your Unity project using the latest `flutter_embed_unity_6000_0.unitypackage` or `flutter_embed_unity_2022_3.unitypackage` asset from [releases on Github](https://github.com/learntoflutter/flutter_embed_unity/releases)


## 1.3.1

24 June 2025

* Production release of support for Unity 6000.0 LTS
* Merged [#45](https://github.com/learntoflutter/flutter_embed_unity/pull/45): fixes touch events for Unity 6 on Android (thanks [@timbotimbo](https://github.com/timbotimbo))
* Merged [#46](https://github.com/learntoflutter/flutter_embed_unity/pull/46): fixes messages from Unity not arriving in Flutter when using other plugins which create background Flutter engines (thanks [@timbotimbo](https://github.com/timbotimbo))
* Bump flutter_embed_unity_2022_3_android to 1.1.4

### Steps to migrate from Unity 2022.3 to Unity 6000.0:
* If you are using Android, add the following additional dependency to your pubspec.yaml:

```yaml
dependencies:
  ...
  # Add this for Unity 6000.0 support on Android:
  flutter_embed_unity_6000_0_android: ^1.2.2  # (Use the latest available)
```
* If you are using Android, upgrade your android project's Gradle and AGP to match or exceed [those used by Unity 6000.0](https://docs.unity3d.com/6000.0/Documentation/Manual/android-gradle-overview.html) and update your NDK version to 27.2.12479018 or higher
* If you are using Android and you previously copied the `aaptOptions` block from your Unity export's build.gradle file to your app's build.gradle file to prevent increased load time due to double compression, this has been migrated to an `androidResources` block. Remove the `aaptOptions` block from your android/app/build.gradle and replace with:
```groovy
android {
  ...
  // Syntax for android/app/build.gradle
  androidResources {
    ignoreAssetsPattern = "!.svn:!.git:!.ds_store:!*.scc:!CVS:!thumbs.db:!picasa.ini:!*~"
    noCompress = ['.unity3d', '.ress', '.resource', '.obb', '.bundle', '.unityexp'] + unityStreamingAssets.tokenize(', ')
  }
}
```
```groovy
android {
  ...
  // Syntax for android/app/build.gradle.kts

  androidResources {
    // Read unityStreamingAssets from gradle.properties
    val unityStreamingAssetsList = (project.findProperty("unityStreamingAssets") as? String)
              ?.split(",")
              ?.map { it.trim() }
              ?: emptyList()

    noCompress += listOf(
      ".unity3d", ".ress", ".resource", ".obb", ".bundle", ".unityexp"
    ) + unityStreamingAssetsList

    ignoreAssetsPattern = "!.svn:!.git:!.ds_store:!*.scc:!CVS:!thumbs.db:!picasa.ini:!*~"
  }
}
```
* [Migrate your Unity project to Unity 6000.0](https://docs.unity3d.com/6000.0/Documentation/Manual/upgrade-project.html)
* Update your Unity project's Flutter export scripts by importing the new `flutter_embed_unity_6000_0.unitypackage` asset from [releases on Github](https://github.com/learntoflutter/flutter_embed_unity/releases)
* Export your Unity project to your Flutter project as before, using the new Unity 6 export scripts
* If you encounter any build errors, go through the project setup steps in the README again (this has been updated for Unity 6)


## 1.3.0-beta.1

23 May 2025

* Beta release of support for Unity 6000.0 LTS

Thanks to [@timbotimbo](https://github.com/timbotimbo) for creating the Android platform implementation for Unity 6

#### Steps to migrate from Unity 2022.3 to Unity 6000.0:
* If you are using Android, add the following additional dependency to your pubspec.yaml:

```yaml
dependencies:
  ...
  # Add this for Unity 6000.0 support on Android:
  flutter_embed_unity_6000_0_android: ^1.2.1-beta.1  # (Use the latest available)
```
* If you are using Android, upgrade your android project's Gradle and AGP to match or exceed [those used by Unity 6000.0](https://docs.unity3d.com/6000.0/Documentation/Manual/android-gradle-overview.html) and update your NDK version to 27.2.12479018 or higher
* If you are using Android and you previously copied the `aaptOptions` block from your Unity export's build.gradle file to your app's build.gradle file to prevent increased load time due to double compression, this has been migrated to an `androidResources` block. Remove the `aaptOptions` block from your android/app/build.gradle and replace with:
```kotlin
  androidResources {
    ignoreAssetsPattern = "!.svn:!.git:!.ds_store:!*.scc:!CVS:!thumbs.db:!picasa.ini:!*~"
    noCompress = ['.unity3d', '.ress', '.resource', '.obb', '.bundle', '.unityexp'] + unityStreamingAssets.tokenize(', ')
  }
```
* [Migrate your Unity project to Unity 6000.0](https://docs.unity3d.com/6000.0/Documentation/Manual/upgrade-project.html)
* Update your Unity project's Flutter export scripts by importing the new `flutter_embed_unity_6000_0.unitypackage` asset from [releases on Github](https://github.com/learntoflutter/flutter_embed_unity/releases)
* Export your Unity project to your Flutter project as before, using the new Unity 6 export scripts
* If you encounter any build errors, go through the project setup steps in the README again (this has been updated for Unity 6)


## 1.2.7

22 May 2025

* Updated example project to support Flutter 3.29, Gradle 8 Java 11. Bump flutter_embed_unity_2022_3_android to 1.1.3 for the same.
* Unity export fixed to prevent duplicate namespace being added to `unityLibrary/build.gradle` when using latest version of Unity 2022.3 ([#36](https://github.com/learntoflutter/flutter_embed_unity/pull/36) thanks [@timbotimbo](https://github.com/timbotimbo)).
* Updates to README with alternative gradle modification syntax for Kotlin DSL ([#37](https://github.com/learntoflutter/flutter_embed_unity/pull/37) thanks [@timbotimbo](https://github.com/timbotimbo))
* Unity export improved to automatically remove ndkPath from `unityLibrary/build.gradle` to prevent build error using latest version with flutter 3.29

To upgrade to the latest Unity export build script for Android, either manually replace the contents of your Unity project's `Assets/FlutterEmbed/Editor/ProjectExporterAndroid.cs` with the [content from the 1.2.7 release branch on Github](https://github.com/learntoflutter/flutter_embed_unity/blob/rel/1.2.7/example_unity_2022_3_project/Assets/FlutterEmbed/Editor/ProjectExporterAndroid.cs), or grab the `flutter_embed_unity_2022_3.unitypackage` asset from [1.2.7 release](https://github.com/learntoflutter/flutter_embed_unity/releases) and re-import into your Unity project


## 1.2.6

21 May 2025

Production release of 1.2.6: Destroy UnityPlayer when the main activity is detached from the plugin to prevent crash when re-opening the app. Fixes [#39](https://github.com/learntoflutter/flutter_embed_unity/issues/39)


## 1.2.6-beta.2

27 March 2025

* Bump flutter_embed_unity_2022_3_android to 1.1.2-beta.2 to fix: ~~Unload~~ Destroy UnityPlayer when the main activity is detached from the plugin to prevent crash when re-opening the app. Fixes [#39](https://github.com/learntoflutter/flutter_embed_unity/issues/39) in more scenarios (including when EmbedUnity widget is not at the bottom of the route stack)


## 1.2.6-beta.1

26 March 2025

* Bump flutter_embed_unity_2022_3_android to 1.1.2-beta.1 to fix: Unload UnityPlayer when the main activity is detached from the plugin to prevent crash when re-opening the app. Fixes [#39](https://github.com/learntoflutter/flutter_embed_unity/issues/39)


## 1.2.5

26 Feb 2025

* Updated README with more up to date advice regarding Gradle and AGP (see issue [#38](https://github.com/learntoflutter/flutter_embed_unity/issues/38) - thanks [@timbotimbo](https://github.com/timbotimbo))


## 1.2.4

23 Dec 2024

* Updated README with further details on issue [#21](https://github.com/learntoflutter/flutter_embed_unity/issues/21): workaround available for AR when using Flutter 3.22+ on Android API 32 or earlier (thanks [@timbotimbo](https://github.com/timbotimbo))


## 1.2.3

2 Aug 2024

* Lowered Dart SDK constraint to 2.18+ for compatibility with Flutter 3.7


## 1.2.2

31 July 2024

* ~~Lowered Dart SDK constraint to 2.18+~~ Fixed in 1.2.3


## 1.2.1

22 July 2024

* Updated README to note issue [#21](https://github.com/learntoflutter/flutter_embed_unity/issues/21): AR not supported when using Flutter 3.22 on Android API 32 or less (thanks [@timbotimbo](https://github.com/timbotimbo))

## 1.2.0

4 July 2024

> NOTE: To take advantage of the new automated steps for iOS Unity export, you will need to re-import the latest flutter_embed_unity_2022_3.unitypackage found in [Releases](https://github.com/learntoflutter/flutter_embed_unity/releases) - you only need the changes in `FlutterEmbed/Editor/ProjectExporterIos.cs`
>
> Alternatively, you can simply modify your existing copy of `FlutterEmbed/Editor/ProjectExporterIos.cs` according to [this commit](https://github.com/learntoflutter/flutter_embed_unity/commit/c393efc0e9fbc589e2e4c1045e52d5335830895a)

* After exporting Unity project for iOS, the manual steps for changing the membership of the Data folder to Unity Framework and adding `-Wl,-U,_FlutterEmbedUnityIos_sendToFlutter` to Other Linker Flags in Xcode is no longer required (thanks @timbotimbo). See note above.


## 1.1.1

16 May 2024

* Updated README to add Flutter 3.22 and later to the list of supported versions (3.22 fixes [#12](https://github.com/learntoflutter/flutter_embed_unity/issues/12) and [#14](https://github.com/learntoflutter/flutter_embed_unity/issues/14))


## 1.1.0

29 March 2024

* New Unity input system touches works on Android
* Updated readme to note Unity 2022.3.21 or later will be required on iOS from 1st May [to comply with App Store privacy manifest requirements](https://forum.unity.com/threads/apple-privacy-manifest-updates-for-unity-engine.1529026/)


## 1.1.0-beta1

13 March 2024

* New Unity input system touches works on Android


## 1.0.4

4 March 2024

* Updated README to note that all Unity versions between 2022.3.10 and 2022.3.18 are not supported with Android 8 or earlier due to [#15](https://github.com/learntoflutter/flutter_embed_unity/issues/15)


## 1.0.3

3 March 2024

* Updated README to note that Flutter 3.16.x and 3.19.x are not supported due to [Flutter #141068](https://github.com/flutter/flutter/issues/141068) and [Flutter #142952](https://github.com/flutter/flutter/issues/142952) (tracked in [flutter_embed_unity #14](https://github.com/learntoflutter/flutter_embed_unity/issues/14))


## 1.0.2

10 January 2024

* Updated README to note limitation of [#12](https://github.com/learntoflutter/flutter_embed_unity/issues/12)


## 1.0.1

20 November 2023

* Update Android and iOS platform dependencies to:
  * Fix iOS issue [#10](https://github.com/learntoflutter/flutter_embed_unity/issues/10)
  * Minor change to Android debug logs
* Updated README with info about [#9](https://github.com/learntoflutter/flutter_embed_unity/issues/9) (2022.3.9 not compatible with Xcode 15)
* Upgrade example Unity project version to 2022.3.13 to fix [#9](https://github.com/learntoflutter/flutter_embed_unity/issues/9)


## 1.0.0

12 October 2023

* First production release
* Added `EmbedUnityPreferences` to allow setting Unity message listening behaviour (see the README)


## 0.0.8-beta

3 October 2023

* Update Android and iOS platform dependencies to:
  * Removed green placeholder when Unity is detached from `EmbedUnity`


## 0.0.7-beta

28 September 2023

* Update Android and platform interface dependency to:
  * Fix [issue #5](https://github.com/learntoflutter/flutter_embed_unity/issues/5) (Unity freezing on hot reload and widget rebuild)


## 0.0.6-beta

27 September 2023

* Update iOS platform dependency to:
  * Fix [issue #6](https://github.com/learntoflutter/flutter_embed_unity/issues/6)
  * Fix iOS platform package dependency name in iOS example app


## 0.0.5-beta

* Update iOS platform dependency to:
  * Fix [issue #3](https://github.com/learntoflutter/flutter_embed_unity/issues/3): plugin not working when R8 / minification enabled on Android


## 0.0.4-beta

* Update dependencies


## 0.0.3-beta

* Minor changes to the README


## 0.0.2-beta

* **Breaking change:** due to a change in namespace, you MUST upgrade the `SendToFlutter.cs` script in your Unity project to use the new version from [the v0.0.2-beta release assets flutter_embed_unity_2022_3.unitypackage](https://github.com/learntoflutter/flutter_embed_unity/releases). Alternatively you can review [the source for SendToFlutter.cs](https://github.com/learntoflutter/flutter_embed_unity/blob/main/example_unity_2022_3_project/Assets/FlutterEmbed/SendToFlutter/SendToFlutter.cs) and make the change to the `AndroidJavaClass` package namespace manually.


## 0.0.1-beta

* Initial beta release