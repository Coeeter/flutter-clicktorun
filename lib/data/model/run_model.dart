import 'package:cloud_firestore/cloud_firestore.dart';

class RunModel {
  String id, email, darkModeImage, lightModeImage;
  double distanceRanInMetres, averageSpeed;
  int timeStartedInMilliseconds, timeTakenInMilliseconds;
  bool isShared;

  RunModel({
    required this.id,
    required this.email,
    required this.darkModeImage,
    required this.lightModeImage,
    required this.timeStartedInMilliseconds,
    required this.timeTakenInMilliseconds,
    required this.distanceRanInMetres,
    required this.averageSpeed,
    this.isShared = false,
  });

  RunModel.fromMap(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) : this(
          id: document.id,
          darkModeImage: document["darkModeImage"],
          lightModeImage: document["lightModeImage"],
          email: document["email"],
          timeStartedInMilliseconds: document["timeStarted"],
          timeTakenInMilliseconds: document["timeTaken"],
          distanceRanInMetres: document["distanceRan"],
          averageSpeed: document["averageSpeed"],
          isShared: document.data()!.containsKey('shared')
              ? document["shared"]
              : false,
        );
}
