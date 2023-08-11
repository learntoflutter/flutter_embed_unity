import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_embed_unity/flutter_embed_unity.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  bool? _succeeded;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    try {
      bool succeeded = await canLaunch('test');

      if (mounted) {
        setState(() {
          _succeeded = succeeded;
        });
      }
    } on PlatformException {
      print('PlatformException calling canLaunch');
    }
  }

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
            Text('Method call test: $_succeeded'),
          ],
        ),
      ),
    );
  }
}
