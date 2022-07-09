import 'package:clicktorun_flutter/data/repositories/auth_repository.dart';
import 'package:clicktorun_flutter/data/repositories/user_repository.dart';
import 'package:clicktorun_flutter/ui/screens/auth/login_screen.dart';
import 'package:clicktorun_flutter/ui/widgets/appbar.dart';
import 'package:clicktorun_flutter/ui/widgets/gradient_button.dart';
import 'package:flutter/material.dart';
import 'package:clicktorun_flutter/data/model/clicktorun_user.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ClickToRunAppbar("Home").getAppBar(),
      body: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(50),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GradientButton(
              text: "Log Out",
              onPressed: () {
                AuthRepository().logout();
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (_) => LoginForm(),
                ));
              },
            ),
            const SizedBox(
              height: 50,
            ),
            GradientButton(
              text: "Delete Account",
              onPressed: () async {
                UserModel? user = await UserRepository().getUser();
                UserRepository().deleteUser(user!.email);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => LoginForm(),
                  ),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
