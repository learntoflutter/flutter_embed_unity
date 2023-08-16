import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_embed_unity/flutter_embed_unity.dart';
import 'package:flutter_embed_unity_android/flutter_embed_unity_android_platform_interface.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  final _flutterEmbedUnityAndroidPlugin = FlutterEmbedUnityAndroid();
  double _rotationSpeed = 15;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Column(
          children: [
            const Expanded(
              child: FlutterEmbed(),
            ),
            ElevatedButton(
              child: Text("Reset"),
              onPressed: () {
                _flutterEmbedUnityAndroidPlugin.reset();
              },
            ),
            Slider(
              min: -100,
              max: 100,
              value: _rotationSpeed,
              onChanged: (value) {
                setState(() {
                  _rotationSpeed = value;
                  _flutterEmbedUnityAndroidPlugin.sendToUnity(
                    "Cube",
                    "SetRotationSpeed",
                    value.toStringAsFixed(2),
                  );
                });
              },
            )
          ],
        ),
      ),
    );
  }
}
