import 'package:expense_claims_app/models/expense_model.dart';

class ExpenseClaim extends Expense {
  ExpenseClaim({
    String id,
    String country,
    String category,
    DateTime date,
    String description,
    String currency,
    double gross,
    double net,
    int vat,
    String approvedBy,
  }) : super(
          id: id,
          approvedBy: approvedBy,
          country: country,
          category: category,
          currency: currency,
          date: date,
          description: description,
          gross: gross,
          net: net,
          vat: vat,
        );

  ExpenseClaim.fromJson(String id, final Map<String, dynamic> json)
      : super.fromJson(json, id);

  Map<String, dynamic> toJson() => super.toJson();
}
