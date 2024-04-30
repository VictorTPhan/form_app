import 'package:flutter/material.dart';
import 'package:form_app/pages/splash_screen.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';

main() async {
  await GetStorage.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    var baseTheme = ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2A00FF)),
      useMaterial3: true,
    );

    return MaterialApp(
      title: 'Formerly',
      theme: baseTheme.copyWith(
        textTheme: GoogleFonts.workSansTextTheme(baseTheme.textTheme),
      ),
      home: const SplashPage(),
    );
  }
}
