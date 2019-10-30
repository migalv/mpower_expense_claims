import 'dart:async';

import 'package:expense_claims_app/blocs/login_bloc.dart';
import 'package:expense_claims_app/repository.dart';
import 'package:flutter/cupertino.dart';

class SignUpBloc {
  // Streams
  Stream<String> get authState => _authStateController.stream;

  // Controllers
  final _authStateController = StreamController<String>();

  Function _showDialog;
  void setShowDialogFunc(Function func) => _showDialog = func;

  String nameValidator(String value) {
    if (value == null) return null;
    if (value.isEmpty) return "Please enter a name";
    if (value.length < 3)
      return "The name should be at least 3 characters long";
    return null;
  }

  String emailValidator(String value) {
    if (value == null) return null;
    if (!value.contains("@") || !value.contains(".") && !value.contains(" ")) {
      return 'Please enter a valid email';
    } else if (value.isEmpty) {
      return 'Please enter an email';
    }
    return null;
  }

  String passwordValidator(String value) {
    if (value == null) return null;
    if (value.isEmpty) {
      return 'Please enter a password';
    }
    if (value.length < 6) {
      return 'Password should be at least 6 characters long';
    }
    return null;
  }

  Future signUp({@required String email, @required password}) async {
    _showDialog();
    _authStateController.add(AuthState.LOADING);
    String result = await repository.signUp(email: email, password: password);
    _authStateController.add(result);
  }

  void dispose() {
    _authStateController.close();
  }
}
