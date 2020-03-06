import 'package:expense_claims_app/models/expense_claim_model.dart';
import 'package:expense_claims_app/models/invoice_model.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

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
  List<Map<String, String>> attachments;
  final int createdAt;
  final String receiptNumber;
  final ExpenseStatus status;
  bool edited;
  bool deleted;

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
    this.attachments,
    this.createdAt,
    this.receiptNumber,
    this.status,
    this.edited = false,
    this.deleted = false,
  });

  Expense.fromJson(Map<String, dynamic> json, {String id})
      : this.id = id,
        this.country = json[COUNTRY_KEY],
        this.category = json[CATEGORY_KEY],
        this.date = json.containsKey(DATE_KEY) && json[DATE_KEY] != null
            ? DateTime.fromMillisecondsSinceEpoch(json[DATE_KEY])
            : null,
        this.description = json[DESCRIPTION_KEY],
        this.currency = json[CURRENCY_KEY],
        this.gross = json[GROSS_KEY]?.toDouble() ?? 0.0,
        this.net = json[NET_KEY]?.toDouble() ?? 0.0,
        this.vat = json[VAT_KEY]?.toDouble() ?? 0.0,
        this.approvedBy = json[APPROVED_BY_KEY],
        this.approvedByName = json[APPROVED_BY_NAME_KEY],
        this.createdBy = json[CREATED_BY_KEY],
        this.costCentreGroup = json[COST_CENTRE_GROUP],
        this.availableTo = json[AVAILABLE_TO]?.cast<String>(),
        this.createdAt = json[CREATED_AT_KEY],
        this.receiptNumber = json[RECEIPT_NUM_KEY],
        this.status = ExpenseStatus(json[STATUS_KEY] ?? 0),
        this.edited = json[EDITED_KEY] ?? false,
        this.deleted = json[DELETED_KEY] ?? false {
    attachments = List<Map<String, String>>();
    if (json.containsKey('attachments') &&
        json['attachments'] != null &&
        json['attachments'].isNotEmpty) {
      List attachmentsList = json["attachments"].toList();
      attachmentsList.forEach((attachment) {
        Map<String, String> attachmentMap = Map.from(attachment);
        attachments.add(attachmentMap);
      });
    }
  }

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
        ATTACHMENTS_KEY: attachments,
        CREATED_AT_KEY: this.createdAt,
        RECEIPT_NUM_KEY: this.receiptNumber,
        STATUS_KEY: this.status.value,
        EDITED_KEY: this.edited,
        DELETED_KEY: this.deleted,
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
  static const String ATTACHMENTS_KEY = "attachments";
  static const String CREATED_AT_KEY = "created_at";
  static const String RECEIPT_NUM_KEY = "receipt_num";
  static const String STATUS_KEY = "status";
  static const String EDITED_KEY = "edited";
  static const String DELETED_KEY = "deleted";
}

enum ExpenseType {
  EXPENSE_CLAIM,
  INVOICE,
}

class ExpenseStatus {
  final int value;
  Color _color;
  Color get color => _color;
  IconData _icon;
  IconData get icon => _icon;

  ExpenseStatus(this.value) : assert(0 <= value && value <= 3) {
    switch (value) {
      case WAITING:
        _color = WAITING_COLOR;
        _icon = WAITING_ICON;
        break;
      case APPROVED:
        _color = APPROVED_COLOR;
        _icon = APPROVED_ICON;
        break;
      case PAID:
        _color = PAID_COLOR;
        _icon = PAID_ICON;
        break;
      case DENIED:
        _color = DENIED_COLOR;
        _icon = DENIED_ICON;
        break;
    }
  }

  @override
  String toString() {
    switch (value) {
      case WAITING:
        return "Waiting";
      case APPROVED:
        return "Approved";
      case PAID:
        return "Paid";
      case DENIED:
        return "Denied";
      default:
        return "";
    }
  }

  static const int WAITING = 0;
  static const int APPROVED = 1;
  static const int PAID = 2;
  static const int DENIED = 3;

  static const Color WAITING_COLOR = Colors.orange;
  static const Color APPROVED_COLOR = Colors.blue;
  static const Color PAID_COLOR = Colors.green;
  static const Color DENIED_COLOR = Colors.red;

  static const IconData WAITING_ICON = MdiIcons.history;
  static const IconData APPROVED_ICON = MdiIcons.check;
  static const IconData PAID_ICON = MdiIcons.currencyUsd;
  static const IconData DENIED_ICON = MdiIcons.close;
}
