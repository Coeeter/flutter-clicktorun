import 'package:clicktorun_flutter/ui/utils/colors.dart';
import 'package:flutter/material.dart';

class ClickToRunAppbar {
  String appbarText;
  ClickToRunAppbar(this.appbarText);

  AppBar getAppBar() => AppBar(
    title: Text(this.appbarText),
    flexibleSpace: Container(
      decoration: const BoxDecoration(
        gradient: ClickToRunColors.linearGradient,
      ),
    ),
  );
  
}
