import 'dart:developer';

import 'package:clicktorun_flutter/data/daos/position_dao.dart';
import 'package:clicktorun_flutter/data/model/position_model.dart';
import 'package:clicktorun_flutter/data/repositories/auth_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PositionDaoImpl implements PositionDao {
  PositionDaoImpl._();
  static final PositionDaoImpl _positionDaoImpl = PositionDaoImpl._();
  factory PositionDaoImpl.instance() => _positionDaoImpl;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<List<List<Position>>?> getRunRoute(String runId) async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await _firestore
          .collection('runs')
          .doc(runId)
          .collection('routes')
          .get();
      List<List<Position>> runRoute = [];
      for (QueryDocumentSnapshot doc in querySnapshot.docs) {
        runRoute.add([]);
        List routePoints = doc['route'];
        for (Map map in routePoints) {
          runRoute.last.add(
            Position.fromMap(
              map as Map<String, dynamic>,
              doc.id,
            ),
          );
        }
      }
      return runRoute;
    } catch (e) {
      log(e.toString());
      return null;
    }
  }

  @override
  Future<bool> insertRunRoute(
    List<List<Position>> runRoute,
    String runId,
  ) async {
    try {
      WriteBatch batch = _firestore.batch();
      for (List<Position> positionList in runRoute) {
        List<Map<String, dynamic>> mapList = positionList.map(
          (position) {
            return position.toMap();
          },
        ).toList();
        batch.set(
          _firestore
              .collection('runs')
              .doc(runId)
              .collection('routes')
              .doc(positionList.first.polylineId),
          {
            'route': mapList,
          },
        );
      }
      await batch.commit();
      return true;
    } catch (e) {
      log(e.toString());
      return false;
    }
  }

  @override
  Future<bool> deleteRunRoute(String runId) async {
    try {
      WriteBatch batch = _firestore.batch();
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await _firestore
          .collection('runs')
          .doc(runId)
          .collection('routes')
          .get();
      for (QueryDocumentSnapshot doc in querySnapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
      return true;
    } catch (e) {
      log(e.toString());
      return false;
    }
  }

  @override
  Future<bool> deleteAllRoutes() async {
    try {
      WriteBatch batch = _firestore.batch();
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await _firestore
          .collection('runs')
          .where(
            'email',
            isEqualTo: AuthRepository.instance().currentUser!.email!,
          )
          .get();
      for (QueryDocumentSnapshot doc in querySnapshot.docs) {
        var routes = await doc.reference.collection('routes').get();
        for (var routeDoc in routes.docs) {
          batch.delete(routeDoc.reference);
        }
      }
      await batch.commit();
      return true;
    } catch (e) {
      log(e.toString());
      return false;
    }
  }
}
