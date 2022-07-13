import 'package:flutter/material.dart';

class TimerText extends StatefulWidget {
  String text;
  TimerText({
    required this.text,
  });
  final _TimerTextState _state = _TimerTextState();
  void setText(int timeTaken) => _state.setText(timeTaken);

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

  void setText(int timeTakenInMilliseconds) {
    int seconds = timeTakenInMilliseconds ~/ 1000 % 60;
    int minutes = timeTakenInMilliseconds ~/ 1000 ~/ 60 % 60;
    int hours = timeTakenInMilliseconds ~/ 1000 ~/ 60 ~/ 60;
    setState(() {
      widget.text =
          "${_formatTime(hours)}:${_formatTime(minutes)}:${_formatTime(seconds)}";
    });
  }

  String _formatTime(int timeValue) =>
      timeValue < 10 ? "0$timeValue" : timeValue.toString();
}
