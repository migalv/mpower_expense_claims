import 'package:expense_claims_app/bloc_provider.dart';
import 'package:expense_claims_app/blocs/splash_bloc.dart';
import 'package:expense_claims_app/colors.dart';
import 'package:expense_claims_app/pages/splash_page.dart';
import 'package:expense_claims_app/repository.dart';
import 'package:flutter/material.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/services.dart';

void main() {
  repository.init();

  Crashlytics.instance.enableInDevMode = true;
  FlutterError.onError = Crashlytics.instance.recordFlutterError;

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
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
    if (state == AppLifecycleState.inactive) {
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
