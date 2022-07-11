import 'dart:io';

import 'package:clicktorun_flutter/data/model/clicktorun_user.dart';

abstract class UserDao {
  Future<UserModel?> getUser();
  Stream<UserModel?> getUserStream();
  Future<bool> insertUser(UserModel user);
  Future<bool> updateUser(Map<String, dynamic> map, File? pickedImage);
  Future<bool> deleteUser();
  Future<bool> deleteUserImage();
}