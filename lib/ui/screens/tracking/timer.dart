import 'package:flutter/material.dart';

class TimerText extends StatefulWidget {
  String text;
  TimerText({
    required this.text,
  });
  final _TimerTextState _state = _TimerTextState();
  void setText(String timeTaken) => _state.setText(timeTaken);

  @override
  State<TimerText> createState() => _state;
}

class _TimerTextState extends State<TimerText> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: (MediaQuery.of(context).size.width - 20) / 3,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Align(
        alignment: Alignment.centerRight,
        child: Text(
          widget.text,
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

  void setText(String timeTaken) {
    setState(() {
      widget.text = timeTaken;
    });
  }
}
