import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  String username;
  String email;
  double heightInCentimetres;
  double weightInKilograms;
  String? profileImage;

  UserModel({
    required this.username,
    required this.email,
    required this.heightInCentimetres,
    required this.weightInKilograms,
    this.profileImage,
  });

  UserModel.fromDocument(
    DocumentSnapshot<Map<String, dynamic>> document,
    String? profileImage,
  ) : this(
          username: document["username"] ?? '',
          email: document.id,
          heightInCentimetres: document["heightInCentimetres"] ?? 0.0,
          weightInKilograms: document["weightInKilograms"] ?? 0.0,
          profileImage: profileImage,
        );
}
