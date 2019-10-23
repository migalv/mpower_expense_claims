import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_claims_app/blocs/login_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

class Repository {
  String _userId;
  String get userId => _userId;

  //
  // DATA SOURCES
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Firestore _firestore = Firestore.instance;

  void initUserId(String userId) => _userId;

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
}

//
// SINGLETON
final Repository repository = Repository();
