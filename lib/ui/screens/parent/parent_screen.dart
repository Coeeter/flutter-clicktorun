import 'package:clicktorun_flutter/ui/screens/explore/explore_screen.dart';
import 'package:clicktorun_flutter/ui/screens/insights/insights_screen.dart';
import 'package:clicktorun_flutter/ui/screens/settings/settings_screen.dart';
import 'package:clicktorun_flutter/ui/screens/home/your_runs_screen.dart';
import 'package:clicktorun_flutter/ui/widgets/appbar.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ParentScreen extends StatefulWidget {
  const ParentScreen({Key? key}) : super(key: key);

  @override
  State<ParentScreen> createState() => _ParentScreenState();
}

class _ParentScreenState extends State<ParentScreen> {
  final GlobalKey<YourRunsScreenState> _runsKey = GlobalKey();
  final GlobalKey<CustomAppbarState> _appbarKey = GlobalKey();
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(
        key: _appbarKey,
        title: _getTitle(currentIndex),
        actions: _getActions(
          context,
          currentIndex,
        ),
        elevation: _getTitle(currentIndex) == "Explore" ? 0 : 4,
      ),
      body: Container(
        color: Theme.of(context).colorScheme.surface,
        child: _getCurrentScreen(currentIndex),
      ),
      bottomNavigationBar: _getBottomNavigationBar(context),
    );
  }

  Widget _getBottomNavigationBar(BuildContext context) {
    return BottomNavigationBar(
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
    );
  }

  Widget? _getCurrentScreen(int index) => [
        YourRunsScreen(
          key: _runsKey,
          appbarKey: _appbarKey,
          refreshParent: () => setState(() {}),
        ),
        const ExploreScreen(),
        const InsightsScreen(),
        const SettingsScreen()
      ][index];

  String _getTitle(int currentIndex) => [
        _runsKey.currentState?.title ?? "Your Runs",
        "Explore",
        "Insights",
        "Settings",
      ][currentIndex];

  List<Widget> _getActions(BuildContext context, int index) => <List<Widget>>[
        [
          Visibility(
            visible: _runsKey.currentState?.isSelectable == true,
            child: IconButton(
              onPressed: () async {
                _runsKey.currentState?.deleteRuns();
              },
              icon: const Icon(Icons.delete),
            ),
          ),
          Visibility(
            visible: _runsKey.currentState?.isSelectable == true,
            child: IconButton(
              onPressed: () {
                _runsKey.currentState?.clearSelection();
              },
              icon: const Icon(Icons.close),
            ),
          ),
          Visibility(
            visible: _runsKey.currentState?.isSelectable != true,
            child: IconButton(
              onPressed: () {
                _runsKey.currentState?.enableSelection();
              },
              icon: const Icon(Icons.edit),
            ),
          ),
        ],
        [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.message,
            ),
          ),
        ],
        [],
        []
      ][index];
}
