import 'package:clicktorun_flutter/ui/utils/colors.dart';
import 'package:flutter/material.dart';

class CustomAppbar extends StatefulWidget implements PreferredSizeWidget {
  @override
  final Size preferredSize;
  String title;
  List<Widget>? actions;
  double elevation;

  CustomAppbar({
    required this.title,
    this.actions,
    this.elevation = 4,
    Key? key,
  })  : preferredSize = const Size.fromHeight(kToolbarHeight),
        super(key: key);

  @override
  State<CustomAppbar> createState() => CustomAppbarState();
}

class CustomAppbarState extends State<CustomAppbar> {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        widget.title,
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
      actions: widget.actions,
      elevation: widget.elevation,
    );
  }

  void setTitle(String title) {
    setState(() {
      widget.title = title;
    });
  }
}
