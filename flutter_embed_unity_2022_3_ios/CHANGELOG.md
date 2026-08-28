## 2.1.0-dev.1

August 2026

### Xcode 26 compatibility

Fixed [#81](https://github.com/learntoflutter/flutter_embed_unity/issues/81) which caused a build error when using the latest Xcode and SPM:

> Undefined symbol: OBJC_CLASS$_UnityFramework


## 2.0.0

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


## 1.0.2

31 July 2024

* Lowered Dart SDK constraint to 2.18+


## 1.0.1

20 November 2023

* Fix [#10](https://github.com/learntoflutter/flutter_embed_unity/issues/10)


## 1.0.0

12 October 2023

* First production release


## 0.0.7-beta

3 October 2023

* Removed green placeholder when Unity is detached from `EmbedUnity`


## 0.0.6-beta

28 September 2023

* Update platform interface dependency


## 0.0.5-beta

27 September 2023

* Fix [issue #6](https://github.com/learntoflutter/flutter_embed_unity/issues/6)
* Fix iOS platform package dependency name in iOS example app


## 0.0.4-beta

* Update dependencies


## 0.0.3-beta

* Minor changes to the README


## 0.0.2-beta

* **Breaking change:** due to a change in namespace, you MUST upgrade the `SendToFlutter.cs` script in your Unity project to use the new version from [the v0.0.2-beta release assets flutter_embed_unity_2022_3.unitypackage](https://github.com/learntoflutter/flutter_embed_unity/releases). Alternatively you can review [the source for SendToFlutter.cs](https://github.com/learntoflutter/flutter_embed_unity/blob/main/example_unity_2022_3_project/Assets/FlutterEmbed/SendToFlutter/SendToFlutter.cs) and make the change to the `AndroidJavaClass` package namespace manually.


## 0.0.1-beta

* Initial beta release