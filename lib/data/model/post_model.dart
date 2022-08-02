import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  String id;
  String runId;
  String email;
  double timePosted;
  String caption;

  PostModel({
    required this.id,
    required this.runId,
    required this.email,
    required this.timePosted,
    required this.caption,
  });

  PostModel.fromDocument(
    DocumentSnapshot doc, [
    List<String> otherImages = const [],
  ]) : this(
          id: doc.id,
          runId: doc["runId"],
          email: doc["email"],
          timePosted: doc["timePosted"],
          caption: doc["caption"],
        );

  Map<String, dynamic> getMap() => {
        'runId': runId,
        'email': email,
        'timePosted': timePosted,
        'caption': caption,
      };
}
