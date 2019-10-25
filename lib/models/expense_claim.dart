class ExpenseClaim {
  final String id;
  final String country;
  final String category;
  final DateTime expenseDate;
  final String description;
  final String currency;
  final double gross;
  final double net;
  final int vat;
  final String approvedBy;

  ExpenseClaim({
    this.id,
    this.country,
    this.category,
    this.expenseDate,
    this.description,
    this.currency,
    this.gross,
    this.net,
    this.vat,
    this.approvedBy,
  });

  ExpenseClaim.fromJson(Map<String, dynamic> json, {String id})
      : this.id = id,
        this.country = json[COUNTRY_KEY],
        this.category = json[COUNTRY_KEY],
        this.expenseDate =
            DateTime.fromMillisecondsSinceEpoch(json[COUNTRY_KEY]),
        this.description = json[COUNTRY_KEY],
        this.currency = json[COUNTRY_KEY],
        this.gross = json[COUNTRY_KEY],
        this.net = json[COUNTRY_KEY],
        this.vat = json[COUNTRY_KEY],
        this.approvedBy = json[COUNTRY_KEY];

  Map<String, dynamic> toJson() => {
        COUNTRY_KEY: this.country,
        CATEGORY_KEY: this.category,
        EXPENSE_DATE_KEY: this.expenseDate.millisecondsSinceEpoch,
        DESCRIPTION_KEY: this.description,
        CURRENCY_KEY: this.currency,
        GROSS_KEY: this.gross,
        NET_KEY: this.net,
        VAT_KEY: this.vat,
        APPROVED_BY_KEY: this.approvedBy,
      };

  static const String COUNTRY_KEY = "country";
  static const String CATEGORY_KEY = "category";
  static const String EXPENSE_DATE_KEY = "expense_date";
  static const String DESCRIPTION_KEY = "description";
  static const String CURRENCY_KEY = "currency";
  static const String GROSS_KEY = "gross";
  static const String NET_KEY = "net";
  static const String VAT_KEY = "vat";
  static const String APPROVED_BY_KEY = "approved_by";
}
