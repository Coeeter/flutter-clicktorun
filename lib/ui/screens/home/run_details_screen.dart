import 'dart:math';

import 'package:charts_flutter/flutter.dart' as charts;
import 'package:clicktorun_flutter/data/model/position_model.dart';
import 'package:clicktorun_flutter/data/model/run_model.dart';
import 'package:clicktorun_flutter/data/repositories/position_repository.dart';
import 'package:clicktorun_flutter/data/repositories/run_repository.dart';
import 'package:clicktorun_flutter/ui/screens/home/widgets/run_graph.dart';
import 'package:clicktorun_flutter/ui/utils/colors.dart';
import 'package:clicktorun_flutter/ui/utils/extensions.dart';
import 'package:clicktorun_flutter/ui/widgets/appbar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shimmer/shimmer.dart';
import 'package:uuid/uuid.dart';

class RunDetailsScreen extends StatefulWidget {
  final RunModel runModel;
  final String imageUrl;
  const RunDetailsScreen({
    required this.runModel,
    required this.imageUrl,
    Key? key,
  }) : super(key: key);

  @override
  State<RunDetailsScreen> createState() => _RunDetailsScreenState();
}

class _RunDetailsScreenState extends State<RunDetailsScreen> {
  bool _isLoading = false;
  GoogleMapController? _controller;
  String? lightMode;
  String? darkMode;

  Color get _baseColor {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[800]!
        : Colors.grey[300]!;
  }

