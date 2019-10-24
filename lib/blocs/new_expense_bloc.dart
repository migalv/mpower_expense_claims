import 'dart:async';
import 'dart:io';

import 'package:expense_claims_app/models/expense_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:rxdart/rxdart.dart';

class NewExpenseBloc {
  // Streams
  ValueObservable<String> get selectedCountry =>
      _selectedCountryController.stream;
  ValueObservable<String> get selectedCategory =>
      _selectedCategoryController.stream;
  ValueObservable<int> get expenseDate => _expenseDateController.stream;
  ValueObservable<String> get selectedCurrency =>
      _selectedCurrencyController.stream;
  Stream<Map<String, File>> get attachments => _attachmentsController.stream;
  ValueObservable<int> get invoiceDate => _invoiceDateController.stream;

  // Controllers
  final _selectedCountryController = BehaviorSubject<String>();
  final _selectedCategoryController = BehaviorSubject<String>();
  final _selectedCurrencyController = BehaviorSubject<String>();
  final _expenseDateController = BehaviorSubject<int>();
  final _attachmentsController = BehaviorSubject<Map<String, File>>();
  final _invoiceDateController = BehaviorSubject<int>();

  Map<String, File> _attachments = Map();

  /// This will determine the type of the form.
  final ExpenseType expenseType;

  // Flags
  bool _multipleAttachments;
  bool get multipleAttachments => _multipleAttachments;

  NewExpenseBloc({@required this.expenseType}) {
    switch (expenseType) {
      case ExpenseType.EXPENSE_CLAIM:
        _attachments["Expense Claim"] = null;
        _attachmentsController.add(_attachments);
        _multipleAttachments = false;
        break;
      case ExpenseType.INVOICE:
        _attachments["Invoice"] = null;
        _attachmentsController.add(_attachments);
        _multipleAttachments = true;
        break;
    }
  }

  void selectCountry(String country) => _selectedCountryController.add(country);
  void selectCategory(String category) =>
      _selectedCategoryController.add(category);
  void selectExpenseDate(DateTime expenseDate) =>
      _expenseDateController.add(expenseDate.millisecondsSinceEpoch);
  void selectCurrency(String currency) =>
      _selectedCurrencyController.add(currency);
  void selectInvoiceDate(DateTime invoiceDate) =>
      _invoiceDateController.add(invoiceDate.millisecondsSinceEpoch);

  void addAttachment(String name, File attachment) {
    if (name != null && _attachments.containsKey(name)) {
      _attachments[name] = attachment;
    } else {
      _attachments.putIfAbsent(
          name ?? "",
          // DateFormat('h:mm:ss a').format(DateTime.now()),
          () => attachment);
    }
    _attachmentsController.add(_attachments);
  }

  void removeAttachment(String name) {
    if (name == null) return;

    _attachments.remove(name);
    _attachmentsController.add(_attachments);
  }

  void dispose() {
    _selectedCountryController.close();
    _selectedCategoryController.close();
    _expenseDateController.close();
    _selectedCurrencyController.close();
    _attachmentsController.close();
    _invoiceDateController.close();
  }
}
