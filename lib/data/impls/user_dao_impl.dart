import 'dart:io';

import 'package:clicktorun_flutter/data/daos/user_dao.dart';
import 'package:clicktorun_flutter/data/model/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class UserDaoImpl implements UserDao {
  UserDaoImpl._internal();
  static final UserDaoImpl _userDaoImpl = UserDaoImpl._internal();
  factory UserDaoImpl.instance() => _userDaoImpl;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final Reference _reference = FirebaseStorage.instance.ref();

  @override
  Future<UserModel?> getUser() async {
    try {
      DocumentSnapshot<Map<String, dynamic>> document = await _firestore
          .collection('users')
          .doc(_firebaseAuth.currentUser!.email)
          .get();
      if (_docChecker(document)) return null;
      return Future.value(UserModel.fromDocument(
        document,
        await _getProfileImageUrl(document),
      ));
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  @override
  Stream<UserModel?> getUserStream() {
    return _firestore
        .collection('users')
        .doc(_firebaseAuth.currentUser!.email)
        .snapshots()
        .asyncMap(
      (doc) async {
        if (_docChecker(doc)) return null;
        return UserModel.fromDocument(
          doc,
          await _getProfileImageUrl(doc),
        );
      },
    );
  }

  @override
  Future<bool> insertUser(UserModel user) async {
    try {
      Map<String, dynamic> map = {
        "username": user.username,
        "heightInCentimetres": user.heightInCentimetres,
        "weightInKilograms": user.weightInKilograms,
      };
      await _firestore.collection('users').doc(user.email).set(map);
      return Future.value(true);
    } catch (e) {
      print(e.toString());
      return Future.value(false);
    }
  }

  @override
  Future<bool> updateUser(
    Map<String, dynamic> map,
    File? profileImage,
  ) async {
    try {
      if (profileImage != null) {
        String fileName = const Uuid().v4();
        await _reference.child(fileName).putFile(profileImage);
        map["profileImage"] = fileName;
        var doc = await _firestore
            .collection('users')
            .doc(_firebaseAuth.currentUser!.email)
            .get();
        if (doc.data()!.containsKey('profileImage')) {
          _reference.child(doc["profileImage"]).delete();
        }
      }
      await _firestore
          .collection('users')
          .doc(_firebaseAuth.currentUser!.email)
          .update(map);
      return Future.value(true);
    } catch (e) {
      print(e.toString());
      return Future.value(false);
    }
  }

  @override
  Future<bool> deleteUser() async {
    try {
      await _firestore
          .collection('users')
          .doc(_firebaseAuth.currentUser!.email)
          .delete();
      await _firebaseAuth.currentUser!.delete();
      return Future.value(true);
    } catch (e) {
      print(e.toString());
      return Future.value(false);
    }
  }

  @override
  Future<bool> deleteUserImage() async {
    try {
      String email = _firebaseAuth.currentUser!.email!;
      var doc = await _firestore.collection('users').doc(email).get();
      if (doc.exists && doc.data()!.containsKey('profileImage')) {
        await _reference.child(doc['profileImage']).delete();
        await _firestore.collection('users').doc(email).update({
          'profileImage': FieldValue.delete(),
        });
      }
      return Future.value(true);
    } catch (e) {
      print(e.toString());
      return Future.value(false);
    }
  }

  bool _docChecker(DocumentSnapshot<Map<String, dynamic>> document) =>
      !document.exists ||
      !document.data()!.containsKey('username') ||
      !document.data()!.containsKey('heightInCentimetres') ||
      !document.data()!.containsKey('weightInKilograms');

  Future<String?> _getProfileImageUrl(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) async {
    String? profileUrl;
    if (!document.data()!.containsKey('profileImage')) {
      return null;
    }
    profileUrl =
        await _reference.child(document['profileImage']).getDownloadURL();
    return profileUrl;
  }
}
