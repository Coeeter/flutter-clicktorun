import 'dart:developer';

import 'package:clicktorun_flutter/data/daos/follow_dao.dart';
import 'package:clicktorun_flutter/data/model/follow_model.dart';
import 'package:clicktorun_flutter/data/model/user_model.dart';
import 'package:clicktorun_flutter/data/repositories/user_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FollowDaoImpl implements FollowDao {
  FollowDaoImpl._();
  static final FollowDaoImpl _instance = FollowDaoImpl._();
  factory FollowDaoImpl.instance() => _instance;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final String collectionPath = 'followlinks';

  @override
  Stream<List<UserModel>> getAllFollowers([String? email]) async* {
    var followListStream = _firestore
        .collection(collectionPath)
        .where(
          'userBeingFollowedEmail',
          isEqualTo: email ?? _firebaseAuth.currentUser!.email!,
        )
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map((doc) {
            return FollowModel.fromDocument(doc);
          }).toList(),
        );
    await for (var followList in followListStream) {
      List<UserModel> followers = [];
      for (var followModel in followList) {
        var user = await UserRepository.instance().getUser(
          followModel.userFollowingEmail,
        );
        if (user == null) continue;
        followers.add(user);
      }
      yield followers;
    }
  }

  @override
  Stream<List<UserModel>> getAllUserIsFollowing([String? email]) async* {
    var followListStream = _firestore
        .collection(collectionPath)
        .where(
          'userFollowingEmail',
          isEqualTo: email ?? _firebaseAuth.currentUser!.email!,
        )
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map((doc) {
            return FollowModel.fromDocument(doc);
          }).toList(),
        );
    await for (var followList in followListStream) {
      List<UserModel> followers = [];
      for (var followModel in followList) {
        var user = await UserRepository.instance().getUser(
          followModel.userBeingFollowedEmail,
        );
        if (user == null) continue;
        followers.add(user);
      }
      yield followers;
    }
  }

  @override
  Future<bool> insertFollowLink(FollowModel followModel) async {
    try {
      await _firestore
          .collection(collectionPath)
          .doc()
          .set(followModel.toMap());
      return true;
    } catch (e) {
      log(e.toString());
      return false;
    }
  }

  @override
  Future<bool> removeFollowLink(
    String userBeingFollowed,
    String userFollowing,
  ) async {
    try {
      var querySnaphsot = await _firestore
          .collection(collectionPath)
          .where(
            'userBeingFollowedEmail',
            isEqualTo: userBeingFollowed,
          )
          .get();
      for (var followLink in querySnaphsot.docs) {
        if (followLink["userFollowingEmail"] == userFollowing) {
          await followLink.reference.delete();
        }
      }
      return true;
    } catch (e) {
      log(e.toString());
      return false;
    }
  }

  @override
  Future<bool> removeAllFollowLinkRelatedToUser(String email) async {
    try {
      var followers = await _firestore
          .collection(collectionPath)
          .where(
            'userBeingFollowedEmail',
            isEqualTo: email,
          )
          .get();
      for (var followLink in followers.docs) {
        await followLink.reference.delete();
      }
      var following = await _firestore
          .collection(collectionPath)
          .where(
            'userFollowingEmail',
            isEqualTo: email,
          )
          .get();
      for (var followLink in following.docs) {
        await followLink.reference.delete();
      }
      return true;
    } catch (e) {
      log(e.toString());
      return false;
    }
  }
}
