enum MessageFromUnityListeningBehaviour {
  /// All `EmbedUnity` widgets currently in a widget tree will receive
  /// all messages from Unity via `onMessageFromUnity` (i.e. multicast)
  allWidgetsReceiveMessages,

  /// Only the most recently created widget (which will usually be in
  /// the top-most route on the navigation stack) will receive messages
  /// from Unity (i.e. unicast)
  onlyMostRecentlyCreatedWidgetReceivesMessages,
}

class EmbedUnityPreferences {
  /// Determines which `EmbedUnity` widgets will receive messages from Unity
  ///
  /// If there are multiple `EmbedUnity` widgets in different screens / routes
  /// of your app, this allows you to decide whether all of them receive each
  /// message (i.e. broadcast) or just the
  /// 'top' widget receives messages from Unity via `onMessageFromUnity`
  static MessageFromUnityListeningBehaviour messageFromUnityListeningBehaviour =
      MessageFromUnityListeningBehaviour.allWidgetsReceiveMessages;
}
