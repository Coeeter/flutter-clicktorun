import 'dart:async';
import 'dart:developer';

import 'package:clicktorun_flutter/data/model/position_model.dart';
import 'package:clicktorun_flutter/data/model/run_model.dart';
import 'package:clicktorun_flutter/data/repositories/auth_repository.dart';
import 'package:clicktorun_flutter/ui/screens/parent/parent_screen.dart';
import 'package:clicktorun_flutter/ui/screens/tracking/widgets/distance.dart';
import 'package:clicktorun_flutter/ui/screens/tracking/widgets/map_widget.dart';
import 'package:clicktorun_flutter/ui/screens/tracking/widgets/timer.dart';
import 'package:clicktorun_flutter/ui/utils/extensions.dart';
import 'package:clicktorun_flutter/ui/widgets/appbar.dart';
import 'package:clicktorun_flutter/ui/widgets/gradient_button.dart';
import 'package:clicktorun_flutter/ui/widgets/loading_container.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:uuid/uuid.dart';

class TrackingScreen extends StatefulWidget {
  const TrackingScreen({Key? key}) : super(key: key);

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  final Location _location = Location();
  final List<List<Position>> _runRoute = [];
  bool _permissionGranted = false;
  bool _takingSnapshot = false;
  bool _isTracking = false;
  bool _isFirstTimeTracking = true;
  int _timeTakenInMilliseconds = 0;
  int _timeStartedInMilliseconds = 0;
  double _distanceRan = 0;

  final GlobalKey<TrackingMapState> _mapKey = GlobalKey();
  final GlobalKey<DistanceTextState> _distanceTextKey = GlobalKey();
  final GlobalKey<TimerTextState> _timerTextKey = GlobalKey();

