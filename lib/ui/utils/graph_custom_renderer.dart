import 'dart:math';
import 'package:charts_flutter/flutter.dart';
import 'package:charts_flutter/src/text_element.dart' as textelement;
import 'package:charts_flutter/src/text_style.dart' as style;

class CustomRenderer extends CircleSymbolRenderer {
  String xAxisName;
  String yAxisName;
  String? xAxisValue;
  String? yAxisValue;
  bool isNightMode;
  CustomRenderer({
    required this.xAxisName,
    required this.yAxisName,
    required this.isNightMode,
  });

  @override
  void paint(
    ChartCanvas canvas,
    Rectangle<num> bounds, {
    List<int>? dashPattern,
    Color? fillColor,
    FillPatternType? fillPattern,
    Color? strokeColor,
    double? strokeWidthPx,
  }) {
    super.paint(
      canvas,
      bounds,
      dashPattern: dashPattern,
      fillColor: fillColor,
      fillPattern: fillPattern,
      strokeColor: strokeColor,
      strokeWidthPx: strokeWidthPx,
    );
    String text = "$yAxisValue $yAxisName\n$xAxisValue $xAxisName";
    canvas.drawRect(
      Rectangle(
        bounds.left - 5,
        bounds.top - 60,
        bounds.width + text.length * 5,
        bounds.height + 40,
      ),
      fill: isNightMode ? Color.white : Color.black,
    );
    var textStyle = style.TextStyle();
    textStyle.color = isNightMode ? Color.black : Color.white;
    textStyle.fontSize = 15;
    canvas.drawText(
      textelement.TextElement(
        text,
        style: textStyle,
      ),
      (bounds.left).round(),
      (bounds.top - 50).round(),
    );
  }
}
