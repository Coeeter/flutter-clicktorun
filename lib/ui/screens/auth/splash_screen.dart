import 'package:clicktorun_flutter/data/model/clicktorun_user.dart';
import 'package:clicktorun_flutter/data/repositories/auth_repository.dart';
import 'package:clicktorun_flutter/data/repositories/user_repository.dart';
import 'package:clicktorun_flutter/ui/screens/auth/user_details_screen.dart';
import 'package:clicktorun_flutter/ui/screens/parent/parent_screen.dart';
import 'package:clicktorun_flutter/ui/utils/colors.dart';
import 'package:flutter/material.dart';
import 'login_screen.dart';

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
        child: Text(
          'ClickToRun',
          style: Theme.of(context).textTheme.headline6!.copyWith(
                fontSize: 50,
                fontWeight: FontWeight.normal,
              ),
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
          UserModel? user = await UserRepository().getUser();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) {
                if (AuthRepository().currentUser == null) {
                  return LoginForm();
                }
                if (user == null) {
                  return UserDetailsScreen();
                }
                return ParentScreen();
              },
            ),
          );
        },
      ),
    ];
  }
}
