import 'package:clicktorun_flutter/data/model/run_model.dart';
import 'package:clicktorun_flutter/data/repositories/auth_repository.dart';
import 'package:clicktorun_flutter/data/repositories/position_repository.dart';
import 'package:clicktorun_flutter/data/repositories/run_repository.dart';
import 'package:clicktorun_flutter/ui/screens/tracking/tracking_screen.dart';
import 'package:clicktorun_flutter/ui/screens/home/widgets/runs_list_view.dart';
import 'package:clicktorun_flutter/ui/utils/Screen.dart';
import 'package:clicktorun_flutter/ui/utils/colors.dart';
import 'package:clicktorun_flutter/ui/screens/home/widgets/draggable_fab.dart';
import 'package:clicktorun_flutter/ui/utils/snackbar.dart';
import 'package:clicktorun_flutter/ui/widgets/appbar.dart';
import 'package:flutter/material.dart';

class YourRunsScreen extends StatefulWidget {
  final void Function() refreshParent;
  final GlobalKey<CustomAppbarState> appbarKey;

  const YourRunsScreen({
    required Key key,
    required this.appbarKey,
    required this.refreshParent,
  }) : super(key: key);

  @override
  State<YourRunsScreen> createState() => YourRunsScreenState();
}

class YourRunsScreenState extends State<YourRunsScreen> {
  final GlobalKey _parentKey = GlobalKey();
  final GlobalKey<RunsListViewState> _listViewKey =
      GlobalKey<RunsListViewState>();
  bool isSelectable = false;
  bool isLoading = false;

  String? title;

  @override
  Widget build(BuildContext context) {
    return Stack(
      key: _parentKey,
      children: [
        if (!isLoading)
          StreamBuilder<List<RunModel>>(
            stream: RunRepository.instance().getRunList(
              AuthRepository.instance().currentUser!.email!,
            ),
            builder: _builder,
          ),
        DraggableFloatingActionButton(
          parentKey: _parentKey,
          onPressed: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => const TrackingScreen(),
            ),
          ),
        ),
        if (isLoading)
          Container(
            color: Theme.of(context).colorScheme.surface,
            child: const Center(
              child: CircularProgressIndicator(
                color: ClickToRunColors.secondary,
              ),
            ),
          ),
      ],
    );
  }

  Widget _builder(
    BuildContext context,
    AsyncSnapshot<List<RunModel>> snapshot,
  ) {
    if (isLoading) return Container();
    bool snapshotIsWaiting =
        snapshot.connectionState == ConnectionState.waiting;
    if (!snapshotIsWaiting && (!snapshot.hasData || snapshot.data!.isEmpty)) {
      return _getNoRunsToDisplay();
    }
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Theme.of(context).colorScheme.surface,
      child: RunsListView(
        key: _listViewKey,
        runList: snapshot.data,
        isLoading: snapshotIsWaiting,
        updateTitle: (int count) {
          if (isSelectable) {
            return widget.appbarKey.currentState?.setTitle("$count selected");
          }
          widget.appbarKey.currentState?.setTitle("Your Runs");
        },
        setLoading: (bool value) {
          setState(() {
            isLoading = value;
          });
        },
      ),
    );
  }

  Widget _getNoRunsToDisplay() {
    Size size = Size(Screen.width, Screen.height);

    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Image.asset(
              'assets/images/ic_empty_run_list.png',
              width: size.width - 150,
              height: size.width - 150,
            ),
          ),
          Text(
            "There are no runs recorded yet",
            style: Theme.of(context).textTheme.headline5,
          ),
          Text(
            "Try adding one today!",
            style: Theme.of(context)
                .textTheme
                .headline6!
                .copyWith(fontWeight: FontWeight.normal),
          ),
        ],
      ),
    );
  }

  void enableSelection() async {
    if (_listViewKey.currentState?.widget.isLoading == true) return;
    setState(() {
      isSelectable = true;
      title = "0 selected";
    });
    _listViewKey.currentState!.setState(() {
      _listViewKey.currentState!.isSelectable = true;
    });
    widget.refreshParent();
  }

  void clearSelection() {
    setState(() {
      isSelectable = false;
      title = null;
    });
    widget.refreshParent();
    _listViewKey.currentState!.setState(() {
      _listViewKey.currentState!.isSelectable = false;
    });
  }

  void deleteRuns() async {
    if (_listViewKey.currentState?.selectedCount == 0) return clearSelection();
    setState(() {
      isSelectable = false;
      isLoading = true;
      title = null;
    });
    _listViewKey.currentState!.setState(() {
      _listViewKey.currentState!.isSelectable = false;
    });
    widget.appbarKey.currentState?.setTitle("Your Runs");
    widget.refreshParent();
    List<String> selectedItems = _listViewKey.currentState!.selectedItems;
    bool deleteResults = await RunRepository.instance().deleteRun(
      selectedItems,
    );
    bool isPositionDeleted = false;
    for (String runId in selectedItems) {
      isPositionDeleted = await PositionRepository.instance().deleteRunRoute(
        runId,
      );
    }
    setState(() {
      isLoading = false;
    });
    if (!deleteResults || !isPositionDeleted) {
      SnackbarUtils(context: context).createSnackbar(
        'Unknown error has occurred',
      );
    }
  }
}
