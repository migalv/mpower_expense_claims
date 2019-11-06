import 'package:expense_claims_app/colors.dart';
import 'package:flutter/material.dart';

class SearchWidget extends StatelessWidget {
  final FocusNode _searchFocusNode;
  final TextEditingController _searchController;

  SearchWidget(this._searchFocusNode, this._searchController, {Key key})
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
        focusNode: _searchFocusNode,
        decoration: InputDecoration(
            hintText: "Search",
            hintStyle: TextStyle(fontSize: 16.0),
            prefixIcon: Icon(Icons.search),
            suffixIcon: _searchFocusNode.hasFocus
                ? IconButton(
                    icon: Icon(Icons.cancel),
                    onPressed: () {
                      _searchFocusNode.unfocus();
                      _searchController.clear();
                    })
                : null,
            border: InputBorder.none),
        style: TextStyle(
          fontSize: 16.0,
        ),
      ),
    );
  }
}
