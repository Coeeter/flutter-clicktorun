import 'package:clicktorun_flutter/data/model/run_model.dart';
import 'package:clicktorun_flutter/data/model/user_model.dart';
import 'package:clicktorun_flutter/data/repositories/auth_repository.dart';
import 'package:clicktorun_flutter/data/repositories/follow_repository.dart';
import 'package:clicktorun_flutter/data/repositories/run_repository.dart';
import 'package:clicktorun_flutter/data/repositories/user_repository.dart';
import 'package:clicktorun_flutter/ui/screens/explore/post_item.dart';
import 'package:clicktorun_flutter/ui/screens/home/run_details_screen.dart';
import 'package:clicktorun_flutter/ui/screens/settings/edit_profile_screen.dart';
import 'package:clicktorun_flutter/ui/screens/settings/following_list_screen.dart';
import 'package:clicktorun_flutter/ui/utils/colors.dart';
import 'package:clicktorun_flutter/ui/widgets/appbar.dart';
import 'package:clicktorun_flutter/ui/widgets/profile_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ProfileScreen extends StatefulWidget {
  final String email;
  const ProfileScreen({
    required this.email,
    Key? key,
  }) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserModel? _user;

  @override
  Widget build(BuildContext context) {
    var colorScheme = Theme.of(context).colorScheme.copyWith(
          surface: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF303030)
              : Colors.white,
        );
    var width = MediaQuery.of(context).size.width * 0.3;

    return StreamBuilder<UserModel?>(
      stream: UserRepository.instance().getUserStream(
        widget.email,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _loadingWidget(context, width);
        }
        _user = snapshot.data!;

        return Scaffold(
          appBar: CustomAppbar(
            title: '${snapshot.data!.username}\'s Profile',
          ),
          body: Container(
            width: double.infinity,
            height: double.infinity,
            color: Theme.of(context).colorScheme.surface,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  const SizedBox(height: 30),
                  SizedBox(
                    width: width,
                    height: width,
                    child: ProfileImage(
                      width: width,
                      snapshot: snapshot,
                      colorScheme: colorScheme,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    snapshot.data!.username,
                    style: Theme.of(context).textTheme.headline5!.copyWith(
                          fontSize: 35,
                        ),
                  ),
                  const SizedBox(height: 10),
                  _getFollowerCount(),
                  const SizedBox(height: 10),
                  _getPosts(),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _getPosts() {
    return StreamBuilder<List<RunModel>>(
      stream: RunRepository.instance().getPosts(),
      builder: (context, postSnapshot) {
        if (postSnapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator(
            color: ClickToRunColors.secondary,
          );
        }
        List<RunModel> posts = [];
        if (postSnapshot.hasData && postSnapshot.data!.isNotEmpty) {
          posts = postSnapshot.data!
              .where((element) => element.email == widget.email)
              .toList();
        }
        if (posts.isEmpty) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 50,
                  vertical: 30,
                ),
                child: Image.asset('assets/images/ic_no_posts.png'),
              ),
              Text(
                'No posts to show here',
                style: Theme.of(context).textTheme.headline5,
              ),
            ],
          );
        }
        return Column(
          children: posts.map((e) {
            return GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => RunDetailsScreen(
                      runModel: e,
                      username: _user!.username,
                    ),
                  ),
                );
              },
              child: PostItem(
                run: e,
                username: _user!.username,
                setIsLoading: (_) {},
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Scaffold _loadingWidget(BuildContext context, double width) {
    return Scaffold(
      appBar: CustomAppbar(
        title: '',
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Shimmer.fromColors(
            baseColor: ClickToRunColors.getbaseColor(context),
            highlightColor: ClickToRunColors.gethighlightColor(context),
            child: Column(
              children: [
                const SizedBox(height: 30),
                SizedBox(
                  width: width,
                  height: width,
                  child: Material(
                    shape: const CircleBorder(),
                    clipBehavior: Clip.hardEdge,
                    child: Container(
                      color: ClickToRunColors.getbaseColor(context),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  width: 200,
                  height: 40,
                  color: ClickToRunColors.getbaseColor(context),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      children: [
                        Container(
                          width: 50,
                          height: 25,
                          color: ClickToRunColors.getbaseColor(context),
                        ),
                        const SizedBox(height: 5),
                        Container(
                          width: 100,
                          height: 20,
                          color: ClickToRunColors.getbaseColor(context),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Container(
                          width: 50,
                          height: 25,
                          color: ClickToRunColors.getbaseColor(context),
                        ),
                        const SizedBox(height: 5),
                        Container(
                          width: 100,
                          height: 20,
                          color: ClickToRunColors.getbaseColor(context),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  width: 150,
                  height: 40,
                  color: ClickToRunColors.getbaseColor(context),
                ),
                const SizedBox(height: 10),
                _getLoadingRunItem(context),
                const SizedBox(height: 10),
                _getLoadingRunItem(context),
                const SizedBox(height: 10),
                _getLoadingRunItem(context),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Material _getLoadingRunItem(BuildContext context) {
    return Material(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
              width: MediaQuery.of(context).size.width - 20,
              height: (MediaQuery.of(context).size.width - 20) / 2,
              color: ClickToRunColors.getbaseColor(context)),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Container(
              color: ClickToRunColors.getbaseColor(context),
              width: 100,
              height: 20,
            ),
          )
        ],
      ),
    );
  }

  Widget _getFollowerCount() {
    var isCurrentAccount =
        AuthRepository.instance().currentUser!.email == widget.email;
    var loading = Shimmer.fromColors(
      highlightColor: ClickToRunColors.gethighlightColor(context),
      baseColor: ClickToRunColors.getbaseColor(context),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  Container(
                    width: 50,
                    height: 25,
                    color: ClickToRunColors.getbaseColor(context),
                  ),
                  const SizedBox(height: 5),
                  Container(
                    width: 100,
                    height: 20,
                    color: ClickToRunColors.getbaseColor(context),
                  ),
                ],
              ),
              Column(
                children: [
                  Container(
                    width: 50,
                    height: 25,
                    color: ClickToRunColors.getbaseColor(context),
                  ),
                  const SizedBox(height: 5),
                  Container(
                    width: 100,
                    height: 20,
                    color: ClickToRunColors.getbaseColor(context),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            width: 150,
            height: 40,
            color: ClickToRunColors.getbaseColor(context),
          ),
        ],
      ),
    );
    return StreamBuilder<List<UserModel>>(
      stream: FollowRepository.instance().getAllUserIsFollowing(widget.email),
      builder: (context, followingList) {
        if (followingList.connectionState == ConnectionState.waiting) {
          return loading;
        }
        return StreamBuilder<List<UserModel>>(
          stream: FollowRepository.instance().getFollowers(widget.email),
          builder: (context, followersList) {
            if (followersList.connectionState == ConnectionState.waiting) {
              return loading;
            }
            bool isFollowing = false;
            if (followersList.hasData && followersList.data!.isNotEmpty) {
              isFollowing = followersList.data!.map((e) => e.email).contains(
                    AuthRepository.instance().currentUser!.email!,
                  );
            }
            return Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => FollowingList(
                              email: widget.email,
                              username: _user!.username,
                            ),
                          ),
                        );
                      },
                      child: Column(
                        children: [
                          Text(
                            followersList.data!.length.toString(),
                            style: Theme.of(context).textTheme.headline5,
                          ),
                          Text(
                            "Followers",
                            style: Theme.of(context)
                                .textTheme
                                .headline4!
                                .copyWith(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => FollowingList(
                              email: widget.email,
                              username: _user!.username,
                              index: 1,
                            ),
                          ),
                        );
                      },
                      child: Column(
                        children: [
                          Text(
                            followingList.data!.length.toString(),
                            style: Theme.of(context).textTheme.headline5,
                          ),
                          Text(
                            "Following",
                            style: Theme.of(context)
                                .textTheme
                                .headline4!
                                .copyWith(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                OutlinedButton(
                  onPressed: () {
                    isCurrentAccount
                        ? Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const EditUserDetailsScreen(),
                            ),
                          )
                        : isFollowing
                            ? FollowRepository.instance().deleteFollow(
                                widget.email,
                                AuthRepository.instance().currentUser!.email!,
                              )
                            : FollowRepository.instance().insertFollowLink(
                                widget.email,
                                AuthRepository.instance().currentUser!.email!,
                              );
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                  ),
                  child: Text(
                    isCurrentAccount
                        ? 'Edit profile'
                        : isFollowing
                            ? 'Unfollow'
                            : 'Follow',
                    style: Theme.of(context)
                        .textTheme
                        .headline5!
                        .copyWith(color: ClickToRunColors.primary),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
