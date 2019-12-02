import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget> actions;

  const CustomAppBar({Key key, this.title, this.actions}) : super(key: key);

  @override
  Widget build(BuildContext context) => AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text(title),
        actions: actions,
      );

  @override
  Size get preferredSize => Size.fromHeight(56);
}
