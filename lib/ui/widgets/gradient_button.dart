import 'package:flutter/material.dart';
import 'package:clicktorun_flutter/ui/utils/colors.dart';

class GradientButton extends StatelessWidget {
  final String text;
  final void Function() onPressed;
  final double width;
  final ShapeBorder shape;
  final EdgeInsetsGeometry? padding;

  const GradientButton({
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
      height: padding == null ? 50 : 50 + padding!.vertical / 2,
      child: Material(
        shape: shape,
        clipBehavior: Clip.hardEdge,
        child: InkWell(
          onTap: onPressed,
          splashColor: ClickToRunColors.darkModeOverlay,
          child: Ink(
            decoration: const BoxDecoration(
              gradient: ClickToRunColors.linearGradient,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  text,
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .headline6
                      ?.copyWith(fontWeight: FontWeight.w700),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
