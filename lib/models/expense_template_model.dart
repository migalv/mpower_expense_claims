class ExpenseTemplate {
  final String id;
  final String name;
  final String approvedBy;
  final String country;
  final String category;
  final String currency;
  final String description;
  final double vat;
  final List<String> availableTo;

  ExpenseTemplate({
    this.id,
    this.name,
    this.approvedBy,
    this.country,
    this.category,
    this.currency,
    this.description,
    this.vat,
    this.availableTo,
  });

  ExpenseTemplate.fromJson(final Map<String, dynamic> json, {String id})
      : this.id = id,
        this.name = json[NAME_KEY],
        this.country = json[COUNTRY_KEY],
        this.category = json[CATEGORY_KEY],
        this.description = json[DESCRIPTION_KEY],
        this.currency = json[CURRENCY_KEY],
        this.vat = json[VAT_KEY],
        this.approvedBy = json[APPROVED_BY_KEY],
        this.availableTo = json[AVAILABLE_TO_KEY]?.cast<String>();

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
}
