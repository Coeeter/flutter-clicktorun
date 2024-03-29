import 'dart:io';

import 'package:clicktorun_flutter/data/daos/user_dao.dart';
import 'package:clicktorun_flutter/data/impls/user_dao_impl.dart';
import 'package:clicktorun_flutter/data/model/user_model.dart';

class UserRepository {
  UserRepository._internal();
  static final UserRepository _userRepository = UserRepository._internal();
  factory UserRepository.instance() => _userRepository;

  final UserDao _userDao = UserDaoImpl.instance();

  Future<UserModel?> getUser([String? email]) {
    return _userDao.getUser(email);
  }

  Stream<UserModel?> getUserStream([String? email]) {
    return _userDao.getUserStream(email);
  }

  Future<bool> insertUser(UserModel user) {
    return _userDao.insertUser(user);
  }

  Future<bool> updateUser({
    required Map<String, dynamic> map,
    File? profileImage,
  }) {
    return _userDao.updateUser(
      map,
      profileImage,
    );
  }

  Future<bool> deleteUser() {
    return _userDao.deleteUser();
  }

  Future<bool> deleteUserImage() {
    return _userDao.deleteUserImage();
  }
}
