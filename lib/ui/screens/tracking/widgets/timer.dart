import 'package:flutter/material.dart';

class TimerText extends StatefulWidget {
  const TimerText({Key? key}) : super(key: key);

  @override
  State<TimerText> createState() => TimerTextState();
}

class TimerTextState extends State<TimerText> {
  String text = "00:00:00";

  void setText(String timeTaken) {
    setState(() {
      text = timeTaken;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: (MediaQuery.of(context).size.width - 20) / 3,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Align(
        alignment: Alignment.centerRight,
        child: Text(
          text,
          style: TextStyle(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Colors.black,
            fontSize: 20,
          ),
        ),
      ),
    );
  }
}
