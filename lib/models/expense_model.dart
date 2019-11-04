import 'package:expense_claims_app/models/expense_claim_model.dart';
import 'package:expense_claims_app/models/invoice_model.dart';
import 'package:expense_claims_app/repository.dart';

abstract class Expense {
  final String id;
  final String approvedBy;
  final String approvedByName;
  final String country;
  final String category;
  final String currency;
  final DateTime date;
  final String description;
  final double gross;
  final double net;
  final double vat;
  final String createdBy;
  final String costCentreGroup;
  final List<String> availableTo;

  Expense({
    this.id,
    this.approvedBy,
    this.approvedByName,
    this.country,
    this.category,
    this.currency,
    this.date,
    this.description,
    this.gross,
    this.net,
    this.vat,
    this.createdBy,
    this.costCentreGroup,
    this.availableTo,
  });

  Expense.fromJson(Map<String, dynamic> json, {String id})
      : this.id = id,
        this.country = json[COUNTRY_KEY],
        this.category = json[CATEGORY_KEY],
        this.date = json.containsKey(DATE_KEY)
            ? DateTime.fromMillisecondsSinceEpoch(json[DATE_KEY])
            : null,
        this.description = json[DESCRIPTION_KEY],
        this.currency = json[CURRENCY_KEY],
        this.gross = json[GROSS_KEY],
        this.net = json[NET_KEY],
        this.vat = json[VAT_KEY],
        this.approvedBy = json[APPROVED_BY_KEY],
        this.approvedByName = json[APPROVED_BY_NAME_KEY],
        this.createdBy = json[CREATED_BY_KEY],
        this.costCentreGroup = json[COST_CENTRE_GROUP],
        this.availableTo = json[AVAILABLE_TO].cast<String>();

  Map<String, dynamic> toJson() => {
        APPROVED_BY_KEY: this.approvedBy,
        APPROVED_BY_NAME_KEY: this.approvedByName,
        COUNTRY_KEY: this.country,
        CATEGORY_KEY: this.category,
        CURRENCY_KEY: this.currency,
        DATE_KEY: this.date.millisecondsSinceEpoch,
        DESCRIPTION_KEY: this.description,
        GROSS_KEY: this.gross,
        NET_KEY: this.net,
        VAT_KEY: this.vat,
        CREATED_BY_KEY: this.createdBy,
        COST_CENTRE_GROUP: this.costCentreGroup,
        AVAILABLE_TO: this.availableTo,
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
  static const String CREATED_BY_KEY = "created_by";
  static const String AVAILABLE_TO = "availableTo";
  static const String COST_CENTRE_GROUP = "cost_centre_group";
  static const String APPROVED_BY_NAME_KEY = "approved_by_name";
}

enum ExpenseType {
  EXPENSE_CLAIM,
  INVOICE,
}
