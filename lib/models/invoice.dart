class Invoice {
  final String id;
  final String country;
  final String category;
  final DateTime date;
  final DateTime dueDate;
  final String description;
  final String currency;
  final double gross;
  final double net;
  final int vat;
  final String approvedBy;

  Invoice({
    this.id,
    this.country,
    this.category,
    this.date,
    this.dueDate,
    this.description,
    this.currency,
    this.gross,
    this.net,
    this.vat,
    this.approvedBy,
  });

  Invoice.fromJson(Map<String, dynamic> json, {String id})
      : this.id = id,
        this.country = json[COUNTRY_KEY],
        this.category = json[CATEGORY_KEY],
        this.date = DateTime.fromMillisecondsSinceEpoch(json[DATE_KEY]),
        this.dueDate = DateTime.fromMillisecondsSinceEpoch(json[DUE_DATE_KEY]),
        this.description = json[DESCRIPTION_KEY],
        this.currency = json[CURRENCY_KEY],
        this.gross = json[GROSS_KEY],
        this.net = json[NET_KEY],
        this.vat = json[VAT_KEY],
        this.approvedBy = json[APPROVED_BY_KEY];

  Map<String, dynamic> toJson() => {
        'id': this.id,
        COUNTRY_KEY: this.country,
        CATEGORY_KEY: this.category,
        DATE_KEY: this.date.millisecondsSinceEpoch,
        DUE_DATE_KEY: this.dueDate.millisecondsSinceEpoch,
        DESCRIPTION_KEY: this.description,
        CURRENCY_KEY: this.currency,
        GROSS_KEY: this.gross,
        NET_KEY: this.net,
        VAT_KEY: this.vat,
        APPROVED_BY_KEY: this.approvedBy,
      };

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
