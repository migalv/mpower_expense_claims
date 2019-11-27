import 'package:expense_claims_app/models/expense_model.dart';
import 'package:flutter/foundation.dart';

class Template {
  final String id;
  final String name;
  final String approvedBy;
  final String createdBy;
  final String country;
  final String category;
  final String currency;
  final String description;
  final double vat;
  final Map availableTo;
  final String costCentreGroup;
  final ExpenseType expenseType;

  Template({
    @required this.id,
    @required this.name,
    @required this.approvedBy,
    @required this.category,
    @required this.country,
    @required this.createdBy,
    @required this.currency,
    @required this.description,
    @required this.vat,
    @required this.availableTo,
    @required this.costCentreGroup,
    @required this.expenseType,
  });

  Template.fromJson(final Map<String, dynamic> json, {String id})
      : this.id = id,
        this.name = json[NAME_KEY],
        this.country = json[COUNTRY_KEY],
        this.category = json[CATEGORY_KEY],
        this.description = json[DESCRIPTION_KEY],
        this.createdBy = json[CREATED_BY],
        this.currency = json[CURRENCY_KEY],
        this.vat = json[VAT_KEY]?.toDouble() ?? 0.0,
        this.approvedBy = json[APPROVED_BY_KEY],
        this.availableTo = json[AVAILABLE_TO_KEY],
        this.costCentreGroup = json[COST_CENTRE_GROUP_KEY],
        this.expenseType = ExpenseType.values[json[EXPENSE_TYPE]];

  Map<String, dynamic> toJson() => {
        APPROVED_BY_KEY: this.approvedBy,
        AVAILABLE_TO_KEY: this.availableTo,
        CATEGORY_KEY: this.category,
        COUNTRY_KEY: this.country,
        COST_CENTRE_GROUP_KEY: this.costCentreGroup,
        CREATED_BY: this.createdBy,
        CURRENCY_KEY: this.currency,
        DESCRIPTION_KEY: this.description,
        EXPENSE_TYPE: this.expenseType.index,
        NAME_KEY: this.name,
        VAT_KEY: this.vat,
      };

  @override
  bool operator ==(template) => template is Template && template.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return "Expense Template: {\n\t id: $id,\n\t name:$name\n}";
  }

  static const String APPROVED_BY_KEY = "approved_by";
  static const String AVAILABLE_TO_KEY = "availableTo";
  static const String CATEGORY_KEY = "category";
  static const String COST_CENTRE_GROUP_KEY = "cost_centre_group";
  static const String COUNTRY_KEY = "country";
  static const String CREATED_BY = "created_by";
  static const String CURRENCY_KEY = "currency";
  static const String DESCRIPTION_KEY = "description";
  static const String EXPENSE_TYPE = "expense_type";
  static const String NAME_KEY = "name";
  static const String VAT_KEY = "vat";
}
