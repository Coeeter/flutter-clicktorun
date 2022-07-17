import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DistanceText extends StatefulWidget {
  String text;
  double distanceRanInMetres = 0.0;
  final _DistanceTextState _state = _DistanceTextState();

  DistanceText({
    required this.text,
  });

  void setDistance(List<List<LatLng>> route) => _state.setDistance(route);

  @override
  State<DistanceText> createState() => _state;
}

class _DistanceTextState extends State<DistanceText> {
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

  void setDistance(List<List<LatLng>> route) {
    double distanceRan = 0;
    for (List<LatLng> list in route) {
      for (int i = 0; i < list.length - 1; i++) {
        distanceRan += _calculateDistance(list[i], list[i + 1]);
      }
    }
    setState(() {
      widget.distanceRanInMetres = distanceRan;
    });
  }

  int _calculateDistance(LatLng firstLatLng, LatLng secondLatLng) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((secondLatLng.latitude - firstLatLng.latitude) * p) / 2 +
        c(firstLatLng.latitude * p) *
            c(secondLatLng.latitude * p) *
            (1 - c((secondLatLng.longitude - firstLatLng.longitude) * p)) /
            2;
    return (12742 * asin(sqrt(a)) * 1000).toInt();
  }

  String _getDistanceString() {
    if (widget.distanceRanInMetres < 1000) {
      return "${widget.distanceRanInMetres.toInt()}m";
    }
    return "${(widget.distanceRanInMetres / 1000).toStringAsFixed(3)}km";
  }
}
