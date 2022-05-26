import 'package:flutter/material.dart';

final Map<int, Color> _yellow700Map = {
  50: const Color(0xFFFDBF11),
  100: Colors.yellow[100]!,
  200: Colors.yellow[200]!,
  300: Colors.yellow[300]!,
  400: Colors.yellow[400]!,
  500: Colors.yellow[500]!,
  600: Colors.yellow[600]!,
  700: Colors.yellow[800]!,
  800: Colors.yellow[900]!,
  900: Colors.yellow[700]!,
};

const lightYellow = Color(0xFFFDF0BF);
const grey = Color(0xFFF3F4F6);
const dark = Color(0xFF464A56);

final MaterialColor yellow700Swatch =
    MaterialColor(Colors.yellow[700]!.value, _yellow700Map);
