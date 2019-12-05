import 'dart:async';
import 'dart:io';

import 'package:expense_claims_app/models/country_model.dart';
import 'package:expense_claims_app/models/expense_claim_model.dart';
import 'package:expense_claims_app/models/expense_model.dart';
import 'package:expense_claims_app/models/template_model.dart';
import 'package:expense_claims_app/models/invoice_model.dart';
import 'package:expense_claims_app/repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:rxdart/rxdart.dart';
import 'package:intl/intl.dart';

class NewExpenseBloc {
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
  ValueObservable<String> get selectedCostCentre =>
      _selectedCostCentreController.stream;
  Stream<bool> get addAttachmentsButtonVisible =>
      _addAttachmentsButtonVisibleController.stream;

  // Controllers
  final _selectedCountryController = BehaviorSubject<Country>();
  final _selectedCategoryController = BehaviorSubject<String>();
  final _selectedCurrencyController = BehaviorSubject<String>();
  final _expenseDateController = BehaviorSubject<DateTime>();
  final _attachmentsController = BehaviorSubject<Map<String, File>>();
  final _selectedDueDateController = BehaviorSubject<DateTime>();
  final _selectedApproverController = BehaviorSubject<String>();
  final _selectedVatController = BehaviorSubject<double>();
  final _selectedCostCentreController = BehaviorSubject<String>();
  final _addAttachmentsButtonVisibleController = StreamController<bool>();

  // PRIVATE
  List<StreamSubscription> _streamSubscriptions = [];
  Map<String, File> _attachments = Map();

  // PUBLIC
  final ExpenseType expenseType;
  bool editingTemplate = false, editingExpense = false;

  Template _templateToBeEdited;
  Expense _expenseToBeEdited;

  // Text Controllers
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController templateNameController = TextEditingController();
  final grossController =
      MoneyMaskedTextController(decimalSeparator: ',', thousandSeparator: '.');
  final receiptNumberController = TextEditingController();

  NewExpenseBloc(
      {@required this.expenseType,
      Expense expenseToBeEdited,
      Template templateToBeEdited})
      : _expenseToBeEdited = expenseToBeEdited,
        _templateToBeEdited = templateToBeEdited {
    editingTemplate = templateToBeEdited != null;
    editingExpense = expenseToBeEdited != null;

    _initFields();

    _listenToAttachmentChanges();
  }

  void _listenToAttachmentChanges() {
    _streamSubscriptions.add(
      attachments.listen(
        (attachments) {
          if (attachments != null)
            _addAttachmentsButtonVisibleController.add(
                attachments.containsKey('Receipt') &&
                        attachments['Receipt'] != null ||
                    attachments.containsKey('Invoice') &&
                        attachments['Invoice'] != null);
        },
      ),
    );
  }

