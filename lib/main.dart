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
          brightness: Brightness.light,
          primarySwatch: ClickToRunColors.primarySwatch,
          focusColor: ClickToRunColors.lightModeOverlay,
        ),
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          primarySwatch: ClickToRunColors.primarySwatch,
          focusColor: ClickToRunColors.darkModeOverlay,
        ),
        home: SplashScreen(),
      ),
    );
  }
}
