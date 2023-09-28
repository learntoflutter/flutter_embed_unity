## 0.0.1-beta

* Initial beta release

## 0.0.2-beta

* **Breaking change:** due to a change in namespace, you MUST upgrade the `SendToFlutter.cs` script in your Unity project to use the new version from [the v0.0.2-beta release assets flutter_embed_unity_2022_3.unitypackage](https://github.com/learntoflutter/flutter_embed_unity/releases). Alternatively you can review [the source for SendToFlutter.cs](https://github.com/learntoflutter/flutter_embed_unity/blob/main/example_unity_2022_3_project/Assets/FlutterEmbed/SendToFlutter/SendToFlutter.cs) and make the change to the `AndroidJavaClass` package namespace manually.

## 0.0.3-beta

* Minor changes to the README

## 0.0.4-beta

* Update dependencies

## 0.0.5-beta

* Fix [issue #3](https://github.com/learntoflutter/flutter_embed_unity/issues/3): plugin not working when R8 / minification enabled on Android

## 0.0.6-beta

* Fix [issue #5](https://github.com/learntoflutter/flutter_embed_unity/issues/5) (Unity freezing on hot reload and widget rebuild)