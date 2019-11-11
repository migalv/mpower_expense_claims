import 'package:expense_claims_app/bloc_provider.dart';
import 'package:expense_claims_app/blocs/expense_tile_bloc.dart';
import 'package:expense_claims_app/blocs/expenses_bloc.dart';
import 'package:expense_claims_app/models/expense_model.dart';
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
  ExpensesBloc _expensesBloc;

  @override
  void initState() {
    _searchTextController
        .addListener(() => _searchBy(_searchTextController.text));
    super.initState();
  }

  @override
  void didChangeDependencies() {
    _expensesBloc = Provider.of<ExpensesBloc>(context);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.0, 0, 20.0, 0),
      child: StreamBuilder<List<Expense>>(
          stream: _expensesBloc.expenses,
          initialData: [],
          builder: (BuildContext context, AsyncSnapshot snapshot) =>
              _getType(snapshot)),
    );
  }

  Widget _getType(AsyncSnapshot snapshot) {
    List<Widget> list = <Widget>[
      Column(
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
      Padding(
        padding: EdgeInsets.only(top: 20.0, bottom: 20.0),
        child: SearchWidget(
          _searchTextController,
          onClearField: _closeSearchBar,
        ),
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

  void _closeSearchBar() {
    Future.delayed(Duration(milliseconds: 50)).then((_) {
      _searchTextController.clear();
    });
    _expensesBloc.startSearch(false);
  }

  void _searchBy(String searchBy) {
    _expensesBloc.startSearch(true);
    _expensesBloc.searchBy.add(_searchTextController.text);
  }
}
