import 'dart:typed_data';

import 'package:clicktorun_flutter/data/daos/run_dao.dart';
import 'package:clicktorun_flutter/data/impls/run_dao_impl.dart';
import 'package:clicktorun_flutter/data/model/run_model.dart';

class RunRepository {
  RunRepository._internal();
  static final RunRepository _instance = RunRepository._internal();
  factory RunRepository.instance() => _instance;

  final RunDao _runDao = RunDaoImpl.instance();

  Stream<List<RunModel>> getRunList(String email) {
    return _runDao.getRunList(email);
  }

  Future<bool> insertRun(
    RunModel runModel,
    Uint8List lightModeImage,
    Uint8List darkModeImage,
  ) {
    return _runDao.insertRun(runModel, lightModeImage, darkModeImage);
  }

  Future<bool> updateRun(String id, Map<String, dynamic> updateValues) {
    return _runDao.updateRun(id, updateValues);
  }

  Future<bool> deleteRun(List<String> idList) {
    return _runDao.deleteRun(idList);
  }

  Future<bool> deleteAllRuns(String email) {
    return _runDao.deleteAllRuns(email);
  }
}
