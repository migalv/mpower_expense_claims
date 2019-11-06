import 'dart:io';

import 'package:expense_claims_app/models/country_model.dart';
import 'package:expense_claims_app/models/expense_claim_model.dart';
import 'package:expense_claims_app/models/expense_model.dart';
import 'package:expense_claims_app/models/expense_template_model.dart';
import 'package:expense_claims_app/models/invoice_model.dart';
import 'package:expense_claims_app/repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:rxdart/rxdart.dart';
import 'package:intl/intl.dart';

class ExpenseFormSectionBloc {
  // Streams
  ValueObservable<Country> get selectedCountry =>
      _selectedCountryController.stream;
  ValueObservable<String> get selectedCategory =>
      _selectedCategoryController.stream;
  ValueObservable<DateTime> get expenseDate => _expenseDateController.stream;
  ValueObservable<String> get selectedCurrency =>
      _selectedCurrencyController.stream;
  ValueObservable<Map<String, File>> get attachments =>
      _attachmentsController.stream;
  ValueObservable<DateTime> get selectedDueDate =>
      _selectedDueDateController.stream;
  ValueObservable<String> get selectedApprover =>
      _selectedApproverController.stream;
  ValueObservable<double> get selectedVat => _selectedVatController.stream;

  // Controllers
  final _selectedCountryController = BehaviorSubject<Country>();
  final _selectedCategoryController = BehaviorSubject<String>();
  final _selectedCurrencyController = BehaviorSubject<String>();
  final _expenseDateController = BehaviorSubject<DateTime>();
  final _attachmentsController = BehaviorSubject<Map<String, File>>();
  final _selectedDueDateController = BehaviorSubject<DateTime>();
  final _selectedApproverController = BehaviorSubject<String>();
  final _selectedVatController = BehaviorSubject<double>();

  Map<String, File> _attachments = Map();

  /// This will determine the type of the form.
  final ExpenseType expenseType;

  final Template template;

  // Flags
  bool _multipleAttachments;
  bool get multipleAttachments => _multipleAttachments;

  ExpenseFormSectionBloc({@required this.expenseType, this.template}) {
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
    if (template != null) _buildFormFromTemplate();
    if (repository?.lastSelectedCountry?.value != null)
      selectCountry(
          repository.getCountryWithId(repository.lastSelectedCountry.value));
    if (repository?.lastSelectedCurrency?.value != null)
      selectCurrency(repository.lastSelectedCurrency.value);
    if (repository?.lastSelectedApprover?.value != null)
      selectApprover(repository.lastSelectedApprover.value);
    selectExpenseDate(DateTime.now());
  }

  // SELECTS
  void selectCountry(Country country) {
    repository.updateLastSelectedCountry(country.id);
    _selectedCountryController.add(country);
  }

  void selectCurrency(String currencyId) {
    repository.updateLastSelectedCurrency(currencyId);
    _selectedCurrencyController.add(currencyId);
  }

  void selectApprover(String approverId) {
    repository.updateLastSelectedApprover(approverId);
    _selectedApproverController.add(approverId);
  }

  void selectCategory(String categoryId) =>
      _selectedCategoryController.add(categoryId);
  void selectExpenseDate(DateTime expenseDate) =>
      _expenseDateController.add(expenseDate);
  void selectDueDate(DateTime dueDate) =>
      _selectedDueDateController.add(dueDate);
  void selectVat(double vat) => _selectedVatController.add(vat);

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
  void uploadNewExpense(String description, String stringGross) {
    if (description == null ||
        stringGross == null ||
        selectedApprover.value == null) return;
    double gross = double.tryParse(stringGross.replaceAll(',', '.'));
    double net;
    double vat = selectedVat.value;
    if (net == null && vat != null) net = gross - (gross * vat) / 100;
    Expense expense;

    if (expenseType == ExpenseType.EXPENSE_CLAIM) {
      expense = ExpenseClaim(
        country: selectedCountry.value.id,
        category: selectedCategory.value,
        date: expenseDate.value,
        description: description,
        currency: selectedCurrency.value,
        gross: gross,
        net: net,
        approvedBy: selectedApprover.value,
        vat: vat,
        createdBy: repository.currentUserId,
        availableTo: [repository.currentUserId],
        approvedByName: repository.approvers.value
            .singleWhere((user) => user.id == selectedApprover.value)
            ?.name,
      );
    } else if (expenseType == ExpenseType.INVOICE) {
      expense = Invoice(
        country: selectedCountry.value.id,
        category: selectedCategory.value,
        date: expenseDate.value,
        dueDate: selectedDueDate.value,
        description: description,
        currency: selectedCurrency.value,
        gross: gross,
        net: net,
        approvedBy: selectedApprover.value,
        vat: vat,
        createdBy: repository.currentUserId,
        availableTo: [repository.currentUserId],
        approvedByName: repository.approvers.value
            .singleWhere((user) => user.id == selectedApprover.value)
            ?.name,
      );
    }

    repository.uploadNewExpense(expense, _attachments);
  }

  // VALIDATORS
  String attachmentsValidator() {
    switch (expenseType) {
      case ExpenseType.EXPENSE_CLAIM:
        if (_attachments[ATTACHMENTS_EXPENSE_CLAIM_NAME] == null)
          return "You need to attach a receipt";
        break;
      case ExpenseType.INVOICE:
        if (_attachments[ATTACHMENTS_INVOICE_NAME] == null)
          return "You need to attach the invoice";
        break;
    }
    return null;
  }

  String categoryValidator(String value) =>
      selectedCategory.value == null ? "Select a category" : null;

  String countryValidator(String value) =>
      selectedCountry.value == null ? "Select a country" : null;

  String dateValidator(ValueObservable dateStream) =>
      dateStream.value == null ? "Select a date" : null;

  String approvedByValidator(String value) =>
      selectedApprover.value == null ? "Select an approver" : null;

  String vatValidator(String value) =>
      selectedVat.value == null ? "Select a VAT" : null;

  String currencyValidator(String value) =>
      selectedCurrency.value == null ? "Select a currency" : null;

  void _buildFormFromTemplate() {
    selectCategory(template.category);
    selectCountry(repository.getCountryWithId(template.country));
    selectVat(template.vat);
    selectCurrency(template.currency);
    selectApprover(template.approvedBy);
  }

  void dispose() {
    _selectedCountryController.close();
    _selectedCategoryController.close();
    _expenseDateController.close();
    _selectedCurrencyController.close();
    _attachmentsController.close();
    _selectedDueDateController.close();
    _selectedApproverController.close();
    _selectedVatController.close();
  }
}

const String ATTACHMENTS_EXPENSE_CLAIM_NAME = "Receipt";
const String ATTACHMENTS_INVOICE_NAME = "Invoice";
