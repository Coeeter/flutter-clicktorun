import 'package:flutter/material.dart';

import '../utils/colors.dart';

class GradientButton extends StatelessWidget {
  String text;
  void Function() onPressed;
  double width;
  ShapeBorder shape;

  GradientButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.width = double.infinity,
    this.shape = const StadiumBorder(),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: 50,
      child: RaisedButton(
        onPressed: onPressed,
        shape: shape,
        padding: const EdgeInsets.all(0.0),
        splashColor: Theme.of(context).focusColor,
        child: Ink(
          decoration: BoxDecoration(
            gradient: ClickToRunColors.linearGradient,
            borderRadius: BorderRadius.circular(30.0),
          ),
          child: Container(
            alignment: Alignment.center,
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headline6,
            ),
          ),
        ),
      ),
    );
  }
}
