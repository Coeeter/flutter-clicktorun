import 'package:clicktorun_flutter/data/model/run_model.dart';
import 'package:clicktorun_flutter/data/repositories/auth_repository.dart';
import 'package:clicktorun_flutter/data/repositories/run_repository.dart';
import 'package:clicktorun_flutter/ui/screens/insights/widgets/average_speed_graph.dart';
import 'package:flutter/material.dart';

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
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Text(
              "Average Speed(km/h) over time",
              style: Theme.of(context).textTheme.headline5?.copyWith(
                    fontSize: 20,
                  ),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<RunModel>>(
              stream: RunRepository.instance().getRunList(
                AuthRepository.instance().currentUser!.email!,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                List<RunModel> runList = snapshot.data!;
                return Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: AverageSpeedOverTimeGraph(
                    runList: runList,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
