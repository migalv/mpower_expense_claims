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
  ValueObservable<String> get selectedCostCentre =>
      _selectedCostCentreController.stream;

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

  // PRIVATE
  List<StreamSubscription> _streamSubscriptions = [];
  Map<String, File> _attachments = Map();
  ExpenseType _expenseType;

  // PUBLIC
  final Stream<int> expenseTypeStream;
  bool editingTemplate = false;
  Template _template;

  // Text Controllers
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController templateNameController = TextEditingController();
  final grossController =
      MoneyMaskedTextController(decimalSeparator: ',', thousandSeparator: '.');
  final receiptNumberController = TextEditingController();

  // Flags
  bool _multipleAttachments;
  bool get multipleAttachments => _multipleAttachments;

  ExpenseFormSectionBloc({@required Stream<int> expenseTypeStream})
      : this.expenseTypeStream = expenseTypeStream {
    _listenToExpenseTypeChanges();
  }

  void _listenToExpenseTypeChanges() {
    _streamSubscriptions.add(expenseTypeStream.listen(
      (expenseType) {
        _expenseType = ExpenseType.values[expenseType ?? 0];
        _initFields();
      },
    ));
  }

  // SELECTS
  void selectCountry(Country country) {
    _selectedVatController.add(null);
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

  void selectCostCentre(String costCenterId) =>
      _selectedCostCentreController.add(costCenterId);
  void selectCategory(String categoryId) =>
      _selectedCategoryController.add(categoryId);
  void selectExpenseDate(DateTime expenseDate) =>
      _expenseDateController.add(expenseDate);
  void selectDueDate(DateTime dueDate) =>
      _selectedDueDateController.add(dueDate);
  void selectVat(double vat) => _selectedVatController.add(vat);

  void setTemplate(Template template, {bool edit = false}) {
    this.editingTemplate = edit;
    _template = template;

    if (template != null) {
      templateNameController.text = _template.name;
      selectCategory(template.category);
      // Country
      if (template.country != null)
        selectCountry(repository.getCountryWithId(template.country));
      else if (repository?.lastSelectedCountry?.value != null)
        selectCountry(
            repository.getCountryWithId(repository.lastSelectedCountry.value));

      // Currency
      if (template.currency != null)
        selectCurrency(template.currency);
      else if (repository?.lastSelectedCurrency?.value != null)
        selectCurrency(repository.lastSelectedCurrency.value);

      // Approver
      if (template.approvedBy != null)
        selectApprover(template.approvedBy);
      else if (repository?.lastSelectedApprover?.value != null)
        selectApprover(repository.lastSelectedApprover.value);

      selectCostCentre(template.costCentreGroup);
      selectVat(template.vat);
      descriptionController.text = template.description;
    } else
      _initFields();
  }

  void editTemplate() {
    Template newTemplate = Template(
      id: _template.id,
      category: _selectedCategoryController.value,
      approvedBy: _selectedApproverController.value,
      availableTo: _template.availableTo,
      costCentreGroup: _selectedCostCentreController.value,
      country: _selectedCountryController.value.id,
      currency: _selectedCurrencyController.value,
      description: descriptionController.text,
      expenseType: _expenseType,
      name: templateNameController.text,
      vat: _selectedVatController.value,
    );
    repository.uploadNewTemplate(newTemplate);
  }

  void _initFields() {
    selectCategory(null);
    selectCountry(
        repository.getCountryWithId(repository.lastSelectedCountry.value));
    selectVat(null);
    selectCurrency(repository.lastSelectedCurrency.value);
    selectApprover(repository.lastSelectedApprover.value);
    selectCostCentre(null);
    selectDueDate(null);
    selectExpenseDate(DateTime.now());
    receiptNumberController.text = "";
    grossController.updateValue(0.0);
    descriptionController.text = "";

    _attachments = Map();
    switch (_expenseType) {
      case ExpenseType.EXPENSE_CLAIM:
        _attachments[ATTACHMENTS_EXPENSE_CLAIM_NAME] = null;
        _attachmentsController.add(_attachments);
        _multipleAttachments = true;
        break;
      case ExpenseType.INVOICE:
        _attachments[ATTACHMENTS_INVOICE_NAME] = null;
        _attachmentsController.add(_attachments);
        _multipleAttachments = true;
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
        _expenseType == ExpenseType.EXPENSE_CLAIM)
      _attachments[ATTACHMENTS_EXPENSE_CLAIM_NAME] = null;
    else if (name == ATTACHMENTS_INVOICE_NAME &&
        _expenseType == ExpenseType.INVOICE)
      _attachments[ATTACHMENTS_INVOICE_NAME] = null;
    else
      _attachments.remove(name);
    _attachmentsController.add(_attachments);
  }

  // UPLOAD DATA
  void uploadNewExpense() {
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

    if (_expenseType == ExpenseType.EXPENSE_CLAIM) {
      expense = ExpenseClaim(
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
    } else if (_expenseType == ExpenseType.INVOICE) {
      expense = Invoice(
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

    repository.uploadNewExpense(expense, _attachments);
    _initFields();
  }

  void uploadTemplate() {
    Template template;

    template = Template(
      approvedBy: selectedApprover.value,
      availableTo: {
        'uid': [repository.currentUserId]
      },
      category: selectedCategory.value,
      country: selectedCountry.value.id,
      currency: selectedCurrency.value,
      description: descriptionController?.text ?? "",
      expenseType: _expenseType,
      name: templateNameController.text,
      costCentreGroup: selectedCostCentre.value,
      vat: selectedVat.value,
    );

    repository.uploadNewTemplate(template);
  }

  // VALIDATORS
  String attachmentsValidator() {
    switch (_expenseType) {
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
    _selectedCostCentreController.close();
  }
}

const String ATTACHMENTS_EXPENSE_CLAIM_NAME = "Receipt";
const String ATTACHMENTS_INVOICE_NAME = "Invoice";
