import 'package:cloud_firestore/cloud_firestore.dart';

class FollowModel {
  String? id;
  String userFollowingEmail;
  String userBeingFollowedEmail;

  FollowModel({
    this.id,
    required this.userBeingFollowedEmail,
    required this.userFollowingEmail,
  });

  FollowModel.fromDocument(DocumentSnapshot<Map<String, dynamic>> doc)
      : this(
          id: doc.id,
          userBeingFollowedEmail: doc["userBeingFollowedEmail"],
          userFollowingEmail: doc["userFollowingEmail"],
        );

  Map<String, dynamic> toMap() => {
        "userBeingFollowedEmail": userBeingFollowedEmail,
        "userFollowingEmail": userFollowingEmail,
      };
}
