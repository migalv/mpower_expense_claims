import 'dart:async';
import 'dart:io';

import 'package:expense_claims_app/models/expense_claim.dart';
import 'package:expense_claims_app/respository.dart';
import 'package:flutter/cupertino.dart';
import 'package:rxdart/rxdart.dart';
import 'package:intl/intl.dart';

class NewExpenseClaimBloc {
  // Streams
  ValueObservable<String> get selectedCountry =>
      _selectedCountryController.stream;
  ValueObservable<String> get selectedCategory =>
      _selectedCategoryController.stream;
  ValueObservable<DateTime> get expenseDate => _expenseDateController.stream;
  ValueObservable<String> get selectedCurrency =>
      _selectedCurrencyController.stream;
  ValueObservable<Map<String, File>> get attachments =>
      _attachmentsController.stream;
  ValueObservable<DateTime> get invoiceDate => _invoiceDateController.stream;
  ValueObservable<String> get selectedApprovedBy =>
      _selectedApprovedByController.stream;

  // Controllers
  final _selectedCountryController = BehaviorSubject<String>();
  final _selectedCategoryController = BehaviorSubject<String>();
  final _selectedCurrencyController = BehaviorSubject<String>();
  final _expenseDateController = BehaviorSubject<DateTime>();
  final _attachmentsController = BehaviorSubject<Map<String, File>>();
  final _invoiceDateController = BehaviorSubject<DateTime>();
  final _selectedApprovedByController = BehaviorSubject<String>();

  Map<String, File> _attachments = Map();

  /// This will determine the type of the form.
  final ExpenseType expenseType;

  // Flags
  bool _multipleAttachments;
  bool get multipleAttachments => _multipleAttachments;

  NewExpenseClaimBloc({@required this.expenseType}) {
    switch (expenseType) {
      case ExpenseType.EXPENSE_CLAIM:
        _attachments[ATTACHMENTS_EXPENSE_CLAIM_NAME] = null;
        _attachmentsController.add(_attachments);
        _multipleAttachments = false;
        break;
      case ExpenseType.INVOICE:
        _attachments[ATTACHMENTS_INVOICE_NAME] = null;
        _attachmentsController.add(_attachments);
        _multipleAttachments = true;
        break;
    }
    selectExpenseDate(DateTime.now());
  }

  // SELECTS
  void selectCountry(String country) => _selectedCountryController.add(country);
  void selectCategory(String category) =>
      _selectedCategoryController.add(category);
  void selectExpenseDate(DateTime expenseDate) =>
      _expenseDateController.add(expenseDate);
  void selectCurrency(String currency) =>
      _selectedCurrencyController.add(currency);
  void selectApprovedBy(String approvedBy) =>
      _selectedApprovedByController.add(approvedBy);
  void selectInvoiceDate(DateTime invoiceDate) =>
      _invoiceDateController.add(invoiceDate);

  // ATTACHMENTS
  void addAttachment(String name, File attachment) {
    if (name != null && _attachments.containsKey(name)) {
      _attachments[name] = attachment;
    } else {
      _attachments.putIfAbsent(
          name ?? DateFormat('h:mm:ss a').format(DateTime.now()),
          () => attachment);
    }
    _attachmentsController.add(_attachments);
  }

  void removeAttachment(String name) {
    if (name == null) return;

    if (name == ATTACHMENTS_EXPENSE_CLAIM_NAME &&
        expenseType == ExpenseType.EXPENSE_CLAIM)
      _attachments[ATTACHMENTS_EXPENSE_CLAIM_NAME] = null;
    else if (name == ATTACHMENTS_INVOICE_NAME &&
        expenseType == ExpenseType.INVOICE)
      _attachments[ATTACHMENTS_INVOICE_NAME] = null;
    else
      _attachments.remove(name);
    _attachmentsController.add(_attachments);
  }

  // UPLOAD DATA
  void uploadNewExpenseClaim(
    String description,
    String stringGross, {
    String stringNet,
  }) {
    if (description == null || stringGross == null) return;
    double gross = double.tryParse(stringGross);
    double net = stringNet != null ? double.tryParse(stringNet) : null;
    ExpenseClaim newExpenseClaim = ExpenseClaim(
      country: selectedCountry.value,
      category: selectedCategory.value,
      expenseDate: expenseDate.value,
      description: description,
      currency: selectedCurrency.value,
      gross: gross,
      net: net,
      approvedBy: selectedApprovedBy.value,
    );

    repository.uploadNewExpenseClaim(newExpenseClaim, _attachments);
  }

  String attachmentsValidator() {
    switch (expenseType) {
      case ExpenseType.EXPENSE_CLAIM:
        if (_attachments[ATTACHMENTS_EXPENSE_CLAIM_NAME] == null)
          return "You need to attach a reciep";
        break;
      case ExpenseType.INVOICE:
        if (_attachments[ATTACHMENTS_INVOICE_NAME] == null)
          return "You need to attach the invoice";
        break;
    }
    return null;
  }

  void dispose() {
    _selectedCountryController.close();
    _selectedCategoryController.close();
    _expenseDateController.close();
    _selectedCurrencyController.close();
    _attachmentsController.close();
    _invoiceDateController.close();
    _selectedApprovedByController.close();
  }
}

enum ExpenseType {
  EXPENSE_CLAIM,
  INVOICE,
}

const String ATTACHMENTS_EXPENSE_CLAIM_NAME = "Reciep";
const String ATTACHMENTS_INVOICE_NAME = "Invoice";
