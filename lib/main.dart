import 'dart:async';

import 'package:expense_claims_app/bloc_provider.dart';
import 'package:expense_claims_app/blocs/splash_bloc.dart';
import 'package:expense_claims_app/pages/splash_page.dart';
import 'package:flutter/material.dart';

void main() {
  final bool debugMode = false;

  FlutterError.onError = (FlutterErrorDetails details) {
    if (debugMode) {
      FlutterError.dumpErrorToConsole(details);
    } else {
      Zone.current.handleUncaughtError(details.exception, details.stack);
    }
  };

  // await FlutterCrashlytics().initialize();

  runZoned<Future<Null>>(() async {
    runApp(MyApp(debugMode: debugMode));
  }, onError: (error, stackTrace) async {
    print(error.toString());
    print(stackTrace.toString());

    // await FlutterCrashlytics()
    //     .reportCrash(error, stackTrace, forceCrash: !debugMode);
  });
}

class MyApp extends StatelessWidget {
  final bool debugMode;

  const MyApp({Key key, @required this.debugMode}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: BlocProvider<SplashBloc>(
        initBloc: (_, bloc) => bloc ?? SplashBloc(),
        onDispose: (_, bloc) => bloc.dispose(),
        child: SplashPage(),
      ),
    );
  }
}
