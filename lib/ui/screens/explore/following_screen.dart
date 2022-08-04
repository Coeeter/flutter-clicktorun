import 'package:clicktorun_flutter/data/model/run_model.dart';
import 'package:clicktorun_flutter/data/model/user_model.dart';
import 'package:clicktorun_flutter/data/repositories/follow_repository.dart';
import 'package:clicktorun_flutter/data/repositories/run_repository.dart';
import 'package:clicktorun_flutter/ui/screens/explore/post_item.dart';
import 'package:clicktorun_flutter/ui/utils/colors.dart';
import 'package:clicktorun_flutter/ui/widgets/loading_container.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class FollowingScreen extends StatefulWidget {
  const FollowingScreen({Key? key}) : super(key: key);

  @override
  State<FollowingScreen> createState() => _FollowingScreenState();
}

class _FollowingScreenState extends State<FollowingScreen> {
  bool _isLoading = false;

  void _setIsLoading(bool value) {
    setState(() {
      _isLoading = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        StreamBuilder<List<UserModel>>(
          stream: FollowRepository.instance().getAllUserIsFollowing(),
          builder: (context, followersList) {
            if (followersList.connectionState == ConnectionState.waiting) {
              return _getLoadingWidget();
            }
            return StreamBuilder<List<RunModel>>(
              stream: RunRepository.instance().getPosts(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return _getLoadingWidget();
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return _nothingToDisplay();
                }
                var runList = snapshot.data!.where((run) {
                  if (!followersList.hasData || followersList.data!.isEmpty) {
                    return false;
                  }
                  return followersList.data!
                      .map((e) => e.email)
                      .contains(run.email);
                });
                if (runList.isEmpty) {
                  return _nothingToDisplay();
                }
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      Column(
                        children: runList.map((run) {
                          return PostItem(
                            run: run,
                            followersList: followersList.data ?? [],
                            setIsLoading: _setIsLoading,
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 10)
                    ],
                  ),
                );
              },
            );
          },
        ),
        Visibility(
          visible: _isLoading,
          child: Container(
            alignment: Alignment.center,
            color: Theme.of(context).colorScheme.surface,
            child: const LoadingContainer(
              overlayVisibility: false,
            ),
          ),
        )
      ],
    );
  }

  Widget _nothingToDisplay() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 50,
            vertical: 30,
          ),
          child: Image.asset('assets/images/ic_no_follows.png'),
        ),
        Text(
          'No followers\'s post to show',
          style: Theme.of(context).textTheme.headline5,
        ),
        Text(
          'Try following a user today!',
          style: Theme.of(context).textTheme.headline5,
        ),
      ],
    );
  }

  Widget _getLoadingWidget() {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, _) {
        return Padding(
          padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
          child: Material(
            elevation: 10,
            child: Column(
              children: [
                Shimmer.fromColors(
                  baseColor: ClickToRunColors.getbaseColor(context),
                  highlightColor: ClickToRunColors.gethighlightColor(context),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const SizedBox(
                              width: 32,
                              height: 32,
                              child: Material(
                                shape: CircleBorder(),
                              ),
                            ),
                            const SizedBox(width: 5),
                            Container(
                              width: 100,
                              height: 20,
                              color: ClickToRunColors.getbaseColor(context),
                            ),
                          ],
                        ),
                        Container(
                          width: 50,
                          height: 20,
                          color: ClickToRunColors.getbaseColor(context),
                        )
                      ],
                    ),
                  ),
                ),
                Shimmer.fromColors(
                  baseColor: ClickToRunColors.getbaseColor(context),
                  highlightColor: ClickToRunColors.gethighlightColor(context),
                  child: Container(
                    width: MediaQuery.of(context).size.width - 20,
                    height: (MediaQuery.of(context).size.width - 20) / 2,
                    color: ClickToRunColors.getbaseColor(context),
                  ),
                ),
                Shimmer.fromColors(
                  baseColor: ClickToRunColors.getbaseColor(context),
                  highlightColor: ClickToRunColors.gethighlightColor(context),
                  child: Container(
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.all(10),
                    child: Container(
                      width: 200,
                      height: 20,
                      color: ClickToRunColors.getbaseColor(context),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
      itemCount: 5,
    );
  }
}
