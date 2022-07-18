import 'package:clicktorun_flutter/ui/utils/colors.dart';
import 'package:flutter/material.dart';

class ClickToRunAppbar {
  String appbarText;
  ClickToRunAppbar(this.appbarText);

  AppBar getAppBar({List<Widget>? actions}) => AppBar(
        title: Text(
          appbarText,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontFamily: 'Roboto',
          ),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: ClickToRunColors.linearGradient,
          ),
        ),
        actions: actions,
      );
}
