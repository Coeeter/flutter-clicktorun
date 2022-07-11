import 'package:clicktorun_flutter/ui/screens/parent/parent_screen.dart';
import 'package:clicktorun_flutter/ui/widgets/appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class TrackingScreen extends StatefulWidget {
  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  GoogleMapController? _controller;
  String lightMode = "";
  String darkMode = "";
  final bool _takingSnapshot = false;

  @override
  void initState() {
    super.initState();
    _loadStyles();
  }

  void _loadStyles() async {
    lightMode = await rootBundle.loadString(
      'assets/map_styles/light_mode.json',
    );
    darkMode = await rootBundle.loadString(
      'assets/map_styles/dark_mode.json',
    );
  }

  @override
  Widget build(BuildContext context) {
    _configureMapType(context);
    return Scaffold(
      appBar: ClickToRunAppbar("Tracking your run").getAppBar(actions: [
        IconButton(
          onPressed: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => ParentScreen(),
            ),
          ),
          icon: const Icon(Icons.close),
        )
      ]),
      body: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
        ),
        child: Stack(
          children: [
            SizedBox(
              height: _takingSnapshot
                  ? MediaQuery.of(context).size.width / 2
                  : double.infinity,
              child: GoogleMap(
                initialCameraPosition: const CameraPosition(
                  target: LatLng(1.3521, 103.8198),
                  zoom: 10,
                ),
                onMapCreated: (controller) {
                  _controller = controller;
                  _configureMapType(context);
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  void _configureMapType(BuildContext context) => _controller?.setMapStyle(
        Theme.of(context).brightness == Brightness.dark ? darkMode : lightMode,
      );
}
