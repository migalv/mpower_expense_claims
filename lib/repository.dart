import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_claims_app/blocs/login_bloc.dart';
import 'package:expense_claims_app/models/category_model.dart';
import 'package:expense_claims_app/models/cost_center_groups_model.dart';
import 'package:expense_claims_app/models/country_model.dart';
import 'package:expense_claims_app/models/currency_model.dart';
import 'package:expense_claims_app/models/expense_model.dart';
import 'package:expense_claims_app/models/template_model.dart';
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
  ValueObservable<List<Template>> get templates => _templatesController.stream;
  ValueObservable<List<CostCentreGroup>> get costCentresGroups =>
      _costCentresGroupsController.stream;
  ValueObservable<int> get lastPageIndex => _lastSelectedListController.stream;

  // CONTROLLERS
  final _countriesController = BehaviorSubject<List<Country>>();
  final _currenciesController = BehaviorSubject<List<Currency>>();
  final _categoriesController = BehaviorSubject<List<Category>>();
  final _lastSelectedCountryController = BehaviorSubject<String>();
  final _lastSelectedCurrencyController = BehaviorSubject<String>();
  final _lastSelectedApproverController = BehaviorSubject<String>();
  final _lastSelectedListController = BehaviorSubject<int>();
  final _expenseClaimsController = BehaviorSubject<List<ExpenseClaim>>();
  final _invoicesController = BehaviorSubject<List<Invoice>>();
  final _approversController = BehaviorSubject<List<User>>();
  final _costCentresGroupsController = BehaviorSubject<List<CostCentreGroup>>();
  final _templatesController = BehaviorSubject<List<Template>>();

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
  Future uploadNewExpense(
      Expense expense, Map<String, File> attachments) async {
    String collection;
    DocumentReference docRef;

    switch (expense.runtimeType) {
      case ExpenseClaim:
        collection = EXPENSE_CLAIMS_COLLECTION;
        break;
      case Invoice:
        collection = INVOICES_COLLECTION;
    }
    // Upload the expense
    docRef = _firestore.collection(collection).document();
    docRef.setData(expense.toJson());

    Map<String, String> downloadUrls =
        await _uploadAttachments(docRef.documentID, attachments, collection);

    expense.attachments.forEach((attachment) {
      String downloadUrl = downloadUrls[attachment["name"]];
      attachment["url"] = downloadUrl;
    });

    // Upload the download urls of the attachments
    docRef.setData(expense.toJson(), merge: true);
  }

  Future uploadNewTemplate(Template template) async {
    if (template.id == null)
      await _firestore
          .collection(TEMPLATES_COLLECTION)
          .document()
          .setData(template.toJson());
    else
      await _firestore
          .collection(TEMPLATES_COLLECTION)
          .document(template.id)
          .setData(template.toJson());
  }

  Future<Map<String, String>> _uploadAttachments(
      String expenseId, Map<String, File> attachments, collection) async {
    if (attachments == null || attachments.isEmpty) return null;

    List keys = attachments.keys.toList();
    List values = attachments.values.toList();
    Map<String, String> downloadUrls = Map();

    for (int i = 0; i < attachments?.length ?? 0; i++)
      downloadUrls[keys[i]] = await _uploadAttachment(
        expenseId,
        keys[i],
        values[i],
        collection,
      );

    return downloadUrls;
  }

  Future<String> _uploadAttachment(String expenseId, String attachmentName,
      File file, String collection) async {
    if (expenseId != null && !expenseId.startsWith('https://')) {
      StorageReference ref = FirebaseStorage.instance
          .ref()
          .child('uploads/$collection/$expenseId')
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

  void updateLastSelectedPageIndex(int pageIndex) => _firestore
          .collection(
              "$USERS_COLLECTION/$currentUserId/$EDITABLE_INFO_COLLECTION")
          .document(LAST_SELECTED_DOC)
          .setData({
        LAST_SELECTED_LIST: pageIndex,
      }, merge: true);

  // LOAD
  void loadSettings() {
    _setUpStream(COUNTRIES_COLLECTION, _countriesController);
    _setUpStream(CURRENCIES_COLLECTION, _currenciesController);
    _setUpStream(CATEGORIES_COLLECTION, _categoriesController);
    _setUpStream(EXPENSE_CLAIMS_COLLECTION, _expenseClaimsController);
    _setUpStream(INVOICES_COLLECTION, _invoicesController);
    _setUpStream(TEMPLATES_COLLECTION, _templatesController);
    _setUpStream(USERS_COLLECTION, _approversController);
    _setUpStream(COST_CENTRES_GROUPS_COLLECTION, _costCentresGroupsController);
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
        list = List<ExpenseClaim>();
        break;
      case INVOICES_COLLECTION:
        queries.add(_firestore
            .collection(collection)
            .where("availableTo", arrayContains: currentUserId));
        list = List<Invoice>();
        break;
      case TEMPLATES_COLLECTION:
        queries.add(_firestore
            .collection(collection)
            .where("availableTo.uid", arrayContains: currentUserId));
        queries.add(_firestore
            .collection(collection)
            .where("availableTo.all", isEqualTo: true));
        list = List<Template>();
        break;
      case USERS_COLLECTION:
        queries.add(_firestore.collection(collection).document(_currentUserId));
        list = List<User>();
        break;
      case COUNTRIES_COLLECTION:
        queries.add(_firestore.collection(collection));
        list = List<Country>();
        break;
      case CURRENCIES_COLLECTION:
        queries.add(_firestore.collection(collection));
        list = List<Currency>();
        break;
      case CATEGORIES_COLLECTION:
        queries.add(_firestore.collection(collection));
        list = List<Category>();
        break;
      case COST_CENTRES_GROUPS_COLLECTION:
        queries.add(_firestore.collection(collection));
        list = List<CostCentreGroup>();
        break;
    }

    queries.forEach(
      (query) => query.snapshots().listen(
        (snapshot) {
          // It's only one document
          if (snapshot is DocumentSnapshot) {
            final onlineElement = _initializeFromJson(collection, snapshot);
            if (collection == USERS_COLLECTION) {
              list.clear();
              list.addAll(onlineElement);
            } else {
              list.removeWhere((ele) => ele.id == onlineElement.id);
              list.add(onlineElement);
            }
            // It's multiple documents
          } else if (snapshot is QuerySnapshot)
            snapshot.documentChanges.forEach((DocumentChange documentChange) {
              final onlineElement =
                  _initializeFromJson(collection, documentChange.document);
              switch (documentChange.type) {
                case DocumentChangeType.added:
                  if (collection == USERS_COLLECTION)
                    list.addAll(onlineElement);
                  else
                    list.add(onlineElement);
                  break;
                case DocumentChangeType.modified:
                  if (collection == USERS_COLLECTION) {
                    list.clear();
                    list.addAll(onlineElement);
                  }
                  list.removeWhere((ele) => ele.id == onlineElement.id);
                  list.add(onlineElement);
                  break;
                case DocumentChangeType.removed:
                  if (collection == USERS_COLLECTION) {
                    list.clear();
                  }
                  list.removeWhere((ele) => ele.id == onlineElement.id);
                  break;
              }
            });
          streamController.add(list);
        },
      ),
    );
  }

  dynamic _initializeFromJson(String collection, DocumentSnapshot docSnapshot) {
    switch (collection) {
      case COUNTRIES_COLLECTION:
        return Country.fromJson(docSnapshot.data, id: docSnapshot.documentID);
      case CURRENCIES_COLLECTION:
        return Currency.fromJson(docSnapshot.data, id: docSnapshot.documentID);
      case CATEGORIES_COLLECTION:
        return Category.fromJson(docSnapshot.data, id: docSnapshot.documentID);
      case EXPENSE_CLAIMS_COLLECTION:
        return ExpenseClaim.fromJson(docSnapshot.data,
            id: docSnapshot.documentID);
      case INVOICES_COLLECTION:
        return Invoice.fromJson(docSnapshot.data, id: docSnapshot.documentID);
      case TEMPLATES_COLLECTION:
        return Template.fromJson(docSnapshot.data, id: docSnapshot.documentID);
      case USERS_COLLECTION:
        Map approversMap = docSnapshot.data[APPROVERS];
        List<User> approvers = <User>[];
        approversMap.forEach((id, map) {
          approvers.add(User.fromJson(map.cast<String, dynamic>(), id: id));
        });
        return approvers;
      case COST_CENTRES_GROUPS_COLLECTION:
        return CostCentreGroup.fromJson(docSnapshot.data,
            id: docSnapshot.documentID);
    }
  }

  void _loadLastSelected() => _firestore
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
        _lastSelectedListController.add(
            (docSnapshot.data?.containsKey(LAST_SELECTED_LIST) ?? false)
                ? docSnapshot.data[LAST_SELECTED_LIST]
                : null);
      });

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
    AuthResult authResult;
    try {
      authResult = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
    } catch (e) {
      print(e.message);
    }

    if (authResult != null) {
      _currentUserId = authResult.user.uid;
      await initUser(_currentUserId);
      if (_currentUser.locked) return AuthState.LOCKED;
      loadSettings();
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

  Future logOut() async {
    _currentUserId = null;
    _currentUser = null;

    await _auth.signOut();
  }

  void deleteTemplates(List<Template> templates) {
    WriteBatch batch = _firestore.batch();
    for (Template template in templates ?? []) {
      batch.delete(_firestore.document('$TEMPLATES_COLLECTION/${template.id}'));
    }
    batch.commit();
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
    _lastSelectedListController.close();
    _costCentresGroupsController.close();
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
const String LAST_SELECTED_LIST = "list_type";

enum authProblems { UserNotFound, PasswordNotValid, NetworkError }
