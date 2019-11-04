import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_claims_app/blocs/login_bloc.dart';
import 'package:expense_claims_app/models/category_model.dart';
import 'package:expense_claims_app/models/cost_center_groups_model.dart';
import 'package:expense_claims_app/models/country_model.dart';
import 'package:expense_claims_app/models/currency_model.dart';
import 'package:expense_claims_app/models/expense_model.dart';
import 'package:expense_claims_app/models/form_template_model.dart';
import 'package:expense_claims_app/models/invoice_model.dart';
import 'package:expense_claims_app/models/user_model.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:rxdart/rxdart.dart';

import 'models/expense_claim_model.dart';

class Repository {
  String _currentUserId;
  String get currentUserId => _currentUserId;
  User _currentUser;
  User get currentUser => _currentUser;

  //
  // DATA SOURCES
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Firestore _firestore = Firestore.instance;

  // STREAMS
  ValueObservable<List<Country>> get countries => _countriesController.stream;
  ValueObservable<List<Currency>> get currencies =>
      _currenciesController.stream;
  ValueObservable<List<Category>> get categories =>
      _categoriesController.stream;
  ValueObservable<List<User>> get approvers => _approversController.stream;
  ValueObservable<String> get lastSelectedCountry =>
      _lastSelectedCountryController.stream;
  ValueObservable<String> get lastSelectedCurrency =>
      _lastSelectedCurrencyController.stream;
  ValueObservable<String> get lastSelectedApprover =>
      _lastSelectedApproverController.stream;
  ValueObservable<List<ExpenseClaim>> get expenseClaims =>
      _expenseClaimsController.stream;
  ValueObservable<List<Invoice>> get invoices => _invoicesController.stream;
  ValueObservable<List<FormTemplate>> get templates =>
      _templatesController.stream;
  ValueObservable<List<CostCentreGroup>> get costCentresGroups =>
      _costCentresGroupsController.stream;

  List<StreamSubscription> _streamSubscriptions = [];

  // CONTROLLERS
  final _countriesController = BehaviorSubject<List<Country>>();
  final _currenciesController = BehaviorSubject<List<Currency>>();
  final _categoriesController = BehaviorSubject<List<Category>>();
  final _lastSelectedCountryController = BehaviorSubject<String>();
  final _lastSelectedCurrencyController = BehaviorSubject<String>();
  final _lastSelectedApproverController = BehaviorSubject<String>();
  final _expenseClaimsController = BehaviorSubject<List<ExpenseClaim>>();
  final _invoicesController = BehaviorSubject<List<Invoice>>();
  final _approversController = BehaviorSubject<List<User>>();
  final _templatesController = BehaviorSubject<List<FormTemplate>>();
  final _costCentresGroupsController = BehaviorSubject<List<CostCentreGroup>>();

  void init() {
    _countriesController.add([]);
    _currenciesController.add([]);
    _categoriesController.add([]);
  }

  Future initUser(String userId) async {
    _currentUserId = userId;

    DocumentSnapshot documentSnapshot =
        await _firestore.document('$USERS_COLLECTION/$userId').get();
    _currentUser = User.fromJson(documentSnapshot.data, id: userId);
  }

  // UPLOAD
  void uploadNewExpense(Expense expense, Map<String, File> attachments) {
    String collection;
    DocumentReference docRef;

    switch (expense.runtimeType) {
      case ExpenseClaim:
        collection = EXPENSE_CLAIMS_COLLECTION;
        break;
      case Invoice:
        collection = INVOICES_COLLECTION;
    }
    docRef = _firestore.collection(collection).document();
    docRef.setData(expense.toJson());
    _uploadAttachments(docRef.documentID, attachments);
  }

  void uploadNewTemplate(FormTemplate template) {
    _firestore
        .collection(TEMPLATES_COLLECTION)
        .document()
        .setData(template.toJson());
  }

  Future _uploadAttachments(
      String expenseId, Map<String, File> attachments) async {
    if (attachments == null || attachments.isEmpty) return;

    List keys = attachments.keys.toList();
    List values = attachments.values.toList();

    for (int i = 0; i < attachments?.length ?? 0; i++)
      await _uploadAttachment(
        expenseId,
        keys[i],
        values[i],
      );
  }

  Future<String> _uploadAttachment(
      String expenseId, String attachmentName, File file) async {
    if (expenseId != null && !expenseId.startsWith('https://')) {
      StorageReference ref = FirebaseStorage.instance
          .ref()
          .child('uploads/$expenseId')
          .child('$attachmentName.jpg');

      StorageUploadTask storageUploadTask = ref.putFile(file);

      StorageTaskSnapshot taskSnapshot = await storageUploadTask.onComplete;
      String downloadUrl = await taskSnapshot.ref.getDownloadURL();

      return downloadUrl;
    }
    return null;
  }

