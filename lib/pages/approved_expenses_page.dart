import 'package:expense_claims_app/models/expense_model.dart';
import 'package:expense_claims_app/repository.dart';
import 'package:expense_claims_app/widgets/expense_tile.dart';
import 'package:flutter/material.dart';

class ApprovedExpensesPage extends StatefulWidget {
  @override
  _ApprovedExpensesPageState createState() => _ApprovedExpensesPageState();
}

class _ApprovedExpensesPageState extends State<ApprovedExpensesPage> {
  GlobalKey<ScaffoldState> _scaffoldKey;

  @override
  void initState() {
    _scaffoldKey = GlobalKey<ScaffoldState>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        key: _scaffoldKey,
        body: StreamBuilder<List<Expense>>(
            stream: repository.approvedByMe,
            builder: (context, snapshot) {
              List<Widget> list = [];
              list.add(_buildTitle());
              list.addAll(_buildListTiles(snapshot.data));
              return ListView(
                children: list,
              );
            }),
      );

  Widget _buildTitle() => Padding(
        padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0.0),
        child: Row(
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
            Text(
              "Approved expenses",
              style: Theme.of(context).textTheme.title,
            ),
          ],
        ),
      );

  List<Widget> _buildListTiles(List<Expense> expenses) {
    List<Widget> tiles = [];
    if (expenses == null) return [];
    expenses.forEach((expense) => tiles.add(Container(
          margin: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 0.0),
          child: ExpenseTile(
            scaffoldKey: _scaffoldKey,
            expense: expense,
            deletable: false,
          ),
        )));
    return tiles;
  }
}
