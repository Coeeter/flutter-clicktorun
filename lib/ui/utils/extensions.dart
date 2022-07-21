import 'dart:math';

import 'package:google_maps_flutter/google_maps_flutter.dart';

extension Utils on int {
  String toTimeString() {
    String seconds = (this ~/ 1000 % 60).toString();
    String minutes = (this ~/ 1000 ~/ 60 % 60).toString();
    String hours = (this ~/ 1000 ~/ 60 ~/ 60).toString();
    if (seconds.length < 2) seconds = '0$seconds';
    if (minutes.length < 2) minutes = '0$minutes';
    if (hours.length < 2) hours = '0$hours';
    return '$hours:$minutes:$seconds';
  }
}

extension Calculation on List<List<LatLng>> {
  double calculateDistance() {
    double distanceRan = 0;
    for (List<LatLng> list in this) {
      for (int i = 0; i < list.length - 1; i++) {
        LatLng firstLatLng = list[i];
        LatLng secondLatLng = list[i + 1];
        var p = 0.017453292519943295;
        var a = 0.5 -
            cos((secondLatLng.latitude - firstLatLng.latitude) * p) / 2 +
            cos(firstLatLng.latitude * p) *
                cos(secondLatLng.latitude * p) *
                (1 -
                    cos((secondLatLng.longitude - firstLatLng.longitude) * p)) /
                2;
        distanceRan += (12742 * asin(sqrt(a)) * 1000).toInt();
      }
    }
    return distanceRan;
  }
}
