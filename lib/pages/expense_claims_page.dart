import 'dart:async';

import 'package:expense_claims_app/bloc_provider.dart';
import 'package:expense_claims_app/blocs/expense_tile_bloc.dart';
import 'package:expense_claims_app/models/expense_claim_model.dart';
import 'package:expense_claims_app/models/expense_model.dart';
import 'package:expense_claims_app/models/invoice_model.dart';
import 'package:expense_claims_app/repository.dart';
import 'package:expense_claims_app/widgets/collapsible.dart';
import 'package:expense_claims_app/widgets/expense_tile.dart';
import 'package:expense_claims_app/widgets/search_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ExpensesPage extends StatefulWidget {
  final ExpenseType _expenseType;

  const ExpensesPage({@required ExpenseType expenseType})
      : _expenseType = expenseType;

  @override
  _ExpensesPageState createState() => _ExpensesPageState();
}

class _ExpensesPageState extends State<ExpensesPage> {
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
    return WillPopScope(
      onWillPop: _popSearch,
      child: Padding(
        padding: EdgeInsets.fromLTRB(20.0, 0, 20.0, 0),
        child: widget._expenseType == ExpenseType.EXPENSE_CLAIM
            ? StreamBuilder<List<ExpenseClaim>>(
                stream: repository.expenseClaims,
                initialData: [],
                builder: (context, snapshot) => _getType(snapshot),
              )
            : StreamBuilder<List<Invoice>>(
                stream: repository.invoices,
                initialData: [],
                builder: (BuildContext context, AsyncSnapshot snapshot) =>
                    _getType(snapshot)),
      ),
    );
  }

  Widget _getType(AsyncSnapshot snapshot) {
    List<Widget> list = <Widget>[
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
                ),
                onPressed: () {},
              ),
            ),
            Text(
              widget._expenseType == ExpenseType.EXPENSE_CLAIM
                  ? "Expense claims"
                  : "Invoices",
              textAlign: TextAlign.left,
              style: TextStyle(
                fontSize: 30.0,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
      Padding(
        padding: EdgeInsets.only(top: 20.0, bottom: 20.0),
        child: SearchWidget(_searchFocusNode, _searchTextController),
      ),
    ];

    list.addAll(snapshot.data
        .map<Widget>(
          (expense) => Container(
            margin: EdgeInsets.only(bottom: 20.0),
            child: BlocProvider<ExpenseTileBloc>(
              initBloc: (_, bloc) => bloc ?? ExpenseTileBloc(expense: expense),
              onDispose: (_, bloc) {
                bloc.dispose();
              },
              child: ExpenseTile(),
            ),
          ),
        )
        .toList());

    list.add(Container(
      height: 20.0,
    ));

    return ListView(shrinkWrap: true, children: list);
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
      return;
    }
    String txt = _searchTextController.text.trim();

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
