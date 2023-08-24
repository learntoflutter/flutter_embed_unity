
import 'package:flutter/material.dart';
import 'package:flutter_embed_unity/flutter_embed_unity.dart';

class PauseOnViewDisposeNotifier extends StatefulWidget {

  final Widget child;

  const PauseOnViewDisposeNotifier({required this.child});

  @override
  State<PauseOnViewDisposeNotifier> createState() => _PauseOnViewDisposeNotifierState();
}

class _PauseOnViewDisposeNotifierState extends State<PauseOnViewDisposeNotifier> {

  @override
  void dispose() {
    pauseUnity();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}