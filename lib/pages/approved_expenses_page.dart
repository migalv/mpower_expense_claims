import 'package:expense_claims_app/models/expense_model.dart';
import 'package:expense_claims_app/repository.dart';
import 'package:expense_claims_app/utils.dart';
import 'package:expense_claims_app/widgets/custom_app_bar.dart';
import 'package:expense_claims_app/widgets/empty_list_widget.dart';
import 'package:expense_claims_app/widgets/expense_tile.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

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
            initialData: [],
            builder: (context, snapshot) {
              List<Widget> list = [];
              list.add(_buildTitle());
              if (snapshot.data.isEmpty)
                list.add(EmptyListPlaceHolder(
                  title: "You don't have any expenses approved by you",
                  subtitle:
                      "If someone puts you as an approver the expense will be shown here",
                ));
              else
                list.addAll(_buildListTiles(snapshot.data));
              return ListView(
                children: list,
              );
            }),
      );

  Widget _buildTitle() => Padding(
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
              'Approved expenses',
              textAlign: TextAlign.left,
              style: TextStyle(
                fontSize: 30.0,
                fontWeight: FontWeight.w500,
              ),
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
          ),
        )));
    return tiles;
  }
}
