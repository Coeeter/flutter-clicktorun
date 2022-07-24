import 'dart:math';
import 'dart:typed_data';

import 'package:clicktorun_flutter/data/model/position_model.dart';
import 'package:clicktorun_flutter/data/model/run_model.dart';
import 'package:clicktorun_flutter/data/repositories/position_repository.dart';
import 'package:clicktorun_flutter/data/repositories/run_repository.dart';
import 'package:clicktorun_flutter/ui/screens/parent/parent_screen.dart';
import 'package:clicktorun_flutter/ui/utils/colors.dart';
import 'package:clicktorun_flutter/ui/utils/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uuid/uuid.dart';

class TrackingMap extends StatefulWidget {
  const TrackingMap({Key? key}) : super(key: key);

  @override
  State<TrackingMap> createState() => TrackingMapState();
}

class TrackingMapState extends State<TrackingMap> {
  final Set<Polyline> _polylines = {};
  GoogleMapController? _controller;
  String lightMode = "";
  String darkMode = "";

  void setPolylines(List<List<LatLng>> runRoute) {
    setState(() {
      _polylines.clear();
      for (var individualRoute in runRoute) {
        _polylines.add(
          Polyline(
            polylineId: PolylineId(const Uuid().v4()),
            visible: true,
            points: individualRoute,
            width: 3,
            color: ClickToRunColors.primary,
          ),
        );
      }
    });
  }

  void animateCamera(LatLng position) {
    _controller!.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: position,
          zoom: 18.5,
        ),
      ),
    );
  }

  void saveRun(RunModel runModel, List<List<Position>> runRoute) async {
    _setLatLngBounds(
      runRoute.map((polyline) {
        return polyline.map((position) => position.toLatLng()).toList();
      }).toList(),
    );
    Uint8List? lightModeImage = await _takeMapSnapshot();
    Uint8List? darkModeImage = await _takeMapSnapshot(Brightness.dark);
    Uuid uuid = const Uuid();
    runModel.id = uuid.v4();
    for (List<Position> positionList in runRoute) {
      String polylineId = uuid.v4();
      for (Position position in positionList) {
        position.polylineId = polylineId;
      }
    }
    bool insertResults = await RunRepository.instance().insertRun(
      runModel,
      lightModeImage!,
      darkModeImage!,
    );
    bool insertrouteResult =
        await PositionRepository.instance().insertPositionList(
      runRoute,
      runModel.id,
    );
    if (!insertResults || !insertrouteResult) {
      return SnackbarUtils(context: context).createSnackbar(
        'Unknown error has occurred',
      );
    }
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const ParentScreen(),
      ),
    );
  }

  void _configureMapType(BuildContext context) {
    _controller?.setMapStyle(
      Theme.of(context).brightness == Brightness.dark ? darkMode : lightMode,
    );
  }

  void _setLatLngBounds(List<List<LatLng>> runRoute) {
    double south = runRoute[0][0].latitude;
    double north = runRoute[0][0].latitude;
    double east = runRoute[0][0].longitude;
    double west = runRoute[0][0].longitude;
    for (List<LatLng> list in runRoute) {
      for (LatLng latLng in list) {
        south = min(south, latLng.latitude);
        north = max(north, latLng.latitude);
        west = min(west, latLng.longitude);
        east = max(east, latLng.longitude);
      }
    }
    LatLngBounds latLngBounds = LatLngBounds(
      southwest: LatLng(south, west),
      northeast: LatLng(north, east),
    );
    _controller?.moveCamera(
      CameraUpdate.newLatLngBounds(
        latLngBounds,
        MediaQuery.of(context).size.width * 0.05,
      ),
    );
  }

  Future<Uint8List?> _takeMapSnapshot([
    Brightness brightness = Brightness.light,
  ]) async {
    _controller?.setMapStyle(
      brightness == Brightness.light ? lightMode : darkMode,
    );
    await Future.delayed(
      const Duration(milliseconds: 500),
    );
    return _controller?.takeSnapshot();
  }

  @override
  void initState() {
    super.initState();
    (() async {
      lightMode = await rootBundle.loadString(
        'assets/map_styles/light_mode.json',
      );
      darkMode = await rootBundle.loadString(
        'assets/map_styles/dark_mode.json',
      );
    })();
  }

  @override
  Widget build(BuildContext context) {
    _configureMapType(context);
    return GoogleMap(
      initialCameraPosition: const CameraPosition(
        target: LatLng(1.3521, 103.8198),
        zoom: 10.0,
      ),
      polylines: _polylines,
      zoomControlsEnabled: false,
      onMapCreated: (googleMapController) {
        _controller = googleMapController;
        _configureMapType(context);
      },
    );
  }
}
