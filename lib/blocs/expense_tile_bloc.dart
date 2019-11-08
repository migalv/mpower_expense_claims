import 'package:expense_claims_app/models/category_model.dart';
import 'package:expense_claims_app/models/expense_model.dart';
import 'package:expense_claims_app/repository.dart';

class ExpenseTileBloc {
  final Expense _expense;

  ExpenseTileBloc({Expense expense}) : _expense = expense;

  Expense get expense => _expense;

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
