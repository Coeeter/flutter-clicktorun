import 'package:clicktorun_flutter/data/model/run_model.dart';
import 'package:clicktorun_flutter/data/repositories/run_repository.dart';
import 'package:clicktorun_flutter/ui/screens/explore/post_item.dart';
import 'package:clicktorun_flutter/ui/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ForYouScreen extends StatefulWidget {
  const ForYouScreen({Key? key}) : super(key: key);

  @override
  State<ForYouScreen> createState() => _ForYouScreenState();
}

class _ForYouScreenState extends State<ForYouScreen> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<RunModel>>(
      stream: RunRepository.instance().getPosts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _getLoadingWidget();
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _nothingToDisplay();
        }
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: snapshot.data!.map((run) {
              return PostItem(run: run);
            }).toList(),
          ),
        );
      },
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
          child: Image.asset('assets/images/ic_no_posts.png'),
        ),
        Text(
          'No posts to show here',
          style: Theme.of(context).textTheme.headline5,
        ),
        Text(
          'Try sharing a run today!',
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
