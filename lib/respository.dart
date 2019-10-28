import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_claims_app/blocs/login_bloc.dart';
import 'package:expense_claims_app/models/category_model.dart';
import 'package:expense_claims_app/models/country_model.dart';
import 'package:expense_claims_app/models/currency_model.dart';
import 'package:expense_claims_app/models/user_model.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:rxdart/rxdart.dart';

import 'models/expense_claim_model.dart';

class Repository {
  String _userId;
  String get userId => _userId;

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

  List<StreamSubscription> _streamSubscriptions = [];

  // CONTROLLERS
  final _countriesController = BehaviorSubject<List<Country>>();
  final _currenciesController = BehaviorSubject<List<Currency>>();
  final _categoriesController = BehaviorSubject<List<Category>>();
  final _lastSelectedCountryController = BehaviorSubject<String>();
  final _lastSelectedCurrencyController = BehaviorSubject<String>();
  final _approversController = BehaviorSubject<List<User>>();

  void initUserId(String userId) => _userId = userId;

  void init() {
    _countriesController.add([]);
    _currenciesController.add([]);
    _categoriesController.add([]);
  }

  // UPLOAD
  void uploadNewExpenseClaim(
      ExpenseClaim expenseClaim, Map<String, File> attachments) {
    DocumentReference docRef =
        _firestore.collection(EXPENSE_CLAIMS_KEY).document();

    docRef.setData(expenseClaim.toJson());

    _uploadAttachments(docRef.documentID, attachments);
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
          .collection("$USERS_KEY/$userId/$EDITABLE_INFO_KEY")
          .document(LAST_SELECTED_DOC)
          .setData({
        LAST_SELECTED_COUNTRY: countryId,
      }, merge: true);

  void updateLastSelectedCurrency(String currencyId) => _firestore
          .collection("$USERS_KEY/$userId/$EDITABLE_INFO_KEY")
          .document(LAST_SELECTED_DOC)
          .setData({
        LAST_SELECTED_CURRENCY: currencyId,
      }, merge: true);

  // LOAD
  void loadSettings() {
    _listenToCountriesChanges();
    _listenToCurrenciesChanges();
    _listenToCategoriesChanges();
    _loadLastSelected();
    _listenToApproversChanges();
  }

  void _listenToCountriesChanges() => _streamSubscriptions.add(
          _firestore.collection(COUNTRIES_KEY).snapshots().listen((snapshot) {
        List<Country> countries = snapshot.documents
            .map((doc) => Country.fromJson(doc.data, id: doc.documentID))
            .toList();
        _countriesController.add(countries);
      }));

  void _listenToCurrenciesChanges() => _streamSubscriptions.add(
          _firestore.collection(CURRENCIES_KEY).snapshots().listen((snapshot) {
        List<Currency> currencies = snapshot.documents
            .map((doc) => Currency.fromJson(doc.data, id: doc.documentID))
            .toList();
        _currenciesController.add(currencies);
      }));

  void _listenToCategoriesChanges() => _streamSubscriptions.add(
          _firestore.collection(CATEGORIES_KEY).snapshots().listen((snapshot) {
        List<Category> categories = snapshot.documents
            .map((doc) => Category.fromJson(doc.data, id: doc.documentID))
            .toList();
        _categoriesController.add(categories);
      }));

  void _listenToApproversChanges() => _streamSubscriptions.add(_firestore
          .collection(USERS_KEY)
          .document(userId)
          .snapshots()
          .listen((snapshot) {
        Map approversMapList = snapshot.data[APPROVERS];
        List<User> approvers = [];
        approversMapList.forEach((approverId, map) {
          approvers.add(User.fromJson(map, id: approverId));
        });
        _approversController.add(approvers);
      }));

  void _loadLastSelected() => _streamSubscriptions.add(_firestore
          .collection("$USERS_KEY/$userId/$EDITABLE_INFO_KEY")
          .document(LAST_SELECTED_DOC)
          .snapshots()
          .listen((docSnapshot) {
        _lastSelectedCountryController.add(
            docSnapshot.data.containsKey(LAST_SELECTED_COUNTRY)
                ? docSnapshot.data[LAST_SELECTED_COUNTRY]
                : null);
        _lastSelectedCurrencyController.add(
            docSnapshot.data.containsKey(LAST_SELECTED_CURRENCY)
                ? docSnapshot.data[LAST_SELECTED_CURRENCY]
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
      _userId = authResult.user.uid;
      return AuthState.SUCCESS;
    }
    return AuthState.ERROR;
  }

  Future<String> signIn(
      {@required String email, @required String password}) async {
    AuthResult authResult = await _auth.signInWithEmailAndPassword(
        email: email, password: password);

    if (authResult != null) {
      _userId = authResult.user.uid;
      return AuthState.SUCCESS;
    }
    return AuthState.ERROR;
  }

  Country getCountryWithId(String countryId) => countries?.value
      ?.singleWhere((country) => country?.id ?? "" == countryId);

  Currency getCurrencyWithId(String currencyId) => currencies?.value
      ?.singleWhere((currency) => currency?.id ?? "" == currencyId);

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
    _approversController.close();

    _streamSubscriptions
        .forEach((streamSubscription) => streamSubscription.cancel());
  }
}

//
// SINGLETON
final Repository repository = Repository();

// FIRESTORE COLLECTION KEYS
const String EXPENSE_CLAIMS_KEY = "expense_claims";
const String COUNTRIES_KEY = "countries";
const String CURRENCIES_KEY = "currencies";
const String CATEGORIES_KEY = "categories";
const String USERS_KEY = "users";
const String EDITABLE_INFO_KEY = "editable_info";

// FIRESTORE DOCUMENT KEYS
const String LAST_SELECTED_DOC = "last_selected";

// USER ATRIBUTES
const String APPROVERS = "approvers";

// LAST SELECTED ATRIBUTES
const String LAST_SELECTED_COUNTRY = "country";
const String LAST_SELECTED_CURRENCY = "currency";
