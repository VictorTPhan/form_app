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