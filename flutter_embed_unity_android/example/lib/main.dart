import 'package:flutter/material.dart';
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
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Builder(
          builder: (context) => Center(
            child: ElevatedButton(
              child: Text("Open unity screen"),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const UnityScreen()));
              },
            ),
          ),
        ),
      ),
    );
  }
}


class UnityScreen extends StatefulWidget {

  const UnityScreen();

  @override
  State<UnityScreen> createState() => _UnityScreenState();
}

class _UnityScreenState extends State<UnityScreen> {

  double _rotationSpeed = 15;

  @override
  void initState() {
    addUnityMessageListener((String data) {
      debugPrint("Received! $data");
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // final theme = Theme.of(context);
    // final localisedText = AppLocalizations.of(context)!;
    // final orientation = MediaQuery.of(context).orientation;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Unity'),
      ),
      body: Column(
        children: [
          const Expanded(
            child: FlutterEmbed(),
          ),
          Slider(
            min: -100,
            max: 100,
            value: _rotationSpeed,
            onChanged: (value) {
              setState(() {
                _rotationSpeed = value;
                sendToUnity(
                  "Cube",
                  "SetRotationSpeed",
                  value.toStringAsFixed(2),
                );
              });
            },
          )
        ],
      ),
    );
  }
}