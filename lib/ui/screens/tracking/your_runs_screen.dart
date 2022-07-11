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
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      key: _parentKey,
      children: [
        _getNoRunsToDisplay(),
        if (isLoading)
          LoadingContainer(
            overlayVisibility: false,
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
