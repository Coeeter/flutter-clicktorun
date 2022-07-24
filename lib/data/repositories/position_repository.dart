import 'package:clicktorun_flutter/data/daos/position_dao.dart';
import 'package:clicktorun_flutter/data/impls/position_dao_impl.dart';
import 'package:clicktorun_flutter/data/model/position_model.dart';

class PositionRepository {
  PositionRepository._();
  static final PositionRepository _positionRepository = PositionRepository._();
  factory PositionRepository.instance() => _positionRepository;

  final PositionDao _positionDao = PositionDaoImpl.instance();

  Future<List<List<Position>>?> getRunRoute(String runId) {
    return _positionDao.getRunRoute(runId);
  }

  Future<bool> insertPositionList(List<List<Position>> runRoute, String runId) {
    return _positionDao.insertRunRoute(runRoute, runId);
  }

  Future<bool> deleteRunRoute(String runId) {
    return _positionDao.deleteRunRoute(runId);
  }
}
