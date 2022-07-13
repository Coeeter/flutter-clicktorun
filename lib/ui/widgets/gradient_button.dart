import 'package:flutter/material.dart';
import 'package:clicktorun_flutter/ui/utils/colors.dart';

class GradientButton extends StatelessWidget {
  String text;
  void Function() onPressed;
  double width;
  ShapeBorder shape;
  EdgeInsetsGeometry? padding;

  GradientButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.width = double.infinity,
    this.shape = const StadiumBorder(),
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: padding,
      height: padding == null ? 50 : 60,
      child: RaisedButton(
        onPressed: onPressed,
        shape: shape,
        padding: const EdgeInsets.all(0.0),
        splashColor: ClickToRunColors.darkModeOverlay,
        child: Ink(
          decoration: BoxDecoration(
            gradient: ClickToRunColors.linearGradient,
            borderRadius: BorderRadius.circular(30.0),
          ),
          child: Container(
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  text,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headline6?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
