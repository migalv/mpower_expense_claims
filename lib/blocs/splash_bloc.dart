import 'dart:async';

import 'package:expense_claims_app/repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rxdart/rxdart.dart';

class SplashBloc {
  Stream<bool> get isLoggedIn => _isLoggedInController.stream;

  final _isLoggedInController = BehaviorSubject<bool>();

  SplashBloc() {
    print("Splash init");

    _checkIfUserIsLogged();
  }

  void _checkIfUserIsLogged() async {
    FirebaseAuth firebaseAuth = FirebaseAuth.instance;

    FirebaseUser firebaseUser = await firebaseAuth.currentUser();

    if (firebaseUser != null) repository.initUserId(firebaseUser.uid);

    _isLoggedInController.add(firebaseUser != null);
  }

  void dispose() {
    _isLoggedInController.close();
    print("Splash disposed");
  }
}
