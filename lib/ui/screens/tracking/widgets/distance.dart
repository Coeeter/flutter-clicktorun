import 'package:flutter/material.dart';

class DistanceText extends StatefulWidget {
  const DistanceText({Key? key}) : super(key: key);

  @override
  State<DistanceText> createState() => DistanceTextState();
}

class DistanceTextState extends State<DistanceText> {
  double distanceRanInMetres = 0.0;

  void setDistance(double distanceRan) {
    setState(() {
      distanceRanInMetres = distanceRan;
    });
  }

  String _getDistanceString() {
    if (distanceRanInMetres < 1000) {
      return "${distanceRanInMetres.toInt()}m";
    }
    return "${(distanceRanInMetres / 1000).toStringAsFixed(3)}km";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: (MediaQuery.of(context).size.width - 20) / 3,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          _getDistanceString(),
          style: TextStyle(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Colors.black,
            fontSize: 20,
          ),
        ),
      ),
    );
  }
}
