import 'dart:io';

import 'package:clicktorun_flutter/data/daos/user_dao.dart';
import 'package:clicktorun_flutter/data/impls/user_dao_impl.dart';
import 'package:clicktorun_flutter/data/model/clicktorun_user.dart';

class UserRepository {
  UserRepository._internal();
  static final UserRepository _userRepository = UserRepository._internal();
  factory UserRepository.instance() => _userRepository;

  final UserDao _userDao = UserDaoImpl();

  Future<UserModel?> getUser() => _userDao.getUser();
  Stream<UserModel?> getUserStream() => _userDao.getUserStream();
  Future<bool> insertUser(UserModel user) => _userDao.insertUser(user);
  Future<bool> updateUser({
    required Map<String, dynamic> map,
    File? profileImage,
  }) =>
      _userDao.updateUser(
        map,
        profileImage,
      );
  Future<bool> deleteUser() => _userDao.deleteUser();
  Future<bool> deleteUserImage() => _userDao.deleteUserImage();
}
