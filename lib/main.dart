import 'dart:async';

import 'package:expense_claims_app/bloc_provider.dart';
import 'package:expense_claims_app/blocs/splash_bloc.dart';
import 'package:expense_claims_app/colors.dart';
import 'package:expense_claims_app/pages/splash_page.dart';
import 'package:expense_claims_app/repository.dart';
import 'package:flutter/material.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_crashlytics/flutter_crashlytics.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  bool debugMode = false;
  repository.init();

  Crashlytics.instance.enableInDevMode = true;
  FlutterError.onError = Crashlytics.instance.recordFlutterError;

  FlutterError.onError = (FlutterErrorDetails details) {
    if (debugMode) {
      FlutterError.dumpErrorToConsole(details);
    } else {
      Zone.current.handleUncaughtError(details.exception, details.stack);
    }
  };

  runZoned<Future<Null>>(() async {
    runApp(MyApp(debugMode: debugMode));
  }, onError: (error, stackTrace) async {
    print(error.toString());
    print(stackTrace.toString());

    await FlutterCrashlytics()
        .reportCrash(error, stackTrace, forceCrash: !debugMode);
  });
}

class MyApp extends StatefulWidget {
  final bool debugMode;

  const MyApp({Key key, this.debugMode}) : super(key: key);
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.detached) {
      repository.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.dark.copyWith(
        statusBarBrightness:
            Brightness.dark, // Dark == white status bar -- for IOS.
      ),
    );

    return MaterialApp(
      title: 'Expense Claims App',
      debugShowCheckedModeBanner: widget.debugMode,
      home: BlocProvider<SplashBloc>(
        initBloc: (_, bloc) => bloc ?? SplashBloc(),
        onDispose: (_, bloc) => bloc.dispose(),
        child: SplashPage(),
      ),
      theme: _buildTheme(),
    );
  }
}

ThemeData _buildTheme() {
  final ThemeData base = ThemeData.dark();
  return base.copyWith(
    primaryColor: primaryColor,
    primaryColorLight: primaryLightColor,
    primaryColorDark: primaryDarkColor,
    accentColor: secondaryColor,
    accentIconTheme: base.iconTheme.copyWith(color: Colors.black54),
    colorScheme: base.colorScheme.copyWith(secondary: secondaryColor),
    errorColor: errorColor,
    cursorColor: secondaryColor,
  );
}
