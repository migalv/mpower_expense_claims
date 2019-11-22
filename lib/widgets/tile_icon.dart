import 'package:flutter/material.dart';

class TileIcon extends StatelessWidget {
  final IconData iconData;
  final Color backgroundColor;
  final Color iconColor;

  const TileIcon({
    Key key,
    this.iconData,
    this.backgroundColor = Colors.white30,
    this.iconColor = Colors.white,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          width: 48.0,
          height: 48.0,
          decoration: BoxDecoration(
            color: backgroundColor,
            shape: BoxShape.circle,
          ),
          child: iconData != null
              ? Icon(
                  iconData,
                  color: iconColor,
                )
              : Container(),
        ),
      );
}
