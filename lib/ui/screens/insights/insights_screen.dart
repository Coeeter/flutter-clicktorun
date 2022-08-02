import 'package:clicktorun_flutter/data/model/run_model.dart';
import 'package:clicktorun_flutter/data/repositories/auth_repository.dart';
import 'package:clicktorun_flutter/data/repositories/run_repository.dart';
import 'package:clicktorun_flutter/ui/screens/insights/graphs_screen.dart';
import 'package:clicktorun_flutter/ui/screens/insights/widgets/all_run_graph.dart';
import 'package:clicktorun_flutter/ui/utils/colors.dart';
import 'package:clicktorun_flutter/ui/utils/extensions.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

enum GraphType {
  averageSpeed,
  distance,
  timeTaken,
}

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({Key? key}) : super(key: key);

  @override
  State<InsightsScreen> createState() => InsightsScreenState();
}

class InsightsScreenState extends State<InsightsScreen> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: const EdgeInsets.all(10),
      child: StreamBuilder<List<RunModel>>(
        stream: RunRepository.instance().getRunList(
          AuthRepository.instance().currentUser!.email!,
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _loadingWidget(context);
          }
          if (snapshot.data == null || snapshot.data!.isEmpty) {
            return _nothingToDisplay(context);
          }
          return _mainBody(context, snapshot);
        },
      ),
    );
  }

  Widget _mainBody(
    BuildContext context,
    AsyncSnapshot<List<RunModel>> snapshot,
  ) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          children: [
            _getHeader(context, "Data of all runs"),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _getTextValue(
                  context,
                  snapshot.data!.length.toString(),
                  'Total number of runs',
                ),
                _getTextValue(
                  context,
                  _getDistance(
                    snapshot.data!.map(
                      (run) {
                        return run.distanceRanInMetres;
                      },
                    ).reduce(
                      (first, next) {
                        return first + next;
                      },
                    ),
                  ),
                  "Total distance",
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _getTextValue(
                  context,
                  _getTimeString(
                    snapshot.data!.map((run) {
                      return run.timeTakenInMilliseconds;
                    }).reduce((first, next) {
                      return first + next;
                    }),
                  ),
                  'Total time taken',
                ),
                _getTextValue(
                  context,
                  "${(snapshot.data!.map(
                        (e) => e.averageSpeed,
                      ).reduce(
                        (v, e) => v + e,
                      ) / snapshot.data!.length).toStringAsFixed(2)} km/h",
                  "Total average speed",
                ),
              ],
            ),
          ],
        ),
        Column(
          children: [
            _getHeader(context, "Graphs of all runs"),
            Padding(
              padding: const EdgeInsets.all(10),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    _buildGraph(
                      context,
                      snapshot,
                      "Average Speed\nover time",
                      GraphType.averageSpeed,
                    ),
                    const SizedBox(width: 10),
                    _buildGraph(
                      context,
                      snapshot,
                      "Distance ran\nover time",
                      GraphType.distance,
                    ),
                    const SizedBox(width: 10),
                    _buildGraph(
                      context,
                      snapshot,
                      "Time taken\nfor runs",
                      GraphType.timeTaken,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _getHeader(
    BuildContext context,
    String text,
  ) {
    return Container(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            text,
            style: Theme.of(context).textTheme.headline5!.copyWith(
                  fontSize: 30,
                  fontWeight: FontWeight.w500,
                ),
          ),
          const SizedBox(height: 10),
          Container(
            height: 2,
            decoration: const BoxDecoration(
              gradient: ClickToRunColors.linearGradient,
            ),
          ),
        ],
      ),
    );
  }

  Widget _getTextValue(
    BuildContext context,
    String text,
    String unit,
  ) {
    return SizedBox(
      width: (MediaQuery.of(context).size.width - 20) / 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            text,
            style: Theme.of(context).textTheme.headline4!.copyWith(
                  fontSize: 27,
                  fontFamily: 'Roboto',
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black,
                ),
          ),
          Text(
            unit,
            style: Theme.of(context).textTheme.headline6!.copyWith(
                  fontSize: 14,
                ),
          ),
        ],
      ),
    );
  }

  String _getTimeString(int timeTakenInMilliseconds) {
    String timeTaken = timeTakenInMilliseconds.toTimeString();
    String seconds = "${int.parse(timeTaken.split(':')[2])}s";
    String minutes = "${int.parse(timeTaken.split(':')[1])}min ";
    String hours = "${int.parse(timeTaken.split(':')[0])}hr ";
    if (hours == "0hr ") hours = "";
    if (minutes == "0min ") minutes = "";
    if (seconds == "0s") seconds = "";
    return "$hours$minutes$seconds";
  }

  String _getDistance(double distanceInMetres) {
    if (distanceInMetres < 1000) return "$distanceInMetres m";
    return "${distanceInMetres / 1000} km";
  }

  Widget _buildGraph(
    BuildContext context,
    AsyncSnapshot<List<RunModel>> snapshot,
    String title,
    GraphType graphType,
  ) {
    double width = MediaQuery.of(context).size.width / 2 + 50;
    return Card(
      elevation: 7,
      child: IntrinsicHeight(
        child: Stack(
          children: [
            Container(
              width: width,
              padding: const EdgeInsets.only(top: 10),
              child: Column(
                children: [
                  SizedBox(
                    width: width,
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .headline5
                          ?.copyWith(overflow: TextOverflow.ellipsis),
                    ),
                  ),
                  SizedBox(
                    width: width,
                    height: width,
                    child: AllRunGraph(
                      runList: snapshot.data!,
                      preview: true,
                      graphType: graphType,
                    ),
                  ),
                ],
              ),
            ),
            InkWell(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => GraphScreen(
                    runList: snapshot.data!,
                    graphType: graphType,
                  ),
                ),
              ),
              child: Container(width: width),
            )
          ],
        ),
      ),
    );
  }

  Widget _nothingToDisplay(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 50,
            vertical: 30,
          ),
          child: Image.asset('assets/images/ic_no_insights_data.png'),
        ),
        Text(
          'No data to get insights from',
          style: Theme.of(context).textTheme.headline5,
        ),
        Text(
          'Try adding a run today!',
          style: Theme.of(context).textTheme.headline5,
        ),
      ],
    );
  }

  Widget _loadingWidget(BuildContext context) {
    return Shimmer.fromColors(
      highlightColor: ClickToRunColors.gethighlightColor(context),
      baseColor: ClickToRunColors.getbaseColor(context),
      child: Container(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                Container(
                  height: 50,
                  color: ClickToRunColors.getbaseColor(context),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: (MediaQuery.of(context).size.width - 80) / 2,
                      height: 60,
                      color: ClickToRunColors.getbaseColor(context),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      width: (MediaQuery.of(context).size.width - 80) / 2,
                      height: 60,
                      color: ClickToRunColors.getbaseColor(context),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: (MediaQuery.of(context).size.width - 80) / 2,
                      height: 60,
                      color: ClickToRunColors.getbaseColor(context),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      width: (MediaQuery.of(context).size.width - 80) / 2,
                      height: 60,
                      color: ClickToRunColors.getbaseColor(context),
                    ),
                  ],
                ),
              ],
            ),
            Column(
              children: [
                Container(
                  height: 50,
                  color: ClickToRunColors.getbaseColor(context),
                ),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const NeverScrollableScrollPhysics(),
                  child: Row(
                    children: [
                      Material(
                        child: Container(
                          width: MediaQuery.of(context).size.width / 2 + 50,
                          height: MediaQuery.of(context).size.width / 2 + 110,
                          color: ClickToRunColors.getbaseColor(context),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Material(
                        child: Container(
                          width: MediaQuery.of(context).size.width / 2 + 50,
                          height: MediaQuery.of(context).size.width / 2 + 110,
                          color: ClickToRunColors.getbaseColor(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
