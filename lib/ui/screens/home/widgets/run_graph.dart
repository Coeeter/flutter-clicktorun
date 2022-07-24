import 'package:charts_flutter/flutter.dart' as charts;
import 'package:clicktorun_flutter/data/model/position_model.dart';
import 'package:clicktorun_flutter/ui/utils/graph_custom_renderer.dart';
import 'package:flutter/material.dart';

class RunGraph extends StatefulWidget {
  final List<charts.Series<Position, num>> seriesList;
  final String cardTitle;
  final String yAxisLabel;
  final String xAxisLabel;
  final String Function(Position) getXAxisValue;
  final String Function(Position) getYAxisValue;

  const RunGraph({
    required this.seriesList,
    required this.cardTitle,
    required this.yAxisLabel,
    required this.xAxisLabel,
    required this.getXAxisValue,
    required this.getYAxisValue,
    Key? key,
  }) : super(key: key);

  @override
  State<RunGraph> createState() => RunGraphState();
}

class RunGraphState extends State<RunGraph> {
  String currentXAxisValue = '';
  String currentYAxisValue = '';

  @override
  Widget build(BuildContext context) {
    charts.Color? labelColor = charts.ColorUtil.fromDartColor(
      Theme.of(context).brightness == Brightness.dark
          ? Colors.white
          : Colors.black,
    );
    CustomRenderer customRenderer = CustomRenderer(
      isNightMode: Theme.of(context).brightness == Brightness.dark,
      xAxisName: widget.xAxisLabel,
      yAxisName: widget.yAxisLabel,
    );
    return Card(
      elevation: 5,
      child: Container(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Text(
              widget.cardTitle,
              style: Theme.of(context).textTheme.headline5,
            ),
            SizedBox(
              height: MediaQuery.of(context).size.width - 40,
              child: charts.LineChart(
                widget.seriesList,
                animate: true,
                behaviors: [
                  charts.SlidingViewport(),
                  charts.PanAndZoomBehavior(),
                  charts.LinePointHighlighter(
                    symbolRenderer: customRenderer,
                  ),
                  charts.ChartTitle(
                    widget.xAxisLabel,
                    behaviorPosition: charts.BehaviorPosition.bottom,
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
                  charts.ChartTitle(
                    widget.yAxisLabel,
                    behaviorPosition: charts.BehaviorPosition.start,
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
                domainAxis: charts.NumericAxisSpec(
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
                  tickProviderSpec: const charts.BasicNumericTickProviderSpec(
                    zeroBound: false,
                  ),
                ),
                selectionModels: [
                  charts.SelectionModelConfig(
                    type: charts.SelectionModelType.info,
                    changedListener: (charts.SelectionModel selectionModel) {
                      var selectedDatum = selectionModel.selectedDatum;
                      customRenderer.xAxisValue = widget.getXAxisValue(
                        selectedDatum.first.datum as Position,
                      );
                      customRenderer.yAxisValue = widget.getYAxisValue(
                        selectedDatum.first.datum as Position,
                      );
                    },
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
