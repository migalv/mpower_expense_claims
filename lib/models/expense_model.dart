import 'package:expense_claims_app/models/expense_claim_model.dart';
import 'package:expense_claims_app/models/invoice_model.dart';

abstract class Expense {
  final String id;
  final String approvedBy;
  final String country;
  final String category;
  final String currency;
  final DateTime date;
  final String description;
  final double gross;
  final double net;
  final double vat;

  Expense({
    this.id,
    this.approvedBy,
    this.country,
    this.category,
    this.currency,
    this.date,
    this.description,
    this.gross,
    this.net,
    this.vat,
  });

  Expense.fromJson(Map<String, dynamic> json, {String id})
      : this.id = id,
        this.country = json[COUNTRY_KEY],
        this.category = json[CATEGORY_KEY],
        this.date = DateTime.fromMillisecondsSinceEpoch(json[DATE_KEY]),
        this.description = json[DESCRIPTION_KEY],
        this.currency = json[CURRENCY_KEY],
        this.gross = json[GROSS_KEY],
        this.net = json[NET_KEY],
        this.vat = json[VAT_KEY],
        this.approvedBy = json[APPROVED_BY_KEY];

  Map<String, dynamic> toJson() => {
        APPROVED_BY_KEY: this.approvedBy,
        COUNTRY_KEY: this.country,
        CATEGORY_KEY: this.category,
        CURRENCY_KEY: this.currency,
        DATE_KEY: this.date.millisecondsSinceEpoch,
        DESCRIPTION_KEY: this.description,
        GROSS_KEY: this.gross,
        NET_KEY: this.net,
        VAT_KEY: this.vat,
      };

  @override
  bool operator ==(expense) => expense is Expense && expense.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    String expenseType;
    if (this is ExpenseClaim)
      expenseType = "Expense claim";
    else if (this is Invoice) expenseType = "Invoice";

    return "$expenseType: {\n\tid: $id,\n\tdescription: $description\n}";
  }

  static const String COUNTRY_KEY = "country";
  static const String CATEGORY_KEY = "category";
  static const String DATE_KEY = "date";
  static const String DUE_DATE_KEY = "due_date";
  static const String DESCRIPTION_KEY = "description";
  static const String CURRENCY_KEY = "currency";
  static const String GROSS_KEY = "gross";
  static const String NET_KEY = "net";
  static const String VAT_KEY = "vat";
  static const String APPROVED_BY_KEY = "approved_by";
}

enum ExpenseType {
  EXPENSE_CLAIM,
  INVOICE,
}