  void updateLastSelectedCountry(String countryId) => _firestore
          .collection(
              "$USERS_COLLECTION/$currentUserId/$EDITABLE_INFO_COLLECTION")
          .document(LAST_SELECTED_DOC)
          .setData({
        LAST_SELECTED_COUNTRY: countryId,
      }, merge: true);

  void updateLastSelectedCurrency(String currencyId) => _firestore
          .collection(
              "$USERS_COLLECTION/$currentUserId/$EDITABLE_INFO_COLLECTION")
          .document(LAST_SELECTED_DOC)
          .setData({
        LAST_SELECTED_CURRENCY: currencyId,
      }, merge: true);

  void updateLastSelectedApprover(String approverId) => _firestore
          .collection(
              "$USERS_COLLECTION/$currentUserId/$EDITABLE_INFO_COLLECTION")
          .document(LAST_SELECTED_DOC)
          .setData({
        LAST_SELECTED_APPROVER: approverId,
      }, merge: true);

  // LOAD
  void loadSettings() {
    _setUpStream(COUNTRIES_COLLECTION, _countriesController);
    _setUpStream(CURRENCIES_COLLECTION, _currenciesController);
    _setUpStream(CATEGORIES_COLLECTION, _categoriesController);
    _setUpStream(EXPENSE_CLAIMS_COLLECTION, _expenseClaimsController);
    _setUpStream(INVOICES_COLLECTION, _invoicesController);
    _setUpStream(TEMPLATES_COLLECTION, _templatesController);
    _setUpStream(COST_CENTRES_GROUPS_COLLECTION, _costCentresGroupsController);
    _listenToApproversChanges();
    _listenToExpenseClaimsChanges();
    _loadLastSelected();
  }

  void _setUpStream(String collection, StreamController streamController) {
    List list = [];
    List queries = [];

    switch (collection) {
      case EXPENSE_CLAIMS_COLLECTION:
        queries.add(_firestore
            .collection(collection)
            .where("availableTo", arrayContains: currentUserId));
        break;
      case INVOICES_COLLECTION:
        queries.add(_firestore
            .collection(collection)
            .where("availableTo", arrayContains: currentUserId));
        break;
      case TEMPLATES_COLLECTION:
        queries.add(_firestore
            .collection(collection)
            .where("availableTo", arrayContains: currentUserId));
        queries.add(_firestore
            .collection(collection)
            .where("availableTo", isEqualTo: null));
        break;
      default:
        queries.add(_firestore.collection(collection));
    }

    queries.forEach(
      (query) => _streamSubscriptions.add(
        query.snapshots().listen(
          (snapshot) {
            // This list is used to cast the data
            List auxList = [];
            switch (collection) {
              case COUNTRIES_COLLECTION:
                auxList = snapshot.documents
                    .map(
                        (doc) => Country.fromJson(doc.data, id: doc.documentID))
                    .toList()
                    .cast<Country>();
                break;
              case CURRENCIES_COLLECTION:
                auxList = snapshot.documents
                    .map((doc) =>
                        Currency.fromJson(doc.data, id: doc.documentID))
                    .toList()
                    .cast<Currency>();
                break;
              case CATEGORIES_COLLECTION:
                auxList = snapshot.documents
                    .map((doc) =>
                        Category.fromJson(doc.data, id: doc.documentID))
                    .toList()
                    .cast<Category>();
                break;
              case EXPENSE_CLAIMS_COLLECTION:
                auxList = snapshot.documents
                    .map((doc) =>
                        ExpenseClaim.fromJson(doc.data, id: doc.documentID))
                    .toList()
                    .cast<ExpenseClaim>();
                break;
              case INVOICES_COLLECTION:
                auxList = snapshot.documents
                    .map(
                        (doc) => Invoice.fromJson(doc.data, id: doc.documentID))
                    .toList()
                    .cast<Invoice>();
                break;
              case TEMPLATES_COLLECTION:
                auxList = snapshot.documents
                    .map((doc) =>
                        FormTemplate.fromJson(doc.data, id: doc.documentID))
                    .toList()
                    .cast<FormTemplate>();
                break;
              case COST_CENTRES_GROUPS_COLLECTION:
                auxList = snapshot.documents
                    .map((doc) =>
                        CostCentreGroup.fromJson(doc.data, id: doc.documentID))
                    .toList()
                    .cast<CostCentreGroup>();
                break;
            }
            if (list.isEmpty)
              list = auxList;
            else
              list.addAll(auxList);

            streamController.add(list);
          },
        ),
      ),
    );
  }

  void _listenToApproversChanges() => _streamSubscriptions.add(_firestore
          .collection(USERS_COLLECTION)
          .document(currentUserId)
          .snapshots()
          .listen((snapshot) {
        Map approversMap = snapshot.data[APPROVERS];
        List<User> approvers = [];
        approversMap?.forEach((approverId, map) => approvers
            .add(User.fromJson(map.cast<String, String>(), id: approverId)));
        _approversController.add(approvers);
      }));

