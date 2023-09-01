# flutter_embed_unity plugin overview

> [!NOTE]
> See [the main README of the app-facing package](https://github.com/jamesncl/flutter_embed_unity/tree/main/flutter_embed_unity) for details.


This is a containing folder for a [federated Flutter plugin](https://docs.flutter.dev/packages-and-plugins/developing-packages) for embedding Unity 3D into Flutter apps, containing:


- `flutter_embed_unity`: this is the main app-facing package, which you should depend on in your Flutter app's `pubspec.yaml`
- `flutter_embed_unity_2022_3_android`: the Android platform package for this plugin, supporting Unity 2022.3 LTS
- `flutter_embed_unity_2022_3_ios`: the iOS platform package for this plugin, supporting Unity 2022.3 LTS
- `flutter_embed_unity_platform_interface`: The package that glues the app-facing package to the platform package(s). This package declares an interface that any platform package must implement to support the app-facing package. Having a single package that defines this interface ensures that all platform packages implement the same functionality in a uniform way.
- `example_unity_2022_3_project`: a Unity project for building into the example project, for demo and development purposes
