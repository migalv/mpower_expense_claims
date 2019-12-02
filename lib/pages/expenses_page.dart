import 'package:expense_claims_app/bloc_provider.dart';
import 'package:expense_claims_app/blocs/expenses_bloc.dart';
import 'package:expense_claims_app/models/expense_model.dart';
import 'package:expense_claims_app/pages/approved_expenses_page.dart';
import 'package:expense_claims_app/utils.dart';
import 'package:expense_claims_app/widgets/custom_app_bar.dart';
import 'package:expense_claims_app/widgets/empty_list_widget.dart';
import 'package:expense_claims_app/widgets/expense_tile.dart';
import 'package:expense_claims_app/widgets/search_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class ExpensesPage extends StatefulWidget {
  @override
  _ExpensesPageState createState() => _ExpensesPageState();
}

class _ExpensesPageState extends State<ExpensesPage> {
  final TextEditingController _searchTextController = TextEditingController();
  ExpensesBloc _expensesBloc;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

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
      builder: (BuildContext context, AsyncSnapshot expensesSnapshot) =>
          StreamBuilder<int>(
        stream: _expensesBloc.expenseTypeStream,
        builder: (context, expenseTypeSnapshot) =>
            _buildBody(expensesSnapshot, expenseTypeSnapshot),
      ),
    );
  }

  Widget _buildBody(
      AsyncSnapshot expensesSnapshot, AsyncSnapshot<int> expenseTypeSnapshot) {
    List<Widget> list = <Widget>[
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            CustomAppBar(
              title: '',
              actions: <Widget>[
                PopupMenuButton(
                  icon: Icon(MdiIcons.dotsVertical),
                  itemBuilder: (_) => [
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
                      : utils.logOut(context),
                ),
              ],
            ),
            Text(
              expenseTypeSnapshot.data == 0 ? "Expense claims" : "Invoices",
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

    if (expensesSnapshot.data.isEmpty) {
      list.add(EmptyListPlaceHolder(
        title:
            "You don't have any ${expenseTypeSnapshot.data == 0 ? 'expense claims' : 'invoices'}",
        subtitle: "You can create one with the + button",
      ));
    } else
      list.addAll(expensesSnapshot.data
          .map<Widget>((expense) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Container(
                  margin: EdgeInsets.only(bottom: 20.0),
                  child: ExpenseTile(
                    scaffoldKey: _scaffoldKey,
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
