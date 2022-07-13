import 'package:cloud_firestore/cloud_firestore.dart';

class RunModel {
  String id, email, darkModeImage, lightModeImage;
  double distanceRanInMetres, averageSpeed;
  int timeStartedInMilliseconds, timeTakenInMilliseconds;

  RunModel({
    required this.id,
    required this.email,
    required this.darkModeImage,
    required this.lightModeImage,
    required this.timeStartedInMilliseconds,
    required this.timeTakenInMilliseconds,
    required this.distanceRanInMetres,
    required this.averageSpeed,
  });

  RunModel.fromMap(
    DocumentSnapshot<Map<String, dynamic>> document,
    String darkModeImage,
    String lightModeImage,
  ) : this(
          id: document.id,
          darkModeImage: darkModeImage,
          lightModeImage: lightModeImage,
          email: document["email"],
          timeStartedInMilliseconds: document["timeStarted"],
          timeTakenInMilliseconds: document["timeTaken"],
          distanceRanInMetres: document["distanceRan"],
          averageSpeed: document["averageSpeed"],
        );
}
