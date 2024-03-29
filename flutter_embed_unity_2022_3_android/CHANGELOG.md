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