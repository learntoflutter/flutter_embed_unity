import 'package:flutter/material.dart';
import 'package:flutter_embed_unity/flutter_embed_unity.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

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
    return ChangeNotifierProvider<AppState>(
      create: (_) => AppState(),
      child: MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            title: const Text('Plugin example app'),
          ),
          body: Builder(
            builder: (context) => Center(
              child: ElevatedButton(
                child: const Text("Open unity screen"),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const UnityScreen()
                      )
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}


class UnityScreen extends StatelessWidget {

  // When converting between strings and numbers in a message protocol
  // always use a fixed locale, to prevent unexpected parsing errors when
  // the user's locale is different to the locale used by the developer
  // (eg the decimal separator might be different)
  static final _fixedLocaleNumberFormatter = NumberFormat.decimalPatternDigits(
    locale: 'en_gb',
    decimalDigits: 2,
  );

  const UnityScreen();

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {

        final theme = Theme.of(context);
        final bool? isUnityArSupportedOnDevice = appState.isUnityArSupportedOnDevice;
        final String arStatusMessage;

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
                      appState.update(numberOfTaps: appState.numberOfTaps + 1);
                    }
                    else if(data == "scene_loaded") {
                      _sendRotationSpeedToUnity(appState.rotationSpeed);
                    }
                    else if(data == "ar:true") {
                      appState.update(isUnityArSupportedOnDevice: true);
                    }
                    else if(data == "ar:false") {
                      appState.update(isUnityArSupportedOnDevice: false);
                    }
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  "Flutter logo has been touched ${appState.numberOfTaps} times",
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
                      value: appState.isArSceneActive,
                      onChanged: isUnityArSupportedOnDevice != null && isUnityArSupportedOnDevice ? (value) {
                        sendToUnity(
                          "SceneSwitcher",
                          "SwitchToScene",
                          appState.isArSceneActive ? "FlutterEmbedExampleScene" : "FlutterEmbedExampleSceneAR",
                        );
                        appState.update(isArSceneActive: value);
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
                      value: appState.rotationSpeed,
                      onChanged: (value) {
                        appState.update(rotationSpeed: value);
                        _sendRotationSpeedToUnity(value);
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
      },
    );
  }

  void _sendRotationSpeedToUnity(double rotationSpeed) {
    sendToUnity(
      "FlutterLogo",
      "SetRotationSpeed",
      _fixedLocaleNumberFormatter.format(rotationSpeed),
    );
  }
}


class AppState with ChangeNotifier {
  bool? isUnityArSupportedOnDevice;
  bool isArSceneActive = false;
  double rotationSpeed = 30;
  int numberOfTaps = 0;

  AppState();

  void update({
    bool? isUnityArSupportedOnDevice,
    bool? isArSceneActive,
    double? rotationSpeed,
    int? numberOfTaps,
  }) {
    this.isUnityArSupportedOnDevice = isUnityArSupportedOnDevice ?? this.isUnityArSupportedOnDevice;
    this.isArSceneActive = isArSceneActive ?? this.isArSceneActive;
    this.rotationSpeed = rotationSpeed ?? this.rotationSpeed;
    this.numberOfTaps = numberOfTaps ?? this.numberOfTaps;
    notifyListeners();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppState &&
          runtimeType == other.runtimeType &&
          isUnityArSupportedOnDevice == other.isUnityArSupportedOnDevice &&
          isArSceneActive == other.isArSceneActive &&
          rotationSpeed == other.rotationSpeed &&
          numberOfTaps == other.numberOfTaps;

  @override
  int get hashCode => isUnityArSupportedOnDevice.hashCode ^ isArSceneActive.hashCode ^ rotationSpeed.hashCode ^ numberOfTaps.hashCode;
}