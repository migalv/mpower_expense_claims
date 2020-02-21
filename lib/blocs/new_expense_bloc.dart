import 'dart:async';
import 'dart:io';

import 'package:expense_claims_app/models/country_model.dart';
import 'package:expense_claims_app/models/expense_claim_model.dart';
import 'package:expense_claims_app/models/expense_model.dart';
import 'package:expense_claims_app/models/template_model.dart';
import 'package:expense_claims_app/models/invoice_model.dart';
import 'package:expense_claims_app/repository.dart';
import 'package:expense_claims_app/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:rxdart/rxdart.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;

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
  ValueObservable<UploadStatus> get uploadStatus =>
      _uploadStatusController.stream;

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
  final _uploadStatusController = BehaviorSubject<UploadStatus>();

  // PRIVATE
  List<StreamSubscription> _streamSubscriptions = [];
  Map<String, File> _attachments = Map();

  // PUBLIC
  final ExpenseType expenseType;
  final bool editingTemplate;
  bool editingExpense = false;

  /// The template that is being used to prefill info
  final Template template;

  /// The template that is being edited
  Template _templateToBeEdited;

  /// The expense that is being edited
  Expense _expenseToBeEdited;

  // Text Controllers
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController templateNameController = TextEditingController();
  final grossController =
      MoneyMaskedTextController(decimalSeparator: ',', thousandSeparator: '.');
  final receiptNumberController = TextEditingController();

  NewExpenseBloc({
    @required this.expenseType,
    Expense expenseToBeEdited,
    this.template,
    this.editingTemplate = false,
  }) : _expenseToBeEdited = expenseToBeEdited {
    editingExpense = expenseToBeEdited != null;

    if (template != null && editingTemplate) _templateToBeEdited = template;

    _initFields();

    _listenToAttachmentChanges();
  }

  void _listenToAttachmentChanges() {
    _streamSubscriptions.add(
      attachments.listen(
        (attachments) {
          if (attachments != null) {
            bool hasAllAttachments = false;

            for (MapEntry entry in attachments.entries) {
              if (expenseType == ExpenseType.EXPENSE_CLAIM) {
                if (entry.key.contains(ATTACHMENTS_EXPENSE_CLAIM_NAME) &&
                    entry.value != null) {
                  hasAllAttachments = true;
                  break;
                }
              }
              if (expenseType == ExpenseType.INVOICE) {
                if (entry.key.contains(ATTACHMENTS_INVOICE_NAME) &&
                    entry.value != null) {
                  hasAllAttachments = true;
                  break;
                }
              }
            }
            _addAttachmentsButtonVisibleController.add(hasAllAttachments);
          }
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
    // If using a template to prefill
    if (template != null && !editingTemplate) {
      templateNameController.text = template.name;
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
    } // If not using a template
    else {
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

      descriptionController.text =
          _expenseToBeEdited?.description ?? _templateToBeEdited?.description;
      templateNameController.text = _templateToBeEdited?.name;
    }

    receiptNumberController.text = _expenseToBeEdited?.receiptNumber;
    selectDueDate(
        _expenseToBeEdited != null && expenseType == ExpenseType.INVOICE
            ? (_expenseToBeEdited as Invoice).dueDate
            : null);
    selectExpenseDate(_expenseToBeEdited?.date);
    grossController.updateValue(_expenseToBeEdited?.gross ?? 0.0);

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
    String extension = p.extension(attachment.path);
    String finalName = '$name$extension';

    if (name != null && _attachments.containsKey(name)) {
      _attachments[finalName] = attachment;
      if (finalName != name) _attachments.remove(name);
    } else
      _attachments.putIfAbsent(
          '${DateFormat('h:mm:ss a').format(DateTime.now())}${p.extension(attachment.path)}',
          () => attachment);

    _attachmentsController.add(_attachments);
  }

  void removeAttachment(String name) {
    if (name == null) return;

    _attachments.remove(name);
    if (name.contains(ATTACHMENTS_EXPENSE_CLAIM_NAME) &&
        expenseType == ExpenseType.EXPENSE_CLAIM) {
      _attachments[ATTACHMENTS_EXPENSE_CLAIM_NAME] = null;
    } else if (name.contains(ATTACHMENTS_INVOICE_NAME) &&
        expenseType == ExpenseType.INVOICE) {
      _attachments[ATTACHMENTS_INVOICE_NAME] = null;
    }

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
  Future<void> uploadExpense() async {
    if (await utils.isConnectedToInternet() == false) {
      _uploadStatusController.add(UploadStatus.CONNECTION_ERROR);
      return;
    }
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

    UploadStatus status = await repository.uploadExpense(expense, _attachments);
    _uploadStatusController.add(status);
  }

  Future<void> uploadTemplate() async {
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
    String returnString;

    switch (expenseType) {
      case ExpenseType.EXPENSE_CLAIM:
        for (var name in _attachments.keys) {
          if (name != null &&
              name.contains(ATTACHMENTS_EXPENSE_CLAIM_NAME) &&
              _attachments[name] == null) {
            returnString = "You need to attach a receipt";
            break;
          }
        }
        break;
      case ExpenseType.INVOICE:
        for (var name in _attachments.keys) {
          if (name != null &&
              name.contains(ATTACHMENTS_INVOICE_NAME) &&
              _attachments[name] == null) {
            returnString = "You need to attach an invoice";
            break;
          }
        }
        break;
    }

    return returnString;
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
    _uploadStatusController.close();

    _streamSubscriptions.forEach((s) => s.cancel());
  }
}

const String ATTACHMENTS_EXPENSE_CLAIM_NAME = "Receipt";
const String ATTACHMENTS_INVOICE_NAME = "Invoice";

enum UploadStatus {
  WAITING,
  SUCCESS,
  CONNECTION_ERROR,
  UNKNOWN_ERROR,
}
