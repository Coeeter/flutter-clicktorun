import 'package:clicktorun_flutter/data/model/clicktorun_user.dart';

abstract class UserDao {
  Future<UserModel?> getUser();
  Future<bool> insertUser(UserModel user);
  Future<bool> updateUser(Map<String, dynamic> map);
  Future<bool> deleteUser(String email);
}
