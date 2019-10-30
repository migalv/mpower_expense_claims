import 'dart:async';

import 'package:expense_claims_app/repository.dart';
import 'package:flutter/cupertino.dart';

class LoginBloc {
  // Streams
  Stream<String> get authState => _authStateController.stream;

  // Controllers
  final _authStateController = StreamController<String>();

  void dispose() {
    _authStateController.close();
  }

  Future<String> signIn(
      {@required String email, @required String password}) async {
    _authStateController.add(AuthState.LOADING);
    String result = await repository.signIn(email: email, password: password);
    _authStateController.add(result);
    return result;
  }
}

class AuthState {
  static const String IDLE = "IDLE";
  static const String LOADING = "LOADING";
  static const String SUCCESS = "SUCCESS";
  static const String ERROR = "ERROR";
  static const String EMAIL_EXISTS = "EMAIL_EXISTS";
}
