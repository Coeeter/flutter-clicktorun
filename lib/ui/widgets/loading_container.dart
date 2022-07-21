import 'package:clicktorun_flutter/ui/utils/colors.dart';
import 'package:flutter/material.dart';

class LoadingContainer extends StatelessWidget {
  final bool overlayVisibility;
  const LoadingContainer({
    this.overlayVisibility = true,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: overlayVisibility ? Theme.of(context).focusColor : null,
      ),
      child: const CircularProgressIndicator(
        color: ClickToRunColors.secondary,
      ),
    );
  }
}
