import 'package:expense_claims_app/models/category_model.dart';
import 'package:expense_claims_app/models/currency_model.dart';
import 'package:expense_claims_app/models/expense_model.dart';
import 'package:expense_claims_app/repository.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

class ExpenseTile extends StatelessWidget {
  final Expense expense;

  const ExpenseTile({Key key, @required this.expense}) : super(key: key);

  Widget build(BuildContext context) {
    return ListTile(
      title: Text(expense.description),
      subtitle: _buildCategorySubTitle(expense.category),
      trailing: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Text(timeago.format(expense.date)),
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
    Currency currency = repository.getCurrencyWithId(expense.currency);

    return Text(expense.gross.toString() + " " + currency.symbol);
  }
}
