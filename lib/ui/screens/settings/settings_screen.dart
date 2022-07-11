import 'package:clicktorun_flutter/data/model/clicktorun_user.dart';
import 'package:clicktorun_flutter/data/repositories/auth_repository.dart';
import 'package:clicktorun_flutter/data/repositories/user_repository.dart';
import 'package:clicktorun_flutter/ui/screens/auth/login_screen.dart';
import 'package:clicktorun_flutter/ui/screens/settings/edit_profile_screen.dart';
import 'package:clicktorun_flutter/ui/widgets/profile_image.dart';
import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Theme.of(context).colorScheme.surface
            : const Color(0xFFEDECEC),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              const SizedBox(height: 20),
              StreamBuilder(
                stream: UserRepository.instance().getUserStream(),
                builder: _builder,
              ),
              const SizedBox(height: 30),
              _settingsItem(
                  title: "Edit Account",
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => EditUserDetailsScreen(),
                    ));
                  }),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(15),
            alignment: Alignment.bottomCenter,
            child: TextButton(
              child: const Text("Sign Out"),
              onPressed: () {
                AuthRepository().logout();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => LoginForm()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _settingsItem({
    required String title,
    required void Function() onPressed,
  }) {
    return Material(
      child: InkWell(
        onTap: onPressed,
        child: Ink(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.background,
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.headline5,
                ),
                const Icon(Icons.arrow_forward),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _builder(
    BuildContext context,
    AsyncSnapshot<UserModel?> userSnapshot,
  ) {
    Size size = MediaQuery.of(context).size;
    double side = (size.width - 20) / 5;
    ColorScheme colorScheme = Theme.of(context).colorScheme.copyWith(
          surface: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF303030)
              : Colors.white,
        );

    return Material(
      child: InkWell(
        onTap: () => {},
        child: Ink(
          decoration: BoxDecoration(color: colorScheme.background),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                ProfileImage(
                  width: side,
                  colorScheme: colorScheme,
                  snapshot: userSnapshot,
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userSnapshot.hasData
                          ? userSnapshot.data!.username
                          : "Loading...",
                      style: Theme.of(context).textTheme.headline4?.copyWith(
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                    ),
                    Text(
                      "View profile",
                      style: Theme.of(context).textTheme.headline6?.copyWith(
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontSize: 18,
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
