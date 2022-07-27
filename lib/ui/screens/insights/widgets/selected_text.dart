import 'package:flutter/material.dart';

class SelectedText extends StatefulWidget {
  const SelectedText({Key? key}) : super(key: key);

  @override
  State<SelectedText> createState() => SelectedTextState();
}

class SelectedTextState extends State<SelectedText> {
  String? _text;

  void setText(String value) {
    setState(() {
      _text = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_text == null) return Container();
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Text(
        _text!,
        style: Theme.of(context)
            .textTheme
            .headline5!
            .copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }
}
