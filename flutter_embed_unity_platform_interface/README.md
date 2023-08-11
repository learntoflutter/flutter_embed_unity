# flutter_embed_unity_platform_interface

A common platform interface for the [`flutter_embed_unity`][1] plugin.

This interface allows platform-specific implementations of the `flutter_embed_unity`
plugin, as well as the plugin itself, to ensure they are supporting the
same interface.

# Usage

To implement a new platform-specific implementation of `flutter_embed_unity`, extend
[`FlutterEmbedUnityPlatform`][2] with an implementation that performs the
platform-specific behavior, and when you register your plugin, set the default
`FlutterEmbedUnityPlatform` by calling
`FlutterEmbedUnityPlatform.instance = FlutterEmbedUnityMyPlatform()`.

# Note on breaking changes

Strongly prefer non-breaking changes (such as adding a method to the interface)
over breaking changes for this package.

See https://flutter.dev/go/platform-interface-breaking-changes for a discussion
on why a less-clean interface is preferable to a breaking change.

[1]: ../flutter_embed_unity
[2]: lib/src/flutter_embed_unity_platform_interface.dart