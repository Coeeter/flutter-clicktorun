import 'package:clicktorun_flutter/ui/screens/explore/following_screen.dart';
import 'package:clicktorun_flutter/ui/screens/explore/for_you_screen.dart';
import 'package:clicktorun_flutter/ui/utils/colors.dart';
import 'package:flutter/material.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({Key? key}) : super(key: key);

  @override
  State<ExploreScreen> createState() => ExploreScreenState();
}

class ExploreScreenState extends State<ExploreScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
    return Container(
      height: double.infinity,
      width: double.infinity,
      alignment: Alignment.topCenter,
      child: Column(
        children: [
          _getTabs(labelColor, context),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              physics: const BouncingScrollPhysics(),
              children: const [
                ForYouScreen(),
                FollowingScreen(),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _getTabs(Color labelColor, BuildContext context) {
    return Material(
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
          labelStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                fontFamily: 'Roboto',
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
          tabs: const [
            Tab(text: "For you"),
            Tab(text: "Following"),
          ],
        ),
      ),
    );
  }
}
