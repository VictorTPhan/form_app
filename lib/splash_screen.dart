import 'dart:math';

import 'package:easy_splash_screen/easy_splash_screen.dart';
import 'package:form_app/misc.dart';
import '../home.dart';
import 'package:flutter/material.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  Widget build(BuildContext context) {
    return EasySplashScreen(
      logo: Image(image: AssetImage('assets/formerly_logo.png')),
      logoWidth: 100,
      title: Text(
        style: standardTextStyle(
          color: Colors.white,
          fontSize: 50
        ),
        "Formerly"
      ),
      gradientBackground: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: gradients[Random().nextInt(gradients.length)]
      ),
      loadingText: Text(
        style: standardTextStyle(
          color: Colors.white,
          fontSize: 30
        ),
        "Loading..."
      ),
      navigator: const HomePage(),
      durationInSeconds: 2,
    );
  }
}