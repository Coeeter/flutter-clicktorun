import 'package:charts_flutter/flutter.dart' as charts;
import 'package:clicktorun_flutter/data/model/run_model.dart';
import 'package:clicktorun_flutter/ui/utils/colors.dart';
import 'package:flutter/material.dart';

class AverageSpeedOverTimeGraph extends StatefulWidget {
  final List<RunModel> runList;
  const AverageSpeedOverTimeGraph({
    required this.runList,
    Key? key,
  }) : super(key: key);

  @override
  State<AverageSpeedOverTimeGraph> createState() =>
      AverageSpeedOverTimeGraphState();
}

class AverageSpeedOverTimeGraphState extends State<AverageSpeedOverTimeGraph> {
  double? selectedSpeed;
  final List<String> _months = [
    "January",
    "February",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December"
  ];

  @override
  Widget build(BuildContext context) {
    charts.Color? labelColor = charts.ColorUtil.fromDartColor(
      Theme.of(context).brightness == Brightness.dark
          ? Colors.white
          : Colors.black,
    );
    List<charts.Series<RunModel, String>> seriesList = [
      charts.Series(
        id: "Average speed over time",
        data: widget.runList,
        domainFn: (RunModel runModel, _) {
          DateTime dateRan = DateTime.fromMillisecondsSinceEpoch(
            runModel.timeStartedInMilliseconds,
          ).toLocal();
          return "${dateRan.hour < 10 ? '0' + dateRan.hour.toString() : dateRan.hour}:${dateRan.minute < 10 ? '0' + dateRan.minute.toString() : dateRan.minute}:${dateRan.second < 10 ? '0' + dateRan.second.toString() : dateRan.second}\n"
              "${dateRan.day} ${_months[dateRan.month - 1]}";
        },
        measureFn: (RunModel runModel, _) => runModel.averageSpeed,
        colorFn: (_, __) => charts.ColorUtil.fromDartColor(
          ClickToRunColors.primary,
        ),
      ),
    ];
    return charts.BarChart(
      seriesList,
      animate: true,
      behaviors: [
        charts.SlidingViewport(),
        charts.PanAndZoomBehavior(),
        if (selectedSpeed != null)
          charts.ChartTitle(
            selectedSpeed!.toStringAsFixed(2) + " km/h",
            behaviorPosition: charts.BehaviorPosition.top,
            titleOutsideJustification:
                charts.OutsideJustification.middleDrawArea,
            titleStyleSpec: charts.TextStyleSpec(
              color: charts.ColorUtil.fromDartColor(
                Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black,
              ),
            ),
          ),
      ],
      domainAxis: charts.OrdinalAxisSpec(
        viewport: charts.OrdinalViewport("", 5),
        renderSpec: charts.GridlineRendererSpec(
          labelStyle: charts.TextStyleSpec(
            color: labelColor,
          ),
        ),
      ),
      primaryMeasureAxis: charts.NumericAxisSpec(
        renderSpec: charts.GridlineRendererSpec(
          labelStyle: charts.TextStyleSpec(
            color: labelColor,
          ),
        ),
      ),
      selectionModels: [
        charts.SelectionModelConfig(
          type: charts.SelectionModelType.info,
          changedListener: (charts.SelectionModel<String> selectionModel) {
            List<charts.SeriesDatum<String>> selectedDatum =
                selectionModel.selectedDatum;
            setState(() {
              selectedSpeed =
                  (selectedDatum.first.datum as RunModel).averageSpeed;
            });
          },
        )
      ],
    );
  }
}
