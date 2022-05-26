import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';

class CustomSwitch extends StatelessWidget {
  const CustomSwitch({
    Key? key,
    required this.snapshot,
    required this.switchPhotoMethod,
  }) : super(key: key);

  final bool? snapshot;
  final Function(bool) switchPhotoMethod;

  @override
  Widget build(BuildContext context) {
    return FlutterSwitch(
      inactiveIcon: const Icon(Icons.folder),
      activeIcon: const Icon(
        Icons.camera_alt,
        color: Colors.white,
      ),
      inactiveColor: Colors.grey,
      activeColor: Colors.grey,
      toggleColor: Colors.black,
      inactiveToggleColor: Colors.white,
      width: 80.0,
      height: 33.0,
      value: snapshot ?? true,
      borderRadius: 20.0,
      padding: 4.0,
      onToggle: switchPhotoMethod,
    );
  }
}
