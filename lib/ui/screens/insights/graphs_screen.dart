import 'package:clicktorun_flutter/data/model/run_model.dart';
import 'package:clicktorun_flutter/ui/screens/insights/insights_screen.dart';
import 'package:clicktorun_flutter/ui/screens/insights/widgets/all_run_graph.dart';
import 'package:clicktorun_flutter/ui/widgets/appbar.dart';
import 'package:flutter/material.dart';

class GraphScreen extends StatefulWidget {
  final List<RunModel> runList;
  final GraphType graphType;
  const GraphScreen({
    required this.runList,
    required this.graphType,
    Key? key,
  }) : super(key: key);

  @override
  State<GraphScreen> createState() => _GraphScreenState();
}

class _GraphScreenState extends State<GraphScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(title: _getTitle()),
      body: Container(
        color: Theme.of(context).colorScheme.surface,
        padding: const EdgeInsets.all(10),
        child: AllRunGraph(
          runList: widget.runList,
          graphType: widget.graphType,
        ),
      ),
    );
  }

  String _getTitle() {
    switch (widget.graphType) {
      case GraphType.averageSpeed:
        return "Average speed over time";
      case GraphType.distance:
        return "Distance ran over time";
      case GraphType.timeTaken:
        return "Time taken for runs";
    }
  }
}
