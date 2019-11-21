import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class EmptyListPlaceHolder extends StatelessWidget {
  final String title;
  final Widget subtitle;

  const EmptyListPlaceHolder(
      {Key key, this.title = "This list is empty", this.subtitle})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: <Widget>[
          SizedBox(height: 16.0),
          Icon(
            MdiIcons.folderOpen,
            size: 88,
          ),
          SizedBox(height: 16.0),
          Text(
            title,
            style: Theme.of(context).textTheme.title.copyWith(fontSize: 24.0),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8.0),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: subtitle ?? Container(),
          ),
        ],
      ),
    );
  }
}
