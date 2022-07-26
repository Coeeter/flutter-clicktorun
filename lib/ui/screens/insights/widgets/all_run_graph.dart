import 'dart:math';

import 'package:charts_flutter/flutter.dart' as charts;
import 'package:clicktorun_flutter/data/model/run_model.dart';
import 'package:clicktorun_flutter/ui/screens/insights/insights_screen.dart';
import 'package:clicktorun_flutter/ui/utils/colors.dart';
import 'package:clicktorun_flutter/ui/utils/extensions.dart';
import 'package:flutter/material.dart';

class AllRunGraph extends StatefulWidget {
  final List<RunModel> runList;
  final bool preview;
  final GraphType graphType;
  const AllRunGraph({
    required this.runList,
    required this.graphType,
    this.preview = false,
    Key? key,
  }) : super(key: key);

  @override
  State<AllRunGraph> createState() => AllRunGraphState();
}

class AllRunGraphState extends State<AllRunGraph> {
  final GlobalKey<SelectedTextState> _textKey = GlobalKey();
  Map<GraphType, double Function(RunModel, int?)> _measureFunctions = {};
  double _maxValue = 0;

  @override
  void initState() {
    _measureFunctions = {
      GraphType.averageSpeed: (runModel, _) => runModel.averageSpeed,
      GraphType.distance: (runModel, _) => runModel.distanceRanInMetres / 1000,
      GraphType.timeTaken: (runModel, _) {
        String units = _getUnits();
        if (units == "s") {
          return runModel.timeTakenInMilliseconds / 1000;
        }
        if (units == 'min') {
          return runModel.timeTakenInMilliseconds / 1000 / 60;
        }
        return runModel.timeTakenInMilliseconds / 1000 / 60 / 60;
      }
    };
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var labelColor = charts.ColorUtil.fromDartColor(
      Theme.of(context).brightness == Brightness.dark
          ? Colors.white
          : Colors.black,
    );
    var data = widget.preview
        ? widget.runList.sublist(widget.runList.length - 5)
        : widget.runList;
    switch (widget.graphType) {
      case GraphType.distance:
        {
          _maxValue = data
              .map(
                (e) => _measureFunctions[widget.graphType]!(e, null),
              )
              .reduce(max);
          break;
        }
      case GraphType.averageSpeed:
        {
          _maxValue = data
              .map(
                (e) => _measureFunctions[widget.graphType]!(e, null),
              )
              .reduce(max)
              .toDouble();
          break;
        }
      case GraphType.timeTaken:
        {
          _maxValue = data
              .map(
                (e) => _measureFunctions[widget.graphType]!(e, null),
              )
              .reduce(max)
              .toDouble();
          break;
        }
    }
    var seriesList = [
      charts.Series(
        id: "${widget.graphType}-graph",
        data: data,
        domainFn: (RunModel runModel, _) {
          DateTime dateRan = DateTime.fromMillisecondsSinceEpoch(
            runModel.timeStartedInMilliseconds,
          ).toLocal();
          String month = [
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
            "December",
          ][dateRan.month - 1];
          String hour = dateRan.hour < 10
              ? '0' + dateRan.hour.toString()
              : dateRan.hour.toString();
          String minute = dateRan.minute < 10
              ? '0' + dateRan.minute.toString()
              : dateRan.minute.toString();
          String seconds = dateRan.second < 10
              ? '0' + dateRan.second.toString()
              : dateRan.second.toString();
          return "$hour:$minute:$seconds\n${dateRan.day} $month";
        },
        measureFn: _measureFunctions[widget.graphType]!,
        colorFn: (_, __) => charts.ColorUtil.fromDartColor(
          ClickToRunColors.primary,
        ),
      ),
    ];
    return Padding(
      padding: widget.preview
          ? const EdgeInsets.all(20)
          : const EdgeInsets.only(bottom: 40, left: 40, right: 10, top: 10),
      child: Column(
        children: [
          SelectedText(key: _textKey),
          Expanded(
            child: ShaderMask(
              shaderCallback: (Rect bounds) {
                return const LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    ClickToRunColors.primary,
                    ClickToRunColors.secondary,
                  ],
                ).createShader(bounds);
              },
              blendMode: BlendMode.srcATop,
              child: charts.BarChart(
                seriesList,
                animate: true,
                layoutConfig: charts.LayoutConfig(
                  leftMarginSpec: charts.MarginSpec.fixedPixel(0),
                  topMarginSpec: charts.MarginSpec.fixedPixel(0),
                  rightMarginSpec: charts.MarginSpec.fixedPixel(0),
                  bottomMarginSpec: charts.MarginSpec.fixedPixel(0),
                ),
                behaviors: [
                  charts.SlidingViewport(),
                  charts.PanAndZoomBehavior(),
                ],
                domainAxis: charts.OrdinalAxisSpec(
                  viewport: charts.OrdinalViewport("", 5),
                  renderSpec: widget.preview
                      ? const charts.NoneRenderSpec()
                      : charts.GridlineRendererSpec(
                          labelStyle: charts.TextStyleSpec(
                            color: labelColor,
                            fontSize: 15,
                          ),
                          lineStyle: charts.LineStyleSpec(
                            color: labelColor,
                          ),
                        ),
                ),
                primaryMeasureAxis: charts.NumericAxisSpec(
                  tickProviderSpec: widget.graphType == GraphType.timeTaken
                      ? null
                      : charts.StaticNumericTickProviderSpec(
                          _getTickSpec(),
                        ),
                  renderSpec: widget.preview
                      ? const charts.NoneRenderSpec()
                      : charts.GridlineRendererSpec(
                          labelStyle: charts.TextStyleSpec(
                            color: labelColor,
                            fontSize: 15,
                          ),
                          lineStyle: charts.LineStyleSpec(
                            color: labelColor,
                          ),
                        ),
                ),
                selectionModels: [
                  charts.SelectionModelConfig(
                    type: charts.SelectionModelType.info,
                    changedListener: (
                      charts.SelectionModel<String> selectionModel,
                    ) {
                      if (widget.preview) return setState(() {});
                      var selectedDatum = selectionModel.selectedDatum;
                      _textKey.currentState?.setText(
                        _getTitle(selectedDatum.first.datum),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getTitle(RunModel runModel) {
    switch (widget.graphType) {
      case GraphType.averageSpeed:
        {
          return "${runModel.averageSpeed.toStringAsFixed(2)} km/h";
        }
      case GraphType.distance:
        {
          if (runModel.distanceRanInMetres < 1000) {
            return "${runModel.distanceRanInMetres.toInt()} m";
          }
          return "${(runModel.distanceRanInMetres / 1000)} km";
        }
      case GraphType.timeTaken:
        {
          String timeTaken = runModel.timeTakenInMilliseconds.toTimeString();
          String seconds = "${int.parse(timeTaken.split(':')[2])}s";
          String minutes = "${int.parse(timeTaken.split(':')[1])}min ";
          String hours = "${int.parse(timeTaken.split(':')[0])}hr ";
          if (hours == "0hr ") hours = "";
          if (minutes == "0min ") minutes = "";
          if (seconds == "0s") seconds = "";
          return "$hours$minutes$seconds";
        }
    }
  }

  String _getUnits() {
    int secondCount = 0;
    int minuteCount = 0;
    int hourCount = 0;
    for (var runModel in widget.runList) {
      int minutes = runModel.timeTakenInMilliseconds ~/ 1000 ~/ 60;
      int hours = runModel.timeTakenInMilliseconds ~/ 1000 ~/ 60 ~/ 60;
      if (hours != 0) {
        hourCount++;
        continue;
      }
      if (minutes != 0) {
        minuteCount++;
        continue;
      }
      secondCount++;
    }
    if (secondCount > minuteCount && secondCount > hourCount) return 's';
    if (minuteCount > secondCount && minuteCount > hourCount) return 'min';
    return 'hour';
  }

  List<charts.TickSpec<num>> _getTickSpec() {
    List<charts.TickSpec<num>> tickSpecList = [];
    _maxValue = _maxValue * 1.2;
    for (double value = 0; value <= _maxValue; value += _maxValue * 0.1) {
      tickSpecList.add(
        charts.TickSpec(
          value,
          label: value.toStringAsFixed(1),
        ),
      );
    }
    return tickSpecList;
  }
}

class SelectedText extends StatefulWidget {
  const SelectedText({Key? key}) : super(key: key);

  @override
  State<SelectedText> createState() => SelectedTextState();
}

class SelectedTextState extends State<SelectedText> {
  String? _text;

  void setText(String value) {
    setState(() {
      _text = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_text == null) return Container();
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Text(
        _text!,
        style: Theme.of(context)
            .textTheme
            .headline5!
            .copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }
}
