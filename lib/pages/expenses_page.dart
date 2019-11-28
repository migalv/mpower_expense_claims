import 'package:expense_claims_app/bloc_provider.dart';
import 'package:expense_claims_app/blocs/expenses_bloc.dart';
import 'package:expense_claims_app/blocs/login_bloc.dart';
import 'package:expense_claims_app/models/expense_model.dart';
import 'package:expense_claims_app/pages/approved_expenses_page.dart';
import 'package:expense_claims_app/pages/login_page.dart';
import 'package:expense_claims_app/repository.dart';
import 'package:expense_claims_app/utils.dart';
import 'package:expense_claims_app/widgets/empty_list_widget.dart';
import 'package:expense_claims_app/widgets/expense_tile.dart';
import 'package:expense_claims_app/widgets/search_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class ExpensesPage extends StatefulWidget {
  final ExpenseType _expenseType;
  final GlobalKey _scaffoldKey;
  final Function _editExpense;

  const ExpensesPage({
    @required ExpenseType expenseType,
    @required GlobalKey scaffoldKey,
    @required Function editExpense,
  })  : _expenseType = expenseType,
        _scaffoldKey = scaffoldKey,
        _editExpense = editExpense;

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
    return StreamBuilder<List<Expense>>(
        stream: _expensesBloc.expenses,
        initialData: [],
        builder: (BuildContext context, AsyncSnapshot snapshot) =>
            _buildBody(snapshot));
  }

  Widget _buildBody(AsyncSnapshot snapshot) {
    List<Widget> list = <Widget>[
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            AppBar(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              elevation: 0,
              actions: <Widget>[
                PopupMenuButton(
                  icon: Icon(MdiIcons.dotsVertical),
                  itemBuilder: (_) => [
                    PopupMenuItem(
                      child: Row(
                        children: <Widget>[
                          Icon(MdiIcons.fileDocumentBoxCheck),
                          SizedBox(
                            width: 8.0,
                          ),
                          Text("Approved Expenses"),
                        ],
                      ),
                      value: 0,
                    ),
                    PopupMenuItem(
                      child: Row(
                        children: <Widget>[
                          Icon(
                            MdiIcons.logout,
                            color: Theme.of(context).errorColor.withAlpha(155),
                          ),
                          SizedBox(
                            width: 8.0,
                          ),
                          Text(
                            "Log out",
                            style:
                                TextStyle(color: Theme.of(context).errorColor),
                          ),
                        ],
                      ),
                      value: 1,
                    ),
                  ],
                  onSelected: (value) => value == 0
                      ? utils.push(context, ApprovedExpensesPage())
                      : _logOut(),
                ),
              ],
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
        padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
        child: SearchWidget(
          _searchTextController,
          onClearField: _closeSearchBar,
        ),
      ),
    ];

    if (snapshot.data.isEmpty) {
      list.add(EmptyListPlaceHolder(
        title:
            "You don't have any ${widget._expenseType == ExpenseType.EXPENSE_CLAIM ? 'expense claims' : 'invoices'}",
        subtitle: "You can create one with the + button",
      ));
    } else
      list.addAll(snapshot.data
          .map<Widget>((expense) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Container(
                  margin: EdgeInsets.only(bottom: 20.0),
                  child: ExpenseTile(
                    scaffoldKey: widget._scaffoldKey,
                    expense: expense,
                    editExpense: widget._editExpense,
                  ),
                ),
              ))
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

  void _logOut() {
    repository.logOut();
    utils.pushReplacement(
      context,
      BlocProvider<LoginBloc>(
        initBloc: (_, bloc) => bloc ?? LoginBloc(),
        onDispose: (_, bloc) => bloc.dispose(),
        child: LoginPage(),
      ),
    );
  }
}
