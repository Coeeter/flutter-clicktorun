import 'package:clicktorun_flutter/data/model/run_model.dart';
import 'package:clicktorun_flutter/data/repositories/auth_repository.dart';
import 'package:clicktorun_flutter/data/repositories/run_repository.dart';
import 'package:clicktorun_flutter/data/repositories/storage_repository.dart';
import 'package:clicktorun_flutter/ui/screens/tracking/tracking_screen.dart';
import 'package:clicktorun_flutter/ui/utils/Screen.dart';
import 'package:clicktorun_flutter/ui/utils/colors.dart';
import 'package:clicktorun_flutter/ui/utils/extensions.dart';
import 'package:clicktorun_flutter/ui/screens/tracking/widgets/draggable_fab.dart';
import 'package:clicktorun_flutter/ui/widgets/loading_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class YourRunsScreen extends StatefulWidget {
  @override
  State<YourRunsScreen> createState() => _YourRunsScreenState();
}

class _YourRunsScreenState extends State<YourRunsScreen> {
  final GlobalKey _parentKey = GlobalKey();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      key: _parentKey,
      children: [
        if (!_isLoading)
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
        if (_isLoading)
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
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Slidable(
        key: ValueKey(runModel.id),
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          dismissible: DismissiblePane(
            onDismissed: () async {
              setState(() {
                _isLoading = true;
              });
              await RunRepository.instance().deleteRun(runModel.id);
              setState(() {
                _isLoading = false;
              });
            },
          ),
          children: [
            SlidableAction(
              onPressed: (_) async {
                setState(() {
                  _isLoading = true;
                });
                await RunRepository.instance().deleteRun(runModel.id);
                setState(() {
                  _isLoading = false;
                });
              },
              icon: Icons.delete,
              label: 'Delete run',
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            )
          ],
        ),
        child: Material(
          elevation: 10,
          child: Column(
            children: [
              SizedBox(
                width: Screen.width - 20,
                height: (Screen.width - 20) / 2,
                child: FutureBuilder<String>(
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
                        double percentLoaded = 1.0 *
                            (loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!);
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          alignment: Alignment.center,
                          child: CircularProgressIndicator(
                            value: percentLoaded,
                            color: ClickToRunColors.secondary,
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              Padding(
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
              ),
            ],
          ),
        ),
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
