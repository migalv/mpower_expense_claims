import 'package:flutter/material.dart';

class ExpensesList extends StatefulWidget {
  @override
  _ExpensesListState createState() => _ExpensesListState();
}

class _ExpensesListState extends State<ExpensesList> {
  @override
  Widget build(BuildContext context) => ListView(
    children: _buildExpensesList()
  );

  List<Widget> _buildExpensesList(){
    List<Widget> expensesTiles = [];


  }
}
