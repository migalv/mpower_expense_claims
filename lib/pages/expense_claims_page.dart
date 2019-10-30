import 'dart:async';

import 'package:expense_claims_app/bloc_provider.dart';
import 'package:expense_claims_app/blocs/expense_tile_bloc.dart';
import 'package:expense_claims_app/models/expense_claim_model.dart';
import 'package:expense_claims_app/repository.dart';
import 'package:expense_claims_app/widgets/collapsible.dart';
import 'package:expense_claims_app/widgets/expense_tile.dart';
import 'package:expense_claims_app/widgets/search_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ExpenseClaimsPage extends StatefulWidget {
  @override
  _ExpenseClaimsPageState createState() => _ExpenseClaimsPageState();
}

class _ExpenseClaimsPageState extends State<ExpenseClaimsPage> {
  final TextEditingController _searchTextController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _isSearching = false;
  Timer _searchTimer;

  @override
  initState() {
    super.initState();

    _searchTextController.addListener(() {
      updateSearch();
    });

    _searchFocusNode.addListener(() {
      setState(() {
        _isSearching = _searchFocusNode.hasFocus;
        updateSearch();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    EdgeInsets devicePadding = MediaQuery.of(context).padding;
    return WillPopScope(
      onWillPop: _popSearch,
      child: Padding(
        padding: EdgeInsets.only(top: devicePadding.top),
        child: SingleChildScrollView(
          padding: EdgeInsets.only(top: 0.0, left: 20, right: 20, bottom: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Collapsible(
                isCollapsed: _isSearching,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        icon: Icon(
                          Icons.settings,
                          color: Colors.black45,
                        ),
                        onPressed: () {},
                      ),
                    ),
                    Text("Expense claims",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 30.0,
                          fontWeight: FontWeight.w500,
                        )),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 22.0),
                child: SearchWidget(_searchFocusNode, _searchTextController),
              ),
              StreamBuilder<List<ExpenseClaim>>(
                stream: repository.expenseClaims,
                initialData: [],
                builder: (context, snapshot) => ListView(
                  shrinkWrap: true,
                  children: snapshot.data
                      .map(
                        (expense) => Container(
                          margin: EdgeInsets.only(bottom: 20.0),
                          child: BlocProvider<ExpenseTileBloc>(
                            initBloc: (_, bloc) =>
                                bloc ?? ExpenseTileBloc(expenseId: expense.id),
                            onDispose: (_, bloc) {
                              bloc.dispose();
                            },
                            child: ExpenseTile(),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  //
  // METHDOS
  Future<bool> _popSearch() {
    if (_isSearching) {
      setState(() {
        _searchFocusNode.unfocus();
        _searchTextController.clear();
        _isSearching = false;
      });
      return Future(() => false);
    } else {
      Navigator.of(context).pop(true);
      return Future(() => true);
    }
  }

  updateSearch() {
    cancelSearch();
    if (!_isSearching) {
      setState(() {
        // _searchResults = List<TimelineEntry>();
      });
      return;
    }
    String txt = _searchTextController.text.trim();

    /// Perform search.
    ///
    /// A [Timer] is used to prevent unnecessary searches while the user is typing.
    _searchTimer = Timer(Duration(milliseconds: txt.isEmpty ? 0 : 350), () {
      // Set<TimelineEntry> res = SearchManager.init().performSearch(txt);
      // setState(() {
      //   _searchResults = res.toList();
      // });
    });
  }

  cancelSearch() {
    if (_searchTimer != null && _searchTimer.isActive) {
      /// Remove old timer.
      _searchTimer.cancel();
      _searchTimer = null;
    }
  }
}
