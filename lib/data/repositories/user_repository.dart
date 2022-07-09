import 'package:clicktorun_flutter/data/daos/user_dao.dart';
import 'package:clicktorun_flutter/data/impls/user_dao_impl.dart';

import '../model/clicktorun_user.dart';

class UserRepository {
  UserRepository._internal();
  static final UserRepository _userRepository = UserRepository._internal();
  factory UserRepository() => _userRepository;

  final UserDao _userDao = UserDaoImpl();

  Future<UserModel?> getUser() => _userDao.getUser();
  Future<bool> insertUser(UserModel user) => _userDao.insertUser(user);
  Future<bool> updateUser(Map<String, dynamic> map) => _userDao.updateUser(map);
  Future<bool> deleteUser(String email) => _userDao.deleteUser(email);
}
