import 'package:clicktorun_flutter/data/repositories/run_repository.dart';
import 'package:clicktorun_flutter/ui/screens/settings/settings_screen.dart';
import 'package:clicktorun_flutter/ui/screens/tracking/your_runs_screen.dart';
import 'package:clicktorun_flutter/ui/utils/snackbar.dart';
import 'package:clicktorun_flutter/ui/widgets/appbar.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ParentScreen extends StatefulWidget {
  @override
  State<ParentScreen> createState() => _ParentScreenState();
}

class _ParentScreenState extends State<ParentScreen> {
  final GlobalKey<YourRunsScreenState> _runsKey = GlobalKey();
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ClickToRunAppbar(_getTitle(currentIndex)).getAppBar(
        actions: _getActions(
          context,
          currentIndex,
        ),
      ),
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

  Widget? _getCurrentScreen(int index) => [
        YourRunsScreen(
          key: _runsKey,
          refresh: () => setState(() {}),
        ),
        null,
        null,
        SettingsScreen()
      ][index];

  String _getTitle(int currentIndex) => [
        _runsKey.currentState?.isSelectable == true
            ? "${_runsKey.currentState?.selectedRuns.length ?? 0} selected"
            : "Your Runs",
        "Explore",
        "Insights",
        "Settings",
      ][currentIndex];

  List<Widget> _getActions(BuildContext context, int index) => <List<Widget>>[
        [
          if (_runsKey.currentState?.isSelectable == true)
            Row(
              children: [
                IconButton(
                  onPressed: () async {
                    setState(() {
                      _runsKey.currentState?.isLoading = true;
                    });
                    bool deleteResults =
                        await RunRepository.instance().deleteRun(
                      _runsKey.currentState?.selectedRuns ?? [],
                    );
                    setState(() {
                      _runsKey.currentState?.isLoading = false;
                    });
                    if (!deleteResults) {
                      return SnackbarUtils(context: context)
                          .createSnackbar('Unknown error has occurred');
                    }
                    setState(() {
                      _runsKey.currentState?.isSelectable = false;
                      _runsKey.currentState?.selectedRuns.clear();
                    });
                  },
                  icon: const Icon(Icons.delete),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _runsKey.currentState?.isSelectable = false;
                      _runsKey.currentState?.selectedRuns.clear();
                    });
                  },
                  icon: const Icon(Icons.close),
                ),
              ],
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
