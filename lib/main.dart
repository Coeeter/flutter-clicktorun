import 'package:clicktorun_flutter/data/repositories/auth_repository.dart';
import 'package:clicktorun_flutter/data/repositories/user_repository.dart';
import 'package:clicktorun_flutter/ui/screens/auth/user_details_screen.dart';
import 'package:clicktorun_flutter/ui/screens/auth/login_screen.dart';
import 'package:clicktorun_flutter/ui/screens/main/home.dart';
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

class SplashScreen extends StatefulWidget {
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _animate = false;
  final int _animationLength = 1;

  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    sleep().then(
      (_) => setState(() {
        _animate = true;
      }),
    );
    return Scaffold(
      body: getBody(mediaQueryData),
    );
  }

  Future<void> sleep() => Future.delayed(
        const Duration(seconds: 2),
        () => null,
      );

  Container getBody(MediaQueryData mediaQueryData) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: ClickToRunColors.linearGradient,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: getChildren(mediaQueryData),
      ),
    );
  }

  List<Widget> getChildren(MediaQueryData mediaQueryData) {
    return [
      AnimatedOpacity(
        opacity: _animate ? 1.0 : 0,
        duration: Duration(milliseconds: (_animationLength * 1000) ~/ 2),
        child: const Text(
          'ClickToRun',
          style: TextStyle(color: Colors.white, fontSize: 40),
        ),
      ),
      AnimatedPositioned(
        duration: Duration(seconds: _animationLength),
        left: _animate
            ? mediaQueryData.size.width
            : mediaQueryData.size.width * 0.13,
        child: Image.asset(
          'images/ic_launcher_round_shadow.png',
          width: mediaQueryData.size.width * 0.8,
          height: mediaQueryData.size.width * 0.8,
        ),
        onEnd: () async {
          if (AuthRepository().currentUser == null) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => LoginForm()),
            );
            return;
          }
          if (await UserRepository().getUser() == null) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => const UserDetailsScreen(),
              ),
            );
            return;
          }
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => HomeScreen()),
          );
        },
      ),
    ];
  }
}
