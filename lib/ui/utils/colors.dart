import 'package:flutter/material.dart';

class ClickToRunColors {
  static const Color primary = Color.fromARGB(255, 0, 204, 255);
  static const Color secondary = Color.fromARGB(255, 119, 255, 187);
  static const Color darkModeOverlay = Color.fromARGB(102, 175, 175, 175);
  static const Color lightModeOverlay = Color.fromARGB(155, 0, 0, 0);
  static const MaterialColor primarySwatch = MaterialColor(0xFF00caff, {
    50: Color.fromRGBO(0, 204, 255, .1),
    100: Color.fromRGBO(0, 204, 255, .2),
    200: Color.fromRGBO(0, 204, 255, .3),
    300: Color.fromRGBO(0, 204, 255, .4),
    400: Color.fromRGBO(0, 204, 255, .5),
    500: Color.fromRGBO(0, 204, 255, .6),
    600: Color.fromRGBO(0, 204, 255, .7),
    700: Color.fromRGBO(0, 204, 255, .8),
    800: Color.fromRGBO(0, 204, 255, .9),
    900: Color.fromRGBO(0, 204, 255, 1),
  });

  static const LinearGradient linearGradient = LinearGradient(
    colors: [
      primary,
      Color.fromARGB(255, 56, 234, 236),
      secondary,
    ],
  );
}
