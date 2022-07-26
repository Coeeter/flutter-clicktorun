import 'package:clicktorun_flutter/data/model/run_model.dart';
import 'package:clicktorun_flutter/data/repositories/auth_repository.dart';
import 'package:clicktorun_flutter/data/repositories/run_repository.dart';
import 'package:clicktorun_flutter/ui/screens/insights/graphs_screen.dart';
import 'package:clicktorun_flutter/ui/screens/insights/widgets/all_run_graph.dart';
import 'package:flutter/material.dart';

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
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: StreamBuilder<List<RunModel>>(
        stream: RunRepository.instance().getRunList(
          AuthRepository.instance().currentUser!.email!,
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _loadingWidget();
          }
          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Container(
                  padding: const EdgeInsets.all(10),
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
          );
        },
      ),
    );
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
              padding: const EdgeInsets.only(top: 20),
              child: Column(
                children: [
                  SizedBox(
                    width: width,
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headline5?.copyWith(
                            fontSize: 18,
                            overflow: TextOverflow.fade,
                          ),
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

  Widget _loadingWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          child: Container(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Card(
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width / 2 + 50,
                    height: MediaQuery.of(context).size.width / 2 + 110,
                  ),
                ),
                const SizedBox(width: 10),
                Card(
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width / 2 + 50,
                    height: MediaQuery.of(context).size.width / 2 + 110,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
