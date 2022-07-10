import 'package:clicktorun_flutter/ui/utils/colors.dart';
import 'package:flutter/material.dart';

class LoadingContainer extends StatelessWidget {
  bool overlayVisibility;
  LoadingContainer({this.overlayVisibility = true});

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
