import 'package:clicktorun_flutter/ui/screens/settings/settings_screen.dart';
import 'package:clicktorun_flutter/ui/screens/tracking/your_runs_screen.dart';
import 'package:clicktorun_flutter/ui/widgets/appbar.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ParentScreen extends StatefulWidget {
  @override
  State<ParentScreen> createState() => _ParentScreenState();
}

class _ParentScreenState extends State<ParentScreen> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ClickToRunAppbar(_getTitle(currentIndex)).getAppBar(),
      body: Container(
        decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface),
        child: _getCurrentScreen(currentIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.personRunning),
            label: "Your Runs",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore),
            label: "Explore",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.insights),
            label: "Insights",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: "Settings",
          ),
        ],
        currentIndex: currentIndex,
        onTap: (int index) => setState(() {
          currentIndex = index;
        }),
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: true,
        showUnselectedLabels: false,
        selectedItemColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget? _getCurrentScreen(int index) =>
      [YourRunsScreen(), null, null, SettingsScreen()][index];

  String _getTitle(int currentIndex) =>
      ["Your Runs", "Explore", "Insights", "Settings"][currentIndex];
}
