import 'package:flutter/material.dart';
import 'package:flutter_embed_unity/flutter_embed_unity.dart';
import 'package:intl/intl.dart';

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
              child: const Text("Open unity screen"),
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

  // When converting between strings and numbers in a message protocol
  // always use a fixed locale, to prevent unexpected parsing errors when
  // the user's locale is different to the locale used by the developer
  // (eg the decimal separator might be different)
  final _fixedLocaleNumberFormatter = NumberFormat.decimalPatternDigits(
    locale: 'en_gb',
    decimalDigits: 2,
  );

  double _rotationSpeed = 30;
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
                switch(data) {
                  case "touch": {
                    setState(() {
                      _numberOfTaps++;
                    });
                    break;
                  }
                  case "scene_loaded": {
                    _setRotationSpeed();
                    break;
                  }
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
                      _setRotationSpeed();
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

  void _setRotationSpeed() {
    sendToUnity(
      "FlutterLogo",
      "SetRotationSpeed",
      _fixedLocaleNumberFormatter.format(_rotationSpeed),
    );
  }
}