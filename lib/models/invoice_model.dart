import 'package:expense_claims_app/models/expense_model.dart';

class Invoice extends Expense {
  final DateTime dueDate;

  Invoice({
    this.dueDate,
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

  Invoice.fromJson(String id, final Map<String, dynamic> json)
      : this.dueDate =
            DateTime.fromMillisecondsSinceEpoch(json[Expense.DUE_DATE_KEY]),
        super.fromJson(json, id);

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = super.toJson();
    json[Expense.DUE_DATE_KEY] = this.dueDate.millisecondsSinceEpoch;
    return json;
  }
}
