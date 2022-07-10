import 'package:clicktorun_flutter/ui/screens/auth/splash_screen.dart';
import 'package:clicktorun_flutter/ui/utils/colors.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Firebase.initializeApp(),
      builder: (BuildContext context, AsyncSnapshot snapshot) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: const ColorScheme(
            brightness: Brightness.light,
            primary: ClickToRunColors.primary,
            onPrimary: Colors.black,
            secondary: ClickToRunColors.secondary,
            onSecondary: Colors.black,
            error: Colors.red,
            onError: Colors.black,
            surface: Colors.white,
            onSurface: Colors.black,
            background: Colors.white,
            onBackground: Colors.black,
          ),
          focusColor: ClickToRunColors.lightModeOverlay,
        ),
        darkTheme: ThemeData(
          colorScheme: const ColorScheme(
            brightness: Brightness.dark,
            primary: ClickToRunColors.primary,
            onPrimary: Colors.white,
            secondary: ClickToRunColors.secondary,
            onSecondary: Colors.white,
            error: Colors.red,
            onError: Colors.white,
            surface: Color(0xffff1c1b1f),
            onSurface: Colors.white,
            background: Colors.black,
            onBackground: Colors.white,
          ),
          focusColor: ClickToRunColors.darkModeOverlay,
        ),
        home: SplashScreen(),
      ),
    );
  }
}
