import 'dart:async';

import 'package:expense_claims_app/models/category_model.dart';
import 'package:expense_claims_app/models/expense_model.dart';
import 'package:expense_claims_app/repository.dart';

class ExpenseTileBloc {
  final String _expenseId;
  Expense _expense;

  Stream<Expense> get expense => repository.expenseClaims.transform(
        StreamTransformer.fromHandlers(
          handleData: (List<Expense> list, EventSink<Expense> eventSink) {
            Expense expense =
                list?.singleWhere((expense) => expense.id == _expenseId);
            _expense = expense;

            eventSink.add(expense);
          },
        ),
      );

  ExpenseTileBloc({String expenseId}) : _expenseId = expenseId;

  Category get category => repository.categories.value?.singleWhere(
      (category) => category.id == _expense.category,
      orElse: () => null);

  String get currencySymbol => repository.currencies.value
      ?.singleWhere((currency) => currency.id == _expense.currency,
          orElse: () => null)
      ?.symbol;

  String get country => repository.countries.value
      ?.singleWhere((country) => country.id == _expense.country,
          orElse: () => null)
      ?.name;

  void dispose() {}
}
