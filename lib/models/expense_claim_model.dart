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
    double vat,
    String approvedBy,
    String approvedByName,
    String createdBy,
    String costCentreGroup,
    List<String> availableTo,
    List<Map<String, String>> attachments,
    int createdAt,
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
        );

  ExpenseClaim.fromJson(final Map<String, dynamic> json, {String id})
      : super.fromJson(json, id: id);

  Map<String, dynamic> toJson() => super.toJson();
}
