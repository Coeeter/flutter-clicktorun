import 'package:flutter/material.dart';

class ForYouScreen extends StatefulWidget {
  const ForYouScreen({Key? key}) : super(key: key);

  @override
  State<ForYouScreen> createState() => _ForYouScreenState();
}

class _ForYouScreenState extends State<ForYouScreen> {
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Text(
        "For you",
        style: Theme.of(context).textTheme.headline5,
      ),
    );
  }
}
