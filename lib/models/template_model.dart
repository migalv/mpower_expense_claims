import 'package:expense_claims_app/models/expense_model.dart';

class Template {
  final String id;
  final String name;
  final String approvedBy;
  final String country;
  final String category;
  final String currency;
  final String description;
  final double vat;
  final List<String> availableTo;
  final String costCentreGroup;
  final ExpenseType expenseType;

  Template({
    this.id,
    this.name,
    this.approvedBy,
    this.country,
    this.category,
    this.currency,
    this.description,
    this.vat,
    this.availableTo,
    this.costCentreGroup,
    this.expenseType,
  });

  Template.fromJson(final Map<String, dynamic> json, {String id})
      : this.id = id,
        this.name = json[NAME_KEY],
        this.country = json[COUNTRY_KEY],
        this.category = json[CATEGORY_KEY],
        this.description = json[DESCRIPTION_KEY],
        this.currency = json[CURRENCY_KEY],
        this.vat = json[VAT_KEY]?.toDouble() ?? 0.0,
        this.approvedBy = json[APPROVED_BY_KEY],
        this.availableTo = json[AVAILABLE_TO_KEY]?.cast<String>(),
        this.costCentreGroup = json[COST_CENTRE_GROUP_KEY],
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
        COST_CENTRE_GROUP_KEY: this.costCentreGroup,
        EXPENSE_TYPE: this.expenseType.index,
      };

  @override
  bool operator ==(template) => template is Template && template.id == id;

  @override
  int get hashCode => id.hashCode;

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
  static const String COST_CENTRE_GROUP_KEY = "cost_centre_group";
}
