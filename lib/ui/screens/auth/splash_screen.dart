import 'package:clicktorun_flutter/data/model/clicktorun_user.dart';
import 'package:clicktorun_flutter/data/repositories/auth_repository.dart';
import 'package:clicktorun_flutter/data/repositories/user_repository.dart';
import 'package:clicktorun_flutter/ui/screens/auth/login_screen.dart';
import 'package:clicktorun_flutter/ui/screens/auth/user_details_screen.dart';
import 'package:clicktorun_flutter/ui/screens/parent/parent_screen.dart';
import 'package:clicktorun_flutter/ui/utils/Screen.dart';
import 'package:clicktorun_flutter/ui/utils/colors.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _animate = false;
  final int _animationLength = 1;
  int animationCount = 0;

  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    Screen.height = mediaQueryData.size.height;
    Screen.width = mediaQueryData.size.width;
    sleep().then(
      (_) {
        if (animationCount > 0) return;
        setState(() {
          _animate = true;
          animationCount++;
        });
      },
    );
    return Scaffold(
      body: getBody(),
    );
  }

  Future<void> sleep() => Future.delayed(
        const Duration(seconds: 2),
        () => null,
      );

  Container getBody() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: ClickToRunColors.linearGradient,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: getChildren(),
      ),
    );
  }

  List<Widget> getChildren() {
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
            ? Screen.width
            : Screen.width * 0.13,
        child: Image.asset(
          'assets/images/ic_launcher_round_shadow.png',
          width: Screen.width * 0.8,
          height: Screen.width * 0.8,
        ),
        onEnd: () async {
          UserModel? user = await UserRepository.instance().getUser();
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