  Future<bool> _isLocationEnabled() async {
    bool serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) return false;
    }
    PermissionStatus permissionStatus = await _location.hasPermission();
    if (permissionStatus == PermissionStatus.denied) {
      permissionStatus = await _location.requestPermission();
      if (permissionStatus != PermissionStatus.granted) return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(
        title: "Tracking your run",
        actions: [
          Visibility(
            visible: !_isTracking && !_isFirstTimeTracking,
            child: IconButton(
              onPressed: () => _saveRun(),
              icon: const Icon(Icons.save),
            ),
          ),
          IconButton(
            onPressed: () => _closeRun(context),
            icon: const Icon(Icons.close),
          )
        ],
      ),
      body: FutureBuilder<bool>(
        future: _isLocationEnabled(),
        builder: (context, locationIsEnabled) => Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
          ),
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              SizedBox(
                height: _takingSnapshot
                    ? MediaQuery.of(context).size.width / 2
                    : double.infinity,
                child: _handlePermission(
                  locationIsEnabled.hasData && locationIsEnabled.data!,
                ),
              ),
              _takingSnapshot ? _loadingToSaveRun() : _controlPanel(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _loadingToSaveRun() {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Material(
        elevation: 10,
        color: Theme.of(context).colorScheme.surface,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const LoadingContainer(
              overlayVisibility: false,
            ),
            const SizedBox(
              height: 20,
            ),
            Text(
              'Do not close the app',
              style: Theme.of(context).textTheme.headline5,
            ),
            Text(
              'Your run is being saved',
              style: Theme.of(context).textTheme.headline5,
            ),
          ],
        ),
      ),
    );
  }

  void _saveRun() async {
    if (_runRoute.isEmpty || _runRoute[0].length < 2 || _takingSnapshot) return;
    setState(() {
      _isTracking = false;
      _takingSnapshot = true;
    });
    await Future.delayed(const Duration(milliseconds: 200));
    _location.enableBackgroundMode(enable: false);
    double distanceRanInKilometres = _distanceRan / 1000;
    double timeTakenInHours = _timeTakenInMilliseconds / 1000 / 60 / 60;
    RunModel runModel = RunModel(
      id: '',
      email: AuthRepository.instance().currentUser!.email!,
      darkModeImage: "maps/dark-${const Uuid().v4()}",
      lightModeImage: "maps/light-${const Uuid().v4()}",
      timeStartedInMilliseconds: _timeStartedInMilliseconds,
      timeTakenInMilliseconds: _timeTakenInMilliseconds,
      distanceRanInMetres: _distanceRan,
      averageSpeed: distanceRanInKilometres / timeTakenInHours,
    );
    _mapKey.currentState!.saveRun(runModel, _runRoute);
  }

  void _closeRun(BuildContext context) {
    if (_takingSnapshot) return;
    if (_isFirstTimeTracking) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const ParentScreen(),
        ),
      );
      return;
    }
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Cancel the run?"),
        content: const Text(
          "Are you sure you want to delete the current run and lose all its data forever?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("No"),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _isTracking = false;
              });
              _location.enableBackgroundMode(enable: false);
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => const ParentScreen(),
                ),
              );
            },
            child: const Text("Yes"),
          ),
        ],
      ),
    );
  }

  Widget _controlPanel() {
    if (!_permissionGranted) return Container();
    return FittedBox(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Container(
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.light
                ? const Color.fromARGB(207, 255, 255, 255)
                : const Color(0x80000000),
            borderRadius: const BorderRadius.all(
              Radius.circular(999),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TimerText(key: _timerTextKey),
              GradientButton(
                text: _isTracking ? "Pause" : "Start",
                onPressed: _handleClick,
                width: (MediaQuery.of(context).size.width - 20) / 3,
                padding: const EdgeInsets.all(10),
              ),
              DistanceText(key: _distanceTextKey),
            ],
          ),
        ),
      ),
    );
  }

  void _handleClick() {
    setState(() {
      _isTracking = !_isTracking;
      if (_isFirstTimeTracking) {
        _isFirstTimeTracking = false;
        _timeStartedInMilliseconds = DateTime.now().millisecondsSinceEpoch;
      }
      if (!_isTracking) return;
      _startTimer();
      _location.enableBackgroundMode();
      _setUpNotification();
      _runRoute.add([]);
    });
  }

  void _setUpNotification([
    String subtitle = "00:00:00",
  ]) {
    late String distanceRan;
    if (_distanceRan < 1000) {
      distanceRan = "${_distanceRan.toInt()}m";
    } else {
      distanceRan = "${_distanceRan / 1000}km";
    }
    _location.changeNotificationOptions(
      title: 'You have ran $distanceRan, keep it up!',
      iconName: 'ic_shoes',
      subtitle: subtitle,
      onTapBringToFront: true,
    );
  }

  Widget _handlePermission(bool permissionGranted) {
    _permissionGranted = permissionGranted;
    if (!_permissionGranted) {
      return const Text("No Permission has been granted");
    }
    _setLocationListener();
    return TrackingMap(
      key: _mapKey,
    );
  }

  void _setLocationListener() {
    _location.onLocationChanged.distinct().listen((locationData) {
      if (!_isTracking) return;
      _runRoute.last.add(Position.fromLocationData(locationData));
      List<List<LatLng>> polylines = _runRoute.map((polyline) {
        return polyline.map((position) => position.toLatLng()).toList();
      }).toList();
      _distanceRan = polylines.calculateDistance();
      _distanceTextKey.currentState!.setDistance(_distanceRan);
      _mapKey.currentState!.setPolylines(polylines);
      _mapKey.currentState!.animateCamera(polylines.last.last);
    });
  }

  void _startTimer() {
    Timer.periodic(
      const Duration(
        seconds: 1,
      ),
      (timer) {
        if (!_isTracking) return timer.cancel();
        _timeTakenInMilliseconds += 1000;
        var timeTaken = _timeTakenInMilliseconds.toTimeString();
        _timerTextKey.currentState!.setText(timeTaken);
        _setUpNotification(timeTaken);
      },
    );
  }
}