  void _listenToExpenseClaimsChanges() => _streamSubscriptions.add(_firestore
          .collection(EXPENSE_CLAIMS_COLLECTION)
          .snapshots()
          .listen((snapshot) {
        List<ExpenseClaim> expenseClaims = snapshot.documents
            .map((doc) => ExpenseClaim.fromJson(doc.data, id: doc.documentID))
            .toList();
        _expenseClaimsController.add(expenseClaims);
      }));

  void _loadLastSelected() => _streamSubscriptions.add(_firestore
          .collection(
              "$USERS_COLLECTION/$currentUserId/$EDITABLE_INFO_COLLECTION")
          .document(LAST_SELECTED_DOC)
          .snapshots()
          .listen((docSnapshot) {
        _lastSelectedCountryController.add(
            (docSnapshot.data?.containsKey(LAST_SELECTED_COUNTRY) ?? false)
                ? docSnapshot.data[LAST_SELECTED_COUNTRY]
                : null);
        _lastSelectedCurrencyController.add(
            (docSnapshot.data?.containsKey(LAST_SELECTED_CURRENCY) ?? false)
                ? docSnapshot.data[LAST_SELECTED_CURRENCY]
                : null);
        _lastSelectedApproverController.add(
            (docSnapshot.data?.containsKey(LAST_SELECTED_APPROVER) ?? false)
                ? docSnapshot.data[LAST_SELECTED_APPROVER]
                : null);
      }));

  // AUTH
  Future<String> signUp(
      {@required String email, @required String password}) async {
    AuthResult authResult;
    try {
      authResult = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
    } catch (signUpError) {
      if (signUpError is PlatformException) {
        if (signUpError.code == 'ERROR_EMAIL_ALREADY_IN_USE') {
          return AuthState.EMAIL_EXISTS;
        }
      }
    }

    if (authResult != null) {
      _currentUserId = authResult.user.uid;
      return AuthState.SUCCESS;
    }
    return AuthState.ERROR;
  }

  Future<String> signIn(
      {@required String email, @required String password}) async {
    AuthResult authResult = await _auth.signInWithEmailAndPassword(
        email: email, password: password);

    if (authResult != null) {
      _currentUserId = authResult.user.uid;
      return AuthState.SUCCESS;
    }
    return AuthState.ERROR;
  }

  Country getCountryWithId(String countryId) {
    try {
      return countries?.value?.singleWhere(
          (country) => (country?.id ?? "") == countryId,
          orElse: null);
    } catch (_) {}
    return null;
  }

  Currency getCurrencyWithId(String currencyId) {
    try {
      return currencies?.value?.singleWhere(
          (currency) => (currency?.id ?? "") == currencyId,
          orElse: null);
    } catch (_) {}
    return null;
  }

  Category getCategoryWithId(String categoryId) {
    try {
      return categories?.value?.singleWhere(
          (category) => (category?.id ?? "") == categoryId,
          orElse: null);
    } catch (_) {}
    return null;
  }

  /// Function that recovers the password given an email
  /// If the recovery fails it returns FALSE if not TRUE
  Future<bool> recoverPassword({@required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (resetError) {
      return false;
    }
    return true;
  }

  void dispose() {
    _categoriesController.close();
    _currenciesController.close();
    _countriesController.close();
    _lastSelectedCountryController.close();
    _lastSelectedCurrencyController.close();
    _lastSelectedApproverController.close();
    _expenseClaimsController.close();
    _approversController.close();
    _invoicesController.close();
    _templatesController.close();
    _costCentresGroupsController.close();
    _streamSubscriptions
        .forEach((streamSubscription) => streamSubscription.cancel());
  }
}

//
// SINGLETON
final Repository repository = Repository();

// FIRESTORE COLLECTION KEYS
const String EXPENSE_CLAIMS_COLLECTION = "expense_claims";
const String INVOICES_COLLECTION = "invoices";
const String COUNTRIES_COLLECTION = "countries";
const String CURRENCIES_COLLECTION = "currencies";
const String CATEGORIES_COLLECTION = "categories";
const String USERS_COLLECTION = "users";
const String EDITABLE_INFO_COLLECTION = "editable_info";
const String TEMPLATES_COLLECTION = "templates";
const String COST_CENTRES_GROUPS_COLLECTION = "cost_centres_groups";

// FIRESTORE DOCUMENT KEYS
const String LAST_SELECTED_DOC = "last_selected";

// USER ATRIBUTES
const String APPROVERS = "approvers";

// LAST SELECTED ATRIBUTES
const String LAST_SELECTED_COUNTRY = "country";
const String LAST_SELECTED_CURRENCY = "currency";
const String LAST_SELECTED_APPROVER = "approver";
