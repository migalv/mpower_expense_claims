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
  final GlobalKey scaffoldKey;

  const ExpensesPage({
    @required ExpenseType expenseType,
    @required this.scaffoldKey,
  }) : _expenseType = expenseType;

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
            _getType(snapshot));
  }

  Widget _getType(AsyncSnapshot snapshot) {
    List<Widget> list = <Widget>[
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: <Widget>[
                  GestureDetector(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Row(
                        children: <Widget>[
                          Icon(MdiIcons.logout),
                          SizedBox(width: 4.0),
                          Text("Logout"),
                        ],
                      ),
                    ),
                    onTap: () => _logOut(),
                  ),
                  Expanded(
                    child: Container(),
                  ),
                  IconButton(
                    alignment: Alignment.centerLeft,
                    icon: Icon(MdiIcons.fileDocumentBoxCheck),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ApprovedExpensesPage(),
                      ),
                    ),
                    tooltip: "Approved expenses",
                  ),
                ],
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
        padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
        child: SearchWidget(
          _searchTextController,
          onClearField: _closeSearchBar,
        ),
      ),
    ];

    if (snapshot.data.isEmpty) {
      String title = "You don't have any ";
      Widget subtitle = Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            "You can create one with the ",
            style: Theme.of(context).textTheme.subtitle,
          ),
          Icon(Icons.add),
          Text(" button", style: Theme.of(context).textTheme.subtitle),
        ],
      );
      title += widget._expenseType == ExpenseType.EXPENSE_CLAIM
          ? "expense claims"
          : "invoices";
      list.add(EmptyListPlaceHolder(
        title: title,
        subtitle: subtitle,
      ));
    } else
      list.addAll(snapshot.data
          .map<Widget>((expense) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Container(
                  margin: EdgeInsets.only(bottom: 20.0),
                  child: ExpenseTile(
                    scaffoldKey: widget.scaffoldKey,
                    expense: expense,
                  ),
                ),
              ))
          .toList());

    list.add(Container(
      height: 20.0,
    ));

    return ListView(shrinkWrap: true, children: list);
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
