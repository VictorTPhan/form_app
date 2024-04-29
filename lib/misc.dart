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
  [0x2E3192, 0x1BFFFF],
  [0xD4145A, 0xFBB03B],
  [0x009245, 0xFCEE21],
  [0x662D8C, 0xED1E79],
  [0xEE9CA7, 0xFFDDE1],
  [0x614385, 0x516395],
  [0x02AABD, 0x00CDAC],
  [0xFF512F, 0xDD2476],
  [0xFF5F6D, 0xFFC371],
  [0x11998E, 0x38EF7D],
  [0xC6EA8D, 0xFE90AF],
  [0xEA8D8D, 0xA890FE],
  [0xD8B5FF, 0x1EAE98],
  [0xFF61D2, 0xFE9090],
  [0xBFF098, 0x6FD6FF],
  [0x4E65FF, 0x92EFFD],
  [0xA9F1DF, 0xFFBBBB],
  [0xC33764, 0x1D2671],
  [0x93A5CF, 0xE4EFE9],
  [0x868F96, 0x596164],
  [0x09203F, 0x537895],
  [0xFFECD2, 0xFCB69F],
  [0xA1C4FD, 0xC2E9FB],
  [0x764BA2, 0x667EEA],
  [0xFDFCFB, 0xE2D1C3]
];
