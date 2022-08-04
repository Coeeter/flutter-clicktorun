import 'package:clicktorun_flutter/data/daos/follow_dao.dart';
import 'package:clicktorun_flutter/data/impls/follow_dao_impl.dart';
import 'package:clicktorun_flutter/data/model/follow_model.dart';
import 'package:clicktorun_flutter/data/model/user_model.dart';

class FollowRepository {
  FollowRepository._();
  static final FollowRepository _instance = FollowRepository._();
  factory FollowRepository.instance() => _instance;

  final FollowDao _followDao = FollowDaoImpl.instance();

  Stream<List<UserModel>> getFollowers() {
    return _followDao.getAllFollowers();
  }

  Stream<List<UserModel>> getAllUserIsFollowing() {
    return _followDao.getAllUserIsFollowing();
  }

  Future<bool> insertFollowLink(
    String userBeingFollowed,
    String userFollowing,
  ) {
    return _followDao.insertFollowLink(
      FollowModel(
        userBeingFollowedEmail: userBeingFollowed,
        userFollowingEmail: userFollowing,
      ),
    );
  }

  Future<bool> deleteFollow(String userBeingFollowed, String userFollowing) {
    return _followDao.removeFollowLink(userBeingFollowed, userFollowing);
  }

  Future<bool> deleteAllLinks(String email) {
    return _followDao.removeAllFollowLinkRelatedToUser(email);
  }
}
