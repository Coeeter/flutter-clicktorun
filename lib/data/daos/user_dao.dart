import 'dart:io';

import 'package:clicktorun_flutter/data/model/user_model.dart';

abstract class UserDao {
  Future<UserModel?> getUser(String? email);
  Stream<UserModel?> getUserStream(String? email);
  Future<bool> insertUser(UserModel user);
  Future<bool> updateUser(Map<String, dynamic> map, File? pickedImage);
  Future<bool> deleteUser();
  Future<bool> deleteUserImage();
}
