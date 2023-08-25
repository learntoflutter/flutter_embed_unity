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
  bool? _isUnityArSupportedOnDevice;
  bool _isArSceneActive = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final String arStatusMessage;
    final bool? isUnityArSupportedOnDevice = _isUnityArSupportedOnDevice;
    if(isUnityArSupportedOnDevice == null) {
      arStatusMessage = "checking...";
    }
    else if(isUnityArSupportedOnDevice) {
      arStatusMessage = "supported";
    }
    else {
      arStatusMessage = "not supported on this device";
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Unity'),
      ),
      body: Column(
        children: [
          Expanded(
            child: EmbedUnity(
              onMessageFromUnity: (String data) {
                if(data == "touch"){
                  setState(() {
                    _numberOfTaps++;
                  });
                }
                else if(data == "scene_loaded") {
                  _setRotationSpeed();
                }
                else if(data == "ar:true") {
                  setState(() {
                    _isUnityArSupportedOnDevice = true;
                  });
                }
                else if(data == "ar:false") {
                  setState(() {
                    _isUnityArSupportedOnDevice = false;
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text("Activate AR ($arStatusMessage)"),
                Switch(
                  value: _isArSceneActive,
                  onChanged: isUnityArSupportedOnDevice != null && isUnityArSupportedOnDevice ? (value) {
                    sendToUnity(
                      "SceneSwitcher",
                      "SwitchToScene",
                      _isArSceneActive ? "FlutterEmbedExampleScene" : "FlutterEmbedExampleSceneAR",
                    );
                    setState(() {
                      _isArSceneActive = value;
                    });
                  } : null,
                ),
              ],
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
          ),
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: () {
                      pauseUnity();
                    },
                    child: const Text("Pause"),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: () {
                      resumeUnity();
                    },
                    child: const Text("Resume"),
                  ),
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