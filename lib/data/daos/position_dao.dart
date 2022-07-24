import 'package:clicktorun_flutter/data/model/position_model.dart';

abstract class PositionDao {
  Future<List<List<Position>>?> getRunRoute(String runId);

  Future<bool> insertRunRoute(List<List<Position>> runRoute, String runId);

  Future<bool> deleteRunRoute(String runId);
}
