import 'package:flutter/material.dart';

class SearchWidget extends StatelessWidget {
  final TextEditingController _searchController;
  final Function onClearField;

  SearchWidget(this._searchController, {Key key, @required this.onClearField})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white12,
        borderRadius: BorderRadius.circular(24.0),
      ),
      height: 40.0,
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
            hintText: "Search",
            hintStyle: TextStyle(fontSize: 16.0),
            prefixIcon: Icon(Icons.search),
            suffixIcon: (_searchController?.text?.length ?? 0) > 0
                ? IconButton(
                    icon: Icon(Icons.cancel), onPressed: () => onClearField())
                : null,
            border: InputBorder.none),
        style: TextStyle(
          fontSize: 16.0,
        ),
      ),
    );
  }
}
