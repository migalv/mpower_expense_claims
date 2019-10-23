import 'dart:async';

import 'package:expense_claims_app/pages/login_page.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';

void main() {
  final bool debugMode = false;

  FlutterError.onError = (FlutterErrorDetails details) {
    if (debugMode) {
      FlutterError.dumpErrorToConsole(details);
    } else {
      Zone.current.handleUncaughtError(details.exception, details.stack);
      Crashlytics.instance.recordFlutterError(details);
    }
  };

  runZoned<Future<Null>>(() async {
    runApp(MyApp(debugMode: debugMode));
  }, onError: (error, stackTrace) async {
    print(error.toString());
    print(stackTrace.toString());
  });
}

class MyApp extends StatelessWidget {
  final bool debugMode;

  const MyApp({Key key, @required this.debugMode}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'Flutter Demo', home: LoginPage());
  }
}
