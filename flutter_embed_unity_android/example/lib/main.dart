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

  double _rotationSpeed = 50;
  int _numberOfTaps = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Unity'),
      ),
      body: Column(
        children: [
          Expanded(
            child: FlutterEmbed(
              onMessageFromUnity: (String data) {
                if(data == "touch") {
                  setState(() {
                    _numberOfTaps++;
                  });
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              "Flutter logo has been touched $_numberOfTaps times",
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium,
            ),
          ),
          Row(
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 16),
                child: Text(
                  "Speed",
                ),
              ),
              Expanded(
                child: Slider(
                  min: -200,
                  max: 200,
                  value: _rotationSpeed,
                  onChanged: (value) {
                    setState(() {
                      _rotationSpeed = value;
                      sendToUnity(
                        "FlutterLogo",
                        "SetRotationSpeed",
                        value.toStringAsFixed(2),
                      );
                    });
                  },
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}