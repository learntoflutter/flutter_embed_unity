import 'package:flutter/material.dart';
import 'package:flutter_embed_unity/flutter_embed_unity.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const ExampleApp());
}

class ExampleApp extends StatefulWidget {
  const ExampleApp({super.key});

  @override
  State<ExampleApp> createState() => _ExampleAppState();
}

class _ExampleAppState extends State<ExampleApp> {

  // When converting between strings and numbers in a message protocol
  // always use a fixed locale, to prevent unexpected parsing errors when
  // the user's locale is different to the locale used by the developer
  // (eg the decimal separator might be different)
  static final _fixedLocaleNumberFormatter = NumberFormat.decimalPatternDigits(
    locale: 'en_gb',
    decimalDigits: 2,
  );

  bool? _isUnityArSupportedOnDevice;
  bool _isArSceneActive = false;
  double _rotationSpeed = 30;
  int _numberOfTaps = 0;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: SafeArea(
          child: Builder(
            builder: (context) {
              final theme = Theme.of(context);
              final bool? isUnityArSupportedOnDevice = _isUnityArSupportedOnDevice;
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

              return Column(
                children: [
                  Expanded(
                    child: EmbedUnity(
                      onMessageFromUnity: (String data) {
                        // A message has been received from a Unity script
                        if(data == "touch"){
                          setState(() {
                            _numberOfTaps += 1;
                          });
                        }
                        else if(data == "scene_loaded") {
                          _sendRotationSpeedToUnity(_rotationSpeed);
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
                            });
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
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const Route2()),
                              );
                            },
                            child: const Text("Open route 2", textAlign: TextAlign.center),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              );
            },
          ),
        ),
      ),
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


class Route2 extends StatelessWidget {

  const Route2();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Route 2'),
        ),
        body: SafeArea(
          child: Builder(
              builder: (context) =>
                  Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          "Unity can only be shown in 1 widget at a time. Therefore if a second route "
                              "with a FlutterEmbed is pushed onto the stack, Unity is 'detached' from "
                              "the first route, and attached to the second. When the second route is "
                              "popped from the stack, Unity is reattached to the first route.",
                        ),
                      ),
                      const Expanded(
                        child: EmbedUnity(),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const BackButton(),
                            ElevatedButton(
                              onPressed: () {
                                showDialog(context: context, builder: (_) => const Route3());
                              },
                              child: const Text("Open route 3", textAlign: TextAlign.center),
                            ),
                          ],
                        ),
                      )
                    ],
                  )
          ),
        )
    );
  }
}


class Route3 extends StatelessWidget {

  const Route3();

  @override
  Widget build(BuildContext context) {
    return const AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Route 3",
            textAlign: TextAlign.center,
          ),
          SizedBox(
            height: 100,
            width: 80,
            child: EmbedUnity(),
          ),
        ],
      ),
    );
  }
}