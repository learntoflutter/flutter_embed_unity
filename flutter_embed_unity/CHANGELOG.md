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