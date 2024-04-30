import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void navigateTo(BuildContext context, StatefulWidget newScreen) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => newScreen,
    ),
  );
}

TextStyle standardTextStyle(
    {double fontSize = 16,
    FontWeight fontWeight = FontWeight.normal,
    FontStyle fontStyle = FontStyle.normal,
    Color color = Colors.black}
    ) {
  return TextStyle(
    fontSize: fontSize,
    fontWeight: fontWeight,
    fontStyle: fontStyle,
    color: color
  );
}

const gradients = [
  [Color(0xFFFFAA48), Color(0xFFFF0073)],
  [Color(0xFF00FF3A), Color(0xFF00796D)],
  [Color(0xFFFFC74B), Color(0xFF05A200)],
  [Color(0xFFFFF000), Color(0xFFF9035E)],
  [Color(0xFF00FF97), Color(0xFF0059FF)],
  [Color(0xFFE003F9), Color(0xFF2F00FF)],
  [Color(0xFF03AFF9), Color(0xFF0022FF)],
];
