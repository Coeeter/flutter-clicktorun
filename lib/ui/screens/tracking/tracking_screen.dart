import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:clicktorun_flutter/data/model/run_model.dart';
import 'package:clicktorun_flutter/data/repositories/auth_repository.dart';
import 'package:clicktorun_flutter/data/repositories/run_repository.dart';
import 'package:clicktorun_flutter/ui/screens/parent/parent_screen.dart';
import 'package:clicktorun_flutter/ui/screens/tracking/widgets/distance.dart';
import 'package:clicktorun_flutter/ui/screens/tracking/widgets/timer.dart';
import 'package:clicktorun_flutter/ui/utils/colors.dart';
import 'package:clicktorun_flutter/ui/utils/extensions.dart';
import 'package:clicktorun_flutter/ui/utils/snackbar.dart';
import 'package:clicktorun_flutter/ui/widgets/appbar.dart';
import 'package:clicktorun_flutter/ui/widgets/gradient_button.dart';
import 'package:clicktorun_flutter/ui/widgets/loading_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:uuid/uuid.dart';

class TrackingScreen extends StatefulWidget {
  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  GoogleMapController? _controller;
  String lightMode = "";
  String darkMode = "";

  bool _permissionGranted = false;
  final Location _location = Location();
  final Set<Polyline> _polylines = {};
  final List<List<LatLng>> _runRoute = [];
  bool _takingSnapshot = false;
  bool _isTracking = false;
  bool _isFirstTimeTracking = true;
  int _timeTakenInMilliseconds = 0;
  int _timeStartedInMilliseconds = 0;

  final TimerText _timerTextView = TimerText(text: "00:00:00");
  final DistanceText _distanceText = DistanceText(text: "0m");

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
    return Scaffold(
      appBar: ClickToRunAppbar("Tracking your run").getAppBar(
        actions: [
          if (!_isTracking && !_isFirstTimeTracking)
            IconButton(
              onPressed: () => _saveRun(),
              icon: const Icon(Icons.save),
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
            LoadingContainer(
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
    _controller?.moveCamera(
      CameraUpdate.newLatLngBounds(
        _getBounds(_runRoute),
        MediaQuery.of(context).size.width * 0.05,
      ),
    );

    _controller?.setMapStyle(lightMode);
    await Future.delayed(const Duration(milliseconds: 500));
    Uint8List? lightModeImage = await _controller?.takeSnapshot();

    _controller?.setMapStyle(darkMode);
    await Future.delayed(const Duration(milliseconds: 500));
    Uint8List? darkModeImage = await _controller?.takeSnapshot();

    String lightModeImageName = "maps/light-${const Uuid().v4()}";
    String darkModeImageName = "maps/dark-${const Uuid().v4()}";
    double averageSpeed = (_distanceText.distanceRanInMetres / 1000) /
        (_timeTakenInMilliseconds / 1000 / 60 / 60);
    RunModel runModel = RunModel(
      id: '',
      email: AuthRepository.instance().currentUser!.email!,
      darkModeImage: darkModeImageName,
      lightModeImage: lightModeImageName,
      timeStartedInMilliseconds: _timeStartedInMilliseconds,
      timeTakenInMilliseconds: _timeTakenInMilliseconds,
      distanceRanInMetres: _distanceText.distanceRanInMetres,
      averageSpeed: averageSpeed,
    );

    await RunRepository.instance().insertRun(
      runModel,
      lightModeImage!,
      darkModeImage!,
    )
        ? Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => ParentScreen(),
            ),
          )
        : SnackbarUtils(context: context).createSnackbar(
            'Unknown error has occurred',
          );
  }

  void _closeRun(BuildContext context) {
    if (_takingSnapshot) return;
    if (_isFirstTimeTracking) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ParentScreen(),
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
                  builder: (_) => ParentScreen(),
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
                : const Color(0xff80000000),
            borderRadius: const BorderRadius.all(
              Radius.circular(999),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _timerTextView,
              GradientButton(
                text: _isTracking ? "Pause" : "Start",
                onPressed: _handleClick,
                width: (MediaQuery.of(context).size.width - 20) / 3,
                padding: const EdgeInsets.all(10),
              ),
              _distanceText,
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
    _location.changeNotificationOptions(
      title: 'Tracking your run',
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
    return GoogleMap(
      initialCameraPosition: const CameraPosition(
        target: LatLng(1.3521, 103.8198),
        zoom: 10.0,
      ),
      polylines: _polylines,
      zoomControlsEnabled: false,
      onMapCreated: (controller) {
        _controller = controller;
        _configureMapType(context);
      },
    );
  }

  void _setLocationListener() {
    _location.onLocationChanged.listen((locationData) {
      if (!_isTracking) return;
      _runRoute.last.add(
        LatLng(
          locationData.latitude!,
          locationData.longitude!,
        ),
      );
      _distanceText.setDistance(_runRoute);
      setState(() {
        _polylines.clear();
        for (var individualRoute in _runRoute) {
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
      _controller!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: _runRoute.last.last,
            zoom: 18.5,
          ),
        ),
      );
    });
  }

  LatLngBounds _getBounds(List<List<LatLng>> route) {
    double south = route[0][0].latitude,
        north = route[0][0].latitude,
        west = route[0][0].longitude,
        east = route[0][0].longitude;
    for (List<LatLng> list in route) {
      for (LatLng latLng in list) {
        south = min(south, latLng.latitude);
        north = max(north, latLng.latitude);
        west = min(west, latLng.longitude);
        east = max(east, latLng.longitude);
      }
    }
    return LatLngBounds(
      southwest: LatLng(south, west),
      northeast: LatLng(north, east),
    );
  }

  void _startTimer() {
    Timer.periodic(
      const Duration(
        seconds: 1,
      ),
      (timer) {
        if (!_isTracking) return timer.cancel();
        _timeTakenInMilliseconds += 1000;
        _timerTextView.setText(_timeTakenInMilliseconds.toTimeString());
        _setUpNotification(_timeTakenInMilliseconds.toTimeString());
      },
    );
  }

  void _configureMapType(BuildContext context) => _controller?.setMapStyle(
        Theme.of(context).brightness == Brightness.dark ? darkMode : lightMode,
      );
}
