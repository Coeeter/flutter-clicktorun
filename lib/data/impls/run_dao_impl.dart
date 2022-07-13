import 'dart:typed_data';

import 'package:clicktorun_flutter/data/daos/run_dao.dart';
import 'package:clicktorun_flutter/data/model/run_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class RunDaoImpl implements RunDao {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Reference _reference = FirebaseStorage.instance.ref();

  RunDaoImpl._internal();
  static final RunDaoImpl _instance = RunDaoImpl._internal();
  factory RunDaoImpl.instance() {
    return _instance;
  }

  @override
  Stream<List<RunModel>> getRunList(String email) {
    return _firestore
        .collection('runs')
        .where('email', isEqualTo: email)
        .orderBy('timeStarted')
        .snapshots()
        .asyncMap(
          (snapshot) async => await _convertToList(snapshot),
        );
  }

  Future<List<RunModel>> _convertToList(
    QuerySnapshot<Map<String, dynamic>> querySnapshot,
  ) async {
    List<DocumentSnapshot<Map<String, dynamic>>> docList = querySnapshot.docs;
    List<RunModel> runList = [];
    for (var document in docList) {
      runList.add(
        RunModel.fromMap(
          document,
          await _getDownloadUrl(document["darkModeImage"]),
          await _getDownloadUrl(document["lightModeImage"]),
        ),
      );
    }
    return runList;
  }

  Future<String> _getDownloadUrl(String child) async {
    return await _reference.child(child).getDownloadURL();
  }

  @override
  Future<bool> insertRun(
    RunModel runModel,
    Uint8List lightModeImage,
    Uint8List darkModeImage,
  ) async {
    try {
      await _reference.child(runModel.lightModeImage).putData(lightModeImage);
      await _reference.child(runModel.darkModeImage).putData(darkModeImage);
      await _firestore.collection('runs').doc().set({
        'email': runModel.email,
        'darkModeImage': runModel.darkModeImage,
        'lightModeImage': runModel.lightModeImage,
        'timeStarted': runModel.timeStartedInMilliseconds,
        'timeTaken': runModel.timeTakenInMilliseconds,
        'distanceRan': runModel.distanceRanInMetres,
        'averageSpeed': runModel.averageSpeed,
      });
      return true;
    } catch (e) {
      print((e as FirebaseException).message.toString());
      return false;
    }
  }

  @override
  Future<bool> updateRun(String id, Map<String, dynamic> updateValues) async {
    try {
      await _firestore.collection('runs').doc(id).update(updateValues);
      return true;
    } catch (e) {
      print((e as FirebaseException).message.toString());
      return false;
    }
  }

  @override
  Future<bool> deleteRun(String id) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> document =
          await _firestore.collection('users').doc(id).get();
      await _reference.child(document["lightModeImage"]).delete();
      await _reference.child(document["darkModeImage"]).delete();
      await _firestore.collection('users').doc(id).delete();
      return true;
    } catch (e) {
      print((e as FirebaseException).message.toString());
      return false;
    }
  }
}
