import 'package:clicktorun_flutter/data/model/user_model.dart';
import 'package:clicktorun_flutter/data/repositories/follow_repository.dart';
import 'package:clicktorun_flutter/ui/screens/settings/profile_screen.dart';
import 'package:clicktorun_flutter/ui/utils/colors.dart';
import 'package:clicktorun_flutter/ui/widgets/appbar.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class FollowingList extends StatefulWidget {
  final String email;
  final String username;
  final int? index;

  const FollowingList({
    required this.email,
    required this.username,
    this.index,
    Key? key,
  }) : super(key: key);

  @override
  State<FollowingList> createState() => _FollowingListState();
}

class _FollowingListState extends State<FollowingList>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.index ?? 0,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color labelColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;

    return StreamBuilder<List<UserModel>>(
      stream: FollowRepository.instance().getAllUserIsFollowing(widget.email),
      builder: (context, followingList) {
        var isLoading =
            followingList.connectionState == ConnectionState.waiting;
        return StreamBuilder<List<UserModel>>(
          stream: FollowRepository.instance().getFollowers(widget.email),
          builder: (context, followersList) {
            var isSecondLoading =
                followersList.connectionState == ConnectionState.waiting;
            return Scaffold(
              appBar: CustomAppbar(
                title: '${widget.username}\'s profile',
                elevation: 0,
              ),
              backgroundColor: Theme.of(context).colorScheme.surface,
              body: Column(
                children: [
                  Material(
                    elevation: 4,
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: ClickToRunColors.linearGradient,
                      ),
                      child: TabBar(
                        controller: _tabController,
                        indicatorColor: labelColor,
                        indicatorWeight: 2.3,
                        labelColor: labelColor,
                        labelStyle:
                            Theme.of(context).textTheme.bodyMedium!.copyWith(
                                  fontFamily: 'Roboto',
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                        tabs: const [
                          Tab(text: "Followers"),
                          Tab(text: "Following"),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      physics: const BouncingScrollPhysics(),
                      children: [
                        isLoading || isSecondLoading
                            ? _getLoadingWidget()
                            : _getListView(
                                context,
                                followersList.data!,
                                'assets/images/ic_no_follows_list.png',
                                'No followers found',
                                const EdgeInsets.symmetric(vertical: 32),
                              ),
                        isLoading || isSecondLoading
                            ? _getLoadingWidget()
                            : _getListView(
                                context,
                                followingList.data!,
                                'assets/images/ic_no_follows.png',
                                'No following found',
                              ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _getListView(
    BuildContext context,
    List<UserModel> userList,
    String asset,
    String empty, [
    EdgeInsets? padding,
  ]) {
    double width = MediaQuery.of(context).size.width * 0.1;
    if (userList.isEmpty) {
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 50,
              vertical: 30,
            ),
            child: Padding(
              padding: padding ?? const EdgeInsets.all(0),
              child: Image.asset(asset),
            ),
          ),
          Text(
            empty,
            style: Theme.of(context).textTheme.headline5,
          ),
        ],
      );
    }

    return ListView(
      physics: const BouncingScrollPhysics(),
      children: userList.map((e) {
        return Material(
          child: InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ProfileScreen(email: e.email),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  _getProfileImage(width, e),
                  const SizedBox(width: 10),
                  Text(
                    e.username,
                    style: Theme.of(context).textTheme.headline5,
                  )
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  SizedBox _getProfileImage(double width, UserModel e) {
    return SizedBox(
      width: width,
      height: width,
      child: Container(
        decoration: const ShapeDecoration(
          shape: CircleBorder(),
          shadows: [
            BoxShadow(
              color: Colors.grey,
              blurRadius: 2,
            ),
          ],
        ),
        child: Material(
          shape: const CircleBorder(),
          clipBehavior: Clip.hardEdge,
          child: Container(
            width: width,
            height: width,
            alignment: Alignment.center,
            child: e.profileImage == null
                ? Icon(
                    Icons.person,
                    size: width,
                    color: Colors.grey,
                  )
                : SizedBox(
                    width: double.infinity,
                    height: double.infinity,
                    child: Image.network(
                      e.profileImage!,
                      fit: BoxFit.cover,
                      loadingBuilder: (
                        BuildContext context,
                        Widget child,
                        ImageChunkEvent? loadingProgress,
                      ) {
                        if (loadingProgress == null) return child;
                        return Shimmer.fromColors(
                          child: Container(
                            color: ClickToRunColors.getbaseColor(context),
                          ),
                          baseColor: ClickToRunColors.getbaseColor(context),
                          highlightColor:
                              ClickToRunColors.gethighlightColor(context),
                        );
                      },
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _getLoadingWidget() {
    return Container();
  }
}
