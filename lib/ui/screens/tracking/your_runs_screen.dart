import 'package:clicktorun_flutter/data/model/run_model.dart';
import 'package:clicktorun_flutter/data/repositories/auth_repository.dart';
import 'package:clicktorun_flutter/data/repositories/run_repository.dart';
import 'package:clicktorun_flutter/ui/screens/tracking/tracking_screen.dart';
import 'package:clicktorun_flutter/ui/utils/Screen.dart';
import 'package:clicktorun_flutter/ui/widgets/draggable_fab.dart';
import 'package:clicktorun_flutter/ui/widgets/loading_container.dart';
import 'package:flutter/material.dart';

class YourRunsScreen extends StatefulWidget {
  @override
  State<YourRunsScreen> createState() => _YourRunsScreenState();
}

class _YourRunsScreenState extends State<YourRunsScreen> {
  final GlobalKey _parentKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Stack(
      key: _parentKey,
      children: [
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
      ],
    );
  }

  Widget _builder(
      BuildContext context, AsyncSnapshot<List<RunModel>> snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return LoadingContainer(
        overlayVisibility: false,
      );
    }
    if (!snapshot.hasData || snapshot.data!.isEmpty) {
      return _getNoRunsToDisplay();
    }
    return ListView(
      children: snapshot.data!.map((runModel) {
        return _getListItem(runModel);
      }).toList(),
    );
  }

  Widget _getListItem(RunModel runModel) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      child: Material(
        elevation: 10,
        child: Column(
          children: [
            SizedBox(
              width: Screen.width - 20,
              height: (Screen.width - 20) / 2,
              child: Stack(
                children: [
                  const Center(
                    child: CircularProgressIndicator(),
                  ),
                  Image.network(
                    Theme.of(context).brightness == Brightness.dark
                        ? runModel.darkModeImage
                        : runModel.lightModeImage,
                  ),
                ],
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
                    _formatTime(runModel.timeTakenInMilliseconds),
                    'Time',
                  ),
                  _getValue(
                    context,
                    runModel.averageSpeed.toStringAsFixed(2),
                    'km/h',
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  String _formatTime(int timeTaken) {
    int seconds = timeTaken ~/ 1000 % 60;
    int minutes = timeTaken ~/ 1000 ~/ 60 % 60;
    int hours = timeTaken ~/ 1000 ~/ 60 ~/ 60;
    return '$hours:$minutes:$seconds';
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
                  fontSize: 16,
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
