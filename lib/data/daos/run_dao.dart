import 'dart:typed_data';

import 'package:clicktorun_flutter/data/model/run_model.dart';

abstract class RunDao {
  Stream<List<RunModel>> getRunList(String email);
  Stream<List<RunModel>> getPosts();
  Future<bool> insertRun(
    RunModel runModel,
    Uint8List lightModeImage,
    Uint8List darkModeImage,
  );
  Future<bool> updateRun(String id, Map<String, dynamic> updateValues);
  Future<bool> deleteRun(List<String> idList);
  Future<bool> deleteAllRuns(String email);
}
