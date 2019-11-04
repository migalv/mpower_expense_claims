import 'package:expense_claims_app/models/expense_model.dart';

class FormTemplate {
  final String id;
  final String name;
  final String approvedBy;
  final String country;
  final String category;
  final String currency;
  final String description;
  final double vat;
  final List<String> availableTo;
  final ExpenseType expenseType;

  FormTemplate({
    this.id,
    this.name,
    this.approvedBy,
    this.country,
    this.category,
    this.currency,
    this.description,
    this.vat,
    this.availableTo,
    this.expenseType,
  });

  FormTemplate.fromJson(final Map<String, dynamic> json, {String id})
      : this.id = id,
        this.name = json[NAME_KEY],
        this.country = json[COUNTRY_KEY],
        this.category = json[CATEGORY_KEY],
        this.description = json[DESCRIPTION_KEY],
        this.currency = json[CURRENCY_KEY],
        this.vat = json[VAT_KEY]?.toDouble() ?? 0.0,
        this.approvedBy = json[APPROVED_BY_KEY],
        this.availableTo = json[AVAILABLE_TO_KEY]?.cast<String>(),
        this.expenseType = ExpenseType.values[json[EXPENSE_TYPE]];

  Map<String, dynamic> toJson() => {
        NAME_KEY: this.name,
        COUNTRY_KEY: this.country,
        CATEGORY_KEY: this.category,
        DESCRIPTION_KEY: this.description,
        CURRENCY_KEY: this.currency,
        VAT_KEY: this.vat,
        APPROVED_BY_KEY: this.approvedBy,
        AVAILABLE_TO_KEY: this.availableTo,
        EXPENSE_TYPE: this.expenseType.index,
      };

  @override
  String toString() {
    return "Expense Template: {\n\t id: $id,\n\t name:$name\n}";
  }

  static const String NAME_KEY = "name";
  static const String COUNTRY_KEY = "country";
  static const String CATEGORY_KEY = "category";
  static const String DESCRIPTION_KEY = "description";
  static const String CURRENCY_KEY = "currency";
  static const String VAT_KEY = "vat";
  static const String APPROVED_BY_KEY = "approved_by";
  static const String AVAILABLE_TO_KEY = "availableTo";
  static const String EXPENSE_TYPE = "expense_type";
}
