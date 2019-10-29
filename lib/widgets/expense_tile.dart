import 'package:expense_claims_app/models/category_model.dart';
import 'package:expense_claims_app/models/currency_model.dart';
import 'package:expense_claims_app/models/expense_model.dart';
import 'package:expense_claims_app/respository.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

class ExpenseTile extends StatefulWidget {
  final Expense expense;

  const ExpenseTile({Key key, @required this.expense}) : super(key: key);

  @override
  _ExpenseTileState createState() => _ExpenseTileState();
}

class _ExpenseTileState extends State<ExpenseTile> {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(widget.expense.description),
      subtitle: _buildCategorySubTitle(widget.expense.category),
      trailing: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Text(timeago.format(widget.expense.date)),
          SizedBox(height: 16.0),
          _buildCost(),
        ],
      ),
      onTap: () {},
    );
  }

  Widget _buildCategorySubTitle(String categoryId) {
    Category category = repository.getCategoryWithId(categoryId);

    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: Row(
        children: <Widget>[
          Icon(category.icon, size: 18.0),
          Text(category.name),
        ],
      ),
    );
  }

  Widget _buildCost() {
    Currency currency = repository.getCurrencyWithId(widget.expense.currency);

    return Text(widget.expense.gross.toString() + " " + currency.symbol);
  }
}
