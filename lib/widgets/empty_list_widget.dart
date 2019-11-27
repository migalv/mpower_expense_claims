import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class EmptyListPlaceHolder extends StatelessWidget {
  final String title;
  final String subtitle;

  const EmptyListPlaceHolder(
      {Key key, this.title = "This list is empty", this.subtitle})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: <Widget>[
          SizedBox(height: 56.0),
          CircleAvatar(
            child: Icon(
              MdiIcons.folderOpen,
              size: 48,
              color: Colors.white70,
            ),
            radius: 44,
            backgroundColor: Colors.white10,
          ),
          SizedBox(height: 16.0),
          Text(
            title,
            style: Theme.of(context).textTheme.title,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 12.0),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Text(
                  subtitle ?? '',
                  style: Theme.of(context).textTheme.body1,
                ) ??
                Container(),
          ),
        ],
      ),
    );
  }
}
