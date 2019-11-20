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
    double vat,
    String approvedBy,
    String approvedByName,
    String createdBy,
    String costCentreGroup,
    List<String> availableTo,
    List<Map<String, String>> attachments,
    int createdAt,
    String receiptNumber,
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
          createdBy: createdBy,
          costCentreGroup: costCentreGroup,
          availableTo: availableTo,
          approvedByName: approvedByName,
          attachments: attachments,
          createdAt: createdAt,
          receiptNumber: receiptNumber,
        );

  Invoice.fromJson(final Map<String, dynamic> json, {String id})
      : this.dueDate = json.containsKey(Expense.DUE_DATE_KEY)
            ? DateTime.fromMillisecondsSinceEpoch(json[Expense.DUE_DATE_KEY])
            : null,
        super.fromJson(json, id: id);

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = super.toJson();
    json[Expense.DUE_DATE_KEY] = this.dueDate.millisecondsSinceEpoch;
    return json;
  }
}
