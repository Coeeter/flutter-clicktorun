import 'package:clicktorun_flutter/data/model/run_model.dart';
import 'package:clicktorun_flutter/data/repositories/auth_repository.dart';
import 'package:clicktorun_flutter/data/repositories/run_repository.dart';
import 'package:clicktorun_flutter/data/repositories/storage_repository.dart';
import 'package:clicktorun_flutter/ui/screens/tracking/tracking_screen.dart';
import 'package:clicktorun_flutter/ui/utils/Screen.dart';
import 'package:clicktorun_flutter/ui/utils/colors.dart';
import 'package:clicktorun_flutter/ui/screens/tracking/widgets/draggable_fab.dart';
import 'package:clicktorun_flutter/ui/utils/extensions.dart';
import 'package:clicktorun_flutter/ui/widgets/loading_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class YourRunsScreen extends StatefulWidget {
  void Function() refresh;
  YourRunsScreen({required Key key, required this.refresh}) : super(key: key);

  @override
  State<YourRunsScreen> createState() => YourRunsScreenState();
}

class YourRunsScreenState extends State<YourRunsScreen> {
  bool isSelectable = false;
  final GlobalKey _parentKey = GlobalKey();
  bool isLoading = false;
  List<String> selectedRuns = [];

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
              builder: (_) => TrackingScreen(),
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
    if (snapshot.connectionState == ConnectionState.waiting) {
      return LoadingContainer(
        overlayVisibility: false,
      );
    }
    if (!snapshot.hasData || snapshot.data!.isEmpty) {
      return _getNoRunsToDisplay();
    }
    return ListView(
      physics: const BouncingScrollPhysics(),
      children: snapshot.data!.map((RunModel runModel) {
        return _getListItem(
          context,
          runModel,
        );
      }).toList(),
    );
  }

  Widget _getListItem(BuildContext context, RunModel runModel) {
    return GestureDetector(
      onLongPress: () {
        setState(() {
          isSelectable = true;
          selectedRuns.add(runModel.id);
        });
        widget.refresh();
      },
      onTap: () {
        if (!isSelectable) return;
        setState(() {
          selectedRuns.contains(runModel.id)
              ? selectedRuns.remove(runModel.id)
              : selectedRuns.add(runModel.id);
        });
        widget.refresh();
      },
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Slidable(
          key: ValueKey(runModel.id),
          endActionPane: isSelectable ? null : _getActionPane(runModel),
          child: Stack(
            children: [
              Material(
                elevation: 10,
                child: Column(
                  children: [
                    SizedBox(
                      width: Screen.width - 20,
                      height: (Screen.width - 20) / 2,
                      child: _getImage(runModel),
                    ),
                    _getDetailsRow(runModel),
                  ],
                ),
              ),
              _getOverlay(runModel.id),
            ],
          ),
        ),
      ),
    );
  }

  ActionPane _getActionPane(RunModel runModel) {
    return ActionPane(
      motion: const ScrollMotion(),
      dismissible: DismissiblePane(
        onDismissed: () async {
          setState(() {
            isLoading = true;
          });
          await RunRepository.instance().deleteRun([runModel.id]);
          setState(() {
            isLoading = false;
          });
        },
      ),
      children: [
        SlidableAction(
          onPressed: (_) async {
            setState(() {
              isLoading = true;
            });
            await RunRepository.instance().deleteRun([runModel.id]);
            setState(() {
              isLoading = false;
            });
          },
          icon: Icons.delete,
          label: 'Delete run',
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
        )
      ],
    );
  }

  Widget _getImage(RunModel runModel) {
    return FutureBuilder<String>(
      future: StorageRepository.instance().getDownloadUrl(
        Theme.of(context).brightness == Brightness.dark
            ? runModel.darkModeImage
            : runModel.lightModeImage,
      ),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: LoadingContainer(overlayVisibility: false),
          );
        }
        return Image.network(
          snapshot.data!,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            if (loadingProgress.expectedTotalBytes == null) {
              return Center(
                child: LoadingContainer(overlayVisibility: false),
              );
            }
            double percentLoaded = (loadingProgress.cumulativeBytesLoaded /
                loadingProgress.expectedTotalBytes!);
            return Center(
              child: CircularProgressIndicator(
                value: percentLoaded,
                color: ClickToRunColors.secondary,
              ),
            );
          },
        );
      },
    );
  }

  Widget _getDetailsRow(RunModel runModel) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _getValue(
            context,
            (runModel.distanceRanInMetres > 1000
                    ? runModel.distanceRanInMetres / 1000
                    : runModel.distanceRanInMetres.toInt())
                .toString(),
            runModel.distanceRanInMetres > 1000 ? 'km' : 'm',
          ),
          _getValue(
            context,
            runModel.timeTakenInMilliseconds.toTimeString(),
            'Time',
          ),
          _getValue(
            context,
            runModel.averageSpeed.toStringAsFixed(2),
            'km/h',
          ),
        ],
      ),
    );
  }

  Widget _getValue(BuildContext context, String value, String unit) {
    return SizedBox(
      width: (Screen.width - 40) / 3,
      child: Column(
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.headline6?.copyWith(
                  overflow: TextOverflow.ellipsis,
                ),
          ),
          Text(
            unit,
            style: Theme.of(context).textTheme.headline6?.copyWith(
                  fontSize: 14,
                ),
          ),
        ],
      ),
    );
  }

  Widget _getOverlay(String id) {
    return Visibility(
      visible: selectedRuns.contains(id),
      child: Container(
        alignment: Alignment.topRight,
        padding: const EdgeInsets.all(5),
        height: (Screen.width - 20) / 2 + 60,
        color: Theme.of(context).focusColor,
        child: const Icon(
          Icons.check_box,
          color: ClickToRunColors.secondary,
          size: 50,
        ),
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
}
