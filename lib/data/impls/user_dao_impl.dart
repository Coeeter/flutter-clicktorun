import 'package:clicktorun_flutter/data/daos/user_dao.dart';
import 'package:clicktorun_flutter/data/model/clicktorun_user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserDaoImpl implements UserDao {
  UserDaoImpl._internal();
  static final UserDaoImpl _userDaoImpl = UserDaoImpl._internal();
  factory UserDaoImpl() => _userDaoImpl;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

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
        document.data()!.containsKey('profileImage'),
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
        .map(
      (doc) {
        if (_docChecker(doc)) return null;
        return UserModel.fromDocument(
          doc,
          doc.data()!.containsKey('profileImage'),
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
  Future<bool> updateUser(Map<String, dynamic> map) async {
    try {
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
  Future<bool> deleteUser(String email) async {
    try {
      await _firestore.collection('users').doc(email).delete();
      await _firebaseAuth.currentUser!.delete();
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
}
