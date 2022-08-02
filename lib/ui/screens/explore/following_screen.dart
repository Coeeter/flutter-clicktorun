import 'package:flutter/material.dart';

class FollowingScreen extends StatefulWidget {
  const FollowingScreen({ Key? key }) : super(key: key);

  @override
  State<FollowingScreen> createState() => _FollowingScreenState();
}

class _FollowingScreenState extends State<FollowingScreen> {
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Text(
        "Following",
        style: Theme.of(context).textTheme.headline5,
      ),
    );
  }
}