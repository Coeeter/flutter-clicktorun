import 'package:clicktorun_flutter/data/model/follow_model.dart';
import 'package:clicktorun_flutter/data/model/user_model.dart';

abstract class FollowDao {
  Stream<List<UserModel>> getAllFollowers([String? email]);
  Stream<List<UserModel>> getAllUserIsFollowing([String? email]);
  Future<bool> insertFollowLink(FollowModel followModel);
  Future<bool> removeFollowLink(String userBeingFollowed, String userFollowing);
  Future<bool> removeAllFollowLinkRelatedToUser(String email);
}