  Color get _highlightColor {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[600]!
        : Colors.grey[100]!;
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
    return Scaffold(
      appBar: CustomAppbar(
        title: 'Details of run',
        actions: [
          IconButton(
            onPressed: () async {
              setState(() {
                _isLoading = true;
              });
              await RunRepository.instance().deleteRun([
                widget.runModel.id,
              ]);
              await PositionRepository.instance().deleteRunRoute(
                widget.runModel.id,
              );
              Navigator.pop(context);
            },
            icon: const Icon(Icons.delete),
          ),
        ],
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Stack(
        children: [
          _getMainBody(context),
          Visibility(
            visible: _isLoading,
            child: Container(
              alignment: Alignment.center,
              color: Theme.of(context).colorScheme.surface,
              child: const CircularProgressIndicator(
                color: ClickToRunColors.secondary,
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _getMainBody(BuildContext context) {
    return FutureBuilder<List<List<Position>>?>(
      future: PositionRepository.instance().getRunRoute(widget.runModel.id),
      builder: (context, snapshot) {
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              Hero(
                tag: 'image-${widget.runModel.id}',
                child: _getMap(context, snapshot),
              ),
              _getHeader(context, "Run data"),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                ),
                child: Column(
                  children: [
                    _getValue(
                      context,
                      'Distance ran',
                      _getdistance,
                    ),
                    const SizedBox(height: 10),
                    _getValue(
                      context,
                      'Time taken',
                      widget.runModel.timeTakenInMilliseconds.toTimeString(),
                    ),
                    const SizedBox(height: 10),
                    _getValue(
                      context,
                      'Average speed',
                      "${widget.runModel.averageSpeed.toStringAsFixed(2)} km/h",
                    ),
                  ],
                ),
              ),
              _getHeader(context, 'Graphs'),
              Container(
                padding: const EdgeInsets.all(15),
                clipBehavior: Clip.none,
                child: _getGraph(context, snapshot),
              ),
            ],
          ),
        );
      },
    );
  }

  String get _getdistance {
    if (widget.runModel.distanceRanInMetres > 1000) {
      return "${widget.runModel.distanceRanInMetres / 1000} km";
    }
    return "${widget.runModel.distanceRanInMetres.toInt()} m";
  }

  Column _getHeader(
    BuildContext context,
    String text,
  ) {
    return Column(
      children: [
        Container(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.only(
            top: 15,
            left: 15,
          ),
          child: Text(
            text,
            style: Theme.of(context).textTheme.headline5!.copyWith(
                  fontSize: 40,
                ),
          ),
        ),
        Container(
          width: MediaQuery.of(context).size.width - 30,
          height: 2,
          color: ClickToRunColors.primary,
        ),
      ],
    );
  }

  Widget _getGraph(
    BuildContext context,
    AsyncSnapshot<List<List<Position>>?> snapshot,
  ) {
    if (snapshot.connectionState == ConnectionState.waiting ||
        !snapshot.hasData) {
      return SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            Shimmer.fromColors(
              child: Container(
                width: MediaQuery.of(context).size.width - 50,
                height: MediaQuery.of(context).size.width + 10,
                color: Theme.of(context).colorScheme.surface,
              ),
              baseColor: _baseColor,
              highlightColor: _highlightColor,
            ),
            const SizedBox(width: 10),
            Shimmer.fromColors(
              child: Container(
                width: MediaQuery.of(context).size.width - 50,
                height: MediaQuery.of(context).size.width + 10,
                color: Theme.of(context).colorScheme.surface,
              ),
              baseColor: _baseColor,
              highlightColor: _highlightColor,
            ),
          ],
        ),
      );
    }
    List<Position> positionList = [];
    for (var listOfPositions in snapshot.data!) {
      positionList.addAll(listOfPositions);
    }
    String xUnits = "seconds";
    var timeList =
        widget.runModel.timeTakenInMilliseconds.toTimeString().split(':');
    if (int.parse(timeList[1]) != 0 && int.parse(timeList[1]) >= 5) {
      xUnits = "minutes";
    }
    if (int.parse(timeList[0]) != 0 && int.parse(timeList[0]) >= 5) {
      xUnits = "hours";
    }
    if (xUnits != "seconds") {
      int timeTaken;
      for (int i = positionList.length - 1; i > 0; i--) {
        var currentPosition = positionList[i];
        var previousPosition = positionList[i - 1];
        timeTaken = currentPosition.timeReachedPositionInMilliseconds -
            widget.runModel.timeStartedInMilliseconds;
        timeTaken = timeTaken ~/ 1000 ~/ 60;
        int nextTimeTaken = previousPosition.timeReachedPositionInMilliseconds -
            widget.runModel.timeStartedInMilliseconds;
        nextTimeTaken = nextTimeTaken ~/ 1000 ~/ 60;
        if (timeTaken == nextTimeTaken) {
          if (previousPosition.speedInMetresPerSecond >
              currentPosition.speedInMetresPerSecond) {
            positionList.removeAt(i);
            continue;
          }
          positionList.removeAt(i - 1);
        }
      }
    }
    String yUnits = widget.runModel.distanceRanInMetres > 1000 ? "km" : "m";
    List<charts.Series<Position, num>> distanceSeriesList = [
      charts.Series(
        id: 'Distance Travelled over time',
        data: positionList,
        domainFn: (position, _) => timeDomainFunction(position, xUnits),
        measureFn: (_, index) =>
            distanceMeasureFunction(index, positionList, yUnits),
        colorFn: (_, __) => charts.ColorUtil.fromDartColor(
          ClickToRunColors.primary,
        ),
      )
    ];
    List<charts.Series<Position, num>> speedSeriesList = [
      charts.Series(
        id: 'Speed over time',
        data: positionList,
        domainFn: (position, _) => timeDomainFunction(position, xUnits),
        measureFn: (position, _) => position.speedInMetresPerSecond * 3.6,
        colorFn: (_, __) => charts.ColorUtil.fromDartColor(
          ClickToRunColors.primary,
        ),
      ),
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width - 50,
            child: RunGraph(
              cardTitle: "Distance ran over Time",
              yAxisLabel: yUnits,
              xAxisLabel: xUnits,
              seriesList: distanceSeriesList,
              getXAxisValue: (position) {
                return getTimeString(position);
              },
              getYAxisValue: (position) {
                return distanceMeasureFunction(
                  positionList.indexOf(position),
                  positionList,
                  yUnits,
                ).toString();
              },
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: MediaQuery.of(context).size.width - 50,
            child: RunGraph(
              cardTitle: "Speed over Time",
              yAxisLabel: "km/h",
              xAxisLabel: xUnits,
              seriesList: speedSeriesList,
              getXAxisValue: (position) {
                return getTimeString(position);
              },
              getYAxisValue: (position) {
                return (position.speedInMetresPerSecond * 3.6)
                    .toStringAsFixed(2);
              },
            ),
          ),
        ],
      ),
    );
  }

  String getTimeString(Position position) {
    var timeReached = position.timeReachedPositionInMilliseconds -
        widget.runModel.timeStartedInMilliseconds;

    var seconds = (timeReached ~/ 1000 % 60).toString() + "s";
    var minutes = (timeReached ~/ 1000 ~/ 60 % 60).toString() + "min ";
    var hours = (timeReached ~/ 1000 ~/ 60 ~/ 60).toString() + "hour ";
    if (seconds == "0s") seconds = "";
    if (minutes == "0min ") minutes = "";
    if (hours == "0hour ") hours = "";
    return hours + minutes + seconds;
  }

  num distanceMeasureFunction(
    int? index,
    List<Position> positionList,
    String yUnits,
  ) {
    if (index == null || index == 0) return 0;
    var remainingLatLng = positionList.reversed
        .toList()
        .sublist(positionList.length - index - 1)
        .map((e) => e.toLatLng())
        .toList();
    return yUnits == "m"
        ? [remainingLatLng].calculateDistance()
        : [remainingLatLng].calculateDistance() / 1000;
  }

  num timeDomainFunction(Position position, String xUnits) {
    var timeReached = position.timeReachedPositionInMilliseconds -
        widget.runModel.timeStartedInMilliseconds;
    if (xUnits == "minutes") {
      return timeReached / 1000 / 60;
    }
    if (xUnits == "hours") {
      return timeReached / 1000 / 60 / 60;
    }
    return timeReached / 1000;
  }

  Widget _getValue(
    BuildContext context,
    String header,
    String value,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          header,
          style: Theme.of(context).textTheme.headline6,
        ),
        Text(
          value,
          style: Theme.of(context)
              .textTheme
              .headline5!
              .copyWith(fontFamily: 'Roboto'),
        ),
      ],
    );
  }

  Widget _getMap(
    BuildContext context,
    AsyncSnapshot<List<List<Position>>?> snapshot,
  ) {
    if (snapshot.connectionState == ConnectionState.waiting ||
        !snapshot.hasData) {
      return Shimmer.fromColors(
        child: Container(
          height: MediaQuery.of(context).size.width,
          color: Theme.of(context).colorScheme.surface,
        ),
        baseColor: _baseColor,
        highlightColor: _highlightColor,
      );
    }

    List<List<LatLng>> runRoute = snapshot.data!.map((positionList) {
      return positionList.map((position) => position.toLatLng()).toList();
    }).toList();

    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.width,
      color: Theme.of(context).colorScheme.surface,
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: runRoute[0][0],
              zoom: 18.5,
            ),
            polylines: _getPolylines(runRoute),
            zoomControlsEnabled: false,
            onMapCreated: (controller) {
              _controller = controller;
              _configureMapType(context);
              _setLatLngBounds(runRoute);
            },
            gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
              Factory<OneSequenceGestureRecognizer>(
                () => EagerGestureRecognizer(),
              ),
            },
          ),
          Material(
            elevation: 100,
            color: Colors.transparent,
            shape: const CircleBorder(),
            clipBehavior: Clip.hardEdge,
            child: IconButton(
              onPressed: () => _setLatLngBounds(
                runRoute,
                animate: true,
              ),
              icon: const FaIcon(FontAwesomeIcons.route),
              tooltip: "Show run route",
            ),
          )
        ],
      ),
    );
  }

  void _configureMapType(BuildContext context) {
    _controller?.setMapStyle(
      Theme.of(context).brightness == Brightness.dark ? darkMode : lightMode,
    );
  }

  void _setLatLngBounds(
    List<List<LatLng>> runRoute, {
    bool animate = false,
  }) {
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
    CameraUpdate cameraUpdate = CameraUpdate.newLatLngBounds(
      LatLngBounds(
        southwest: LatLng(south, west),
        northeast: LatLng(north, east),
      ),
      MediaQuery.of(context).size.width * 0.05,
    );
    if (animate) {
      _controller?.animateCamera(cameraUpdate);
      return;
    }
    _controller?.moveCamera(cameraUpdate);
  }

  Set<Polyline> _getPolylines(List<List<LatLng>> runRoute) {
    Set<Polyline> polylines = {};
    for (var route in runRoute) {
      polylines.add(
        Polyline(
          polylineId: PolylineId(const Uuid().v4()),
          visible: true,
          points: route,
          width: 3,
          color: ClickToRunColors.primary,
        ),
      );
    }
    return polylines;
  }
}