  // SELECTS
  void selectCountry(Country country) {
    _selectedVatController.add(null);
    repository.updateLastSelectedCountry(country?.id);
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

  void selectCostCentre(String costCenterId) =>
      _selectedCostCentreController.add(costCenterId);
  void selectCategory(String categoryId) =>
      _selectedCategoryController.add(categoryId);
  void selectExpenseDate(DateTime expenseDate) =>
      _expenseDateController.add(expenseDate);
  void selectDueDate(DateTime dueDate) =>
      _selectedDueDateController.add(dueDate);
  void selectVat(double vat) => _selectedVatController.add(vat);

  void _initFields() {
    selectCategory(
        _expenseToBeEdited?.category ?? _templateToBeEdited?.category);

    selectCountry(repository.getCountryWithId(_expenseToBeEdited?.country ??
        _templateToBeEdited?.country ??
        repository.lastSelectedCountry.value));

    selectVat(_expenseToBeEdited?.vat ?? _templateToBeEdited?.vat);

    selectCurrency(_expenseToBeEdited?.currency ??
        _templateToBeEdited?.currency ??
        repository.lastSelectedCurrency.value);

    selectApprover(_expenseToBeEdited?.approvedBy ??
        _templateToBeEdited?.approvedBy ??
        repository.lastSelectedApprover.value);
    selectCostCentre(_expenseToBeEdited?.costCentreGroup ??
        _templateToBeEdited?.costCentreGroup);
    selectDueDate(
        _expenseToBeEdited != null && expenseType == ExpenseType.INVOICE
            ? (_expenseToBeEdited as Invoice).dueDate
            : null);
    selectExpenseDate(_expenseToBeEdited?.date ?? DateTime.now());
    grossController.updateValue(_expenseToBeEdited?.gross ?? 0.0);

    receiptNumberController.text = _expenseToBeEdited?.receiptNumber;
    descriptionController.text =
        _expenseToBeEdited?.description ?? _templateToBeEdited?.description;
    templateNameController.text = _templateToBeEdited?.name;

    _attachments = Map();
    switch (expenseType) {
      case ExpenseType.EXPENSE_CLAIM:
        _attachments[ATTACHMENTS_EXPENSE_CLAIM_NAME] = null;
        _attachmentsController.add(_attachments);
        break;
      case ExpenseType.INVOICE:
        _attachments[ATTACHMENTS_INVOICE_NAME] = null;
        _attachmentsController.add(_attachments);
        break;
    }
  }

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

  void saveEditing() {
    if (editingTemplate) {
      Template newTemplate = Template(
        id: _templateToBeEdited.id,
        createdBy: repository.currentUserId,
        category: _selectedCategoryController.value,
        approvedBy: _selectedApproverController.value,
        availableTo: _templateToBeEdited.availableTo,
        costCentreGroup: _selectedCostCentreController.value,
        country: _selectedCountryController.value.id,
        currency: _selectedCurrencyController.value,
        description: descriptionController.text,
        expenseType: expenseType,
        name: templateNameController.text,
        vat: _selectedVatController.value,
      );
      repository.uploadNewTemplate(newTemplate);
    } else if (editingExpense) uploadExpense();
  }

  // UPLOAD DATA
  void uploadExpense() {
    double gross = grossController.numberValue;
    double net;
    double vat = selectedVat.value;
    if (vat == -1)
      net = gross;
    else
      net = gross - (gross * vat) / 100;
    Expense expense;
    List<Map<String, String>> attachmentsList = List<Map<String, String>>();

    _attachments.forEach((name, file) => attachmentsList.add({"name": name}));

    if (expenseType == ExpenseType.EXPENSE_CLAIM) {
      expense = ExpenseClaim(
        id: _expenseToBeEdited?.id,
        attachments: attachmentsList,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        country: selectedCountry.value.id,
        category: selectedCategory.value,
        date: expenseDate.value,
        description: descriptionController?.text ?? "",
        currency: selectedCurrency.value,
        gross: gross,
        net: net,
        approvedBy: selectedApprover.value,
        vat: vat,
        createdBy: repository.currentUserId,
        costCentreGroup: selectedCostCentre.value,
        availableTo: [repository.currentUserId],
        approvedByName: repository.approvers.value
            .singleWhere((user) => user.id == selectedApprover.value)
            ?.name,
        receiptNumber: receiptNumberController.text != ""
            ? receiptNumberController.text
            : null,
        status: ExpenseStatus(ExpenseStatus.WAITING),
      );
    } else if (expenseType == ExpenseType.INVOICE) {
      expense = Invoice(
        id: _expenseToBeEdited?.id,
        attachments: attachmentsList,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        country: selectedCountry.value.id,
        category: selectedCategory.value,
        date: expenseDate.value,
        dueDate: selectedDueDate.value,
        description: descriptionController?.text ?? "",
        currency: selectedCurrency.value,
        gross: gross,
        net: net,
        approvedBy: selectedApprover.value,
        vat: vat,
        createdBy: repository.currentUserId,
        costCentreGroup: selectedCostCentre.value,
        availableTo: [repository.currentUserId],
        approvedByName: repository.approvers.value
            .singleWhere((user) => user.id == selectedApprover.value)
            ?.name,
        receiptNumber: receiptNumberController.text != ""
            ? receiptNumberController.text
            : null,
        status: ExpenseStatus(ExpenseStatus.WAITING),
      );
    }

    repository.uploadExpense(expense, _attachments);
  }

  void uploadTemplate() {
    Template template;

    template = Template(
      id: repository.generateDocumentId(TEMPLATES_COLLECTION),
      approvedBy: selectedApprover.value,
      availableTo: {
        'uid': [repository.currentUserId]
      },
      createdBy: repository.currentUserId,
      category: selectedCategory.value,
      country: selectedCountry.value.id,
      currency: selectedCurrency.value,
      description: descriptionController?.text ?? "",
      expenseType: expenseType,
      name: templateNameController.text,
      costCentreGroup: selectedCostCentre.value,
      vat: selectedVat.value,
    );

    repository.uploadNewTemplate(template);
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

  String costCentreValidator(String value) =>
      selectedCostCentre.value == null ? "Select an option" : null;

  void dispose() {
    _selectedCountryController.close();
    _selectedCategoryController.close();
    _expenseDateController.close();
    _selectedCurrencyController.close();
    _attachmentsController.close();
    _selectedDueDateController.close();
    _selectedApproverController.close();
    _selectedVatController.close();
    _addAttachmentsButtonVisibleController.close();
    _selectedCostCentreController.close();

    _streamSubscriptions.forEach((s) => s.cancel());
  }
}

const String ATTACHMENTS_EXPENSE_CLAIM_NAME = "Receipt";
const String ATTACHMENTS_INVOICE_NAME = "Invoice";
