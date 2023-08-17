import 'package:flutter/material.dart';

class OrientationChangeDetector extends StatefulWidget {

  final Widget child;
  final Function() onBuildOrientationChanged;

  const OrientationChangeDetector({required this.child, required this.onBuildOrientationChanged});

  @override
  State<OrientationChangeDetector> createState() => _OrientationChangeDetectorState();
}

class _OrientationChangeDetectorState extends State<OrientationChangeDetector> {

  Orientation? _previousOrientation;

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
        builder: (context, orientation) {
          if(_previousOrientation == null) {
            _previousOrientation = orientation;
          }
          else if(_previousOrientation != orientation) {
            widget.onBuildOrientationChanged();
            _previousOrientation = orientation;
          }
          return widget.child;
        }
    );
  }
}