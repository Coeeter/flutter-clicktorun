import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class Position {
  String? polylineId;
  double latitude;
  double longitude;
  double speedInMetresPerSecond;
  int timeReachedPositionInMilliseconds;

  Position._({
    this.polylineId,
    required this.latitude,
    required this.longitude,
    required this.speedInMetresPerSecond,
    required this.timeReachedPositionInMilliseconds,
  });

  Position.fromMap(Map<String, dynamic> doc, String polylineId)
      : this._(
          polylineId: polylineId,
          latitude: doc["latitude"],
          longitude: doc["longitude"],
          speedInMetresPerSecond: doc["speed"],
          timeReachedPositionInMilliseconds: doc["timeReached"],
        );

  Position.fromLocationData(LocationData locationData)
      : this._(
          latitude: locationData.latitude!,
          longitude: locationData.longitude!,
          speedInMetresPerSecond: locationData.speed!,
          timeReachedPositionInMilliseconds:
              DateTime.now().millisecondsSinceEpoch,
        );

  LatLng toLatLng() => LatLng(latitude, longitude);

  Map<String, dynamic> toMap() => {
        'latitude': latitude,
        'longitude': longitude,
        'speed': speedInMetresPerSecond,
        'timeReached': timeReachedPositionInMilliseconds,
      };

  @override
  String toString() => "{\n"
      "\t'polylineId': '$polylineId',\n"
      "\t'latitude': $latitude,\n"
      "\t'longitude': $longitude,\n"
      "\t'speed': $speedInMetresPerSecond,\n"
      "\t'timeReachedPositionInMilliseconds': $timeReachedPositionInMilliseconds,\n"
      "}";
}
