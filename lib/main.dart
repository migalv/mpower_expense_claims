import 'dart:async';

import 'package:expense_claims_app/bloc_provider.dart';
import 'package:expense_claims_app/blocs/splash_bloc.dart';
import 'package:expense_claims_app/colors.dart';
import 'package:expense_claims_app/pages/splash_page.dart';
import 'package:expense_claims_app/respository.dart';
import 'package:flutter/material.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/services.dart';

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

  repository.init();

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
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
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
  final ThemeData base = ThemeData.light();
  return base.copyWith(
      primaryColor: primaryColor,
      primaryColorLight: primaryLightColor,
      primaryColorDark: primaryDarkColor,
      accentColor: secondaryColor,
      colorScheme: base.colorScheme.copyWith(secondary: secondaryColor),
      textTheme: _buildTextTheme(base.textTheme),
      primaryTextTheme: _buildTextTheme(base.primaryTextTheme),
      accentTextTheme: _buildTextTheme(base.accentTextTheme),
      primaryIconTheme: base.iconTheme.copyWith(color: Colors.black54),
      accentIconTheme: base.iconTheme.copyWith(color: Colors.black54),
      textSelectionColor: secondaryColor,
      backgroundColor: secondaryDarkColor,
      chipTheme: _buildChipTheme());
}

ChipThemeData _buildChipTheme() {
  return ChipThemeData(
      backgroundColor: Colors.white,
      disabledColor: Colors.white,
      selectedColor: Colors.white,
      secondarySelectedColor: Colors.white,
      labelPadding: EdgeInsets.all(0.0),
      padding: EdgeInsets.symmetric(vertical: 6.0, horizontal: 12.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      labelStyle: TextStyle(
          fontFamily: 'LibreFranklin',
          fontWeight: FontWeight.w400,
          fontSize: 13.96,
          letterSpacing: 0.25,
          color: Colors.black87),
      secondaryLabelStyle: TextStyle(
          fontFamily: 'LibreFranklin',
          fontWeight: FontWeight.w400,
          fontSize: 13.96,
          letterSpacing: 0.25,
          color: Colors.black87),
      brightness: Brightness.light);
}

TextTheme _buildTextTheme(TextTheme base) {
  return base.copyWith(
    display1: base.display1.copyWith(
      fontFamily: 'GoogleSans',
      fontWeight: FontWeight.w700,
      fontSize: 99.45,
      letterSpacing: -1.5,
    ),
    display2: base.display2.copyWith(
      fontFamily: 'GoogleSans',
      fontWeight: FontWeight.w700,
      fontSize: 62.12,
      letterSpacing: -0.5,
    ),
    display3: base.display3.copyWith(
      fontFamily: 'LibreFranklin',
      fontWeight: FontWeight.w500,
      fontSize: 47.85,
      letterSpacing: 0,
    ),
    display4: base.display4.copyWith(
        fontFamily: 'GoogleSans',
        fontWeight: FontWeight.w700,
        fontSize: 35.22,
        letterSpacing: 0.25,
        color: black60),
    headline: base.headline.copyWith(
      fontFamily: 'LibreFranklin',
      fontWeight: FontWeight.w500,
      fontSize: 23.92,
      letterSpacing: 0,
    ),
    title: base.title.copyWith(
        fontFamily: 'LibreFranklin',
        fontWeight: FontWeight.w500,
        fontSize: 17.94,
        letterSpacing: 0.15,
        color: Colors.black87),
    body1: base.body1.copyWith(
        fontFamily: 'GoogleSans',
        fontWeight: FontWeight.w400,
        fontSize: 15.95,
        letterSpacing: 0.5,
        color: Colors.black87),
    body2: base.body2.copyWith(
        fontFamily: 'LibreFranklin',
        fontWeight: FontWeight.w400,
        fontSize: 13.96,
        letterSpacing: 0.25,
        color: black60),
    button: base.button.copyWith(
        fontFamily: 'LibreFranklin',
        fontWeight: FontWeight.w800,
        fontSize: 13.96,
        letterSpacing: 1.25,
        color: Colors.black87),
    caption: base.caption.copyWith(
        fontFamily: 'GoogleSans',
        fontWeight: FontWeight.w400,
        fontSize: 12.43,
        letterSpacing: 0.4,
        color: black60),
    overline: base.overline.copyWith(
        fontFamily: 'LibreFranklin',
        fontWeight: FontWeight.w700,
        fontSize: 11.96,
        letterSpacing: 2,
        color: black60),
    subhead: base.subhead.copyWith(
        fontFamily: 'LibreFranklin',
        fontWeight: FontWeight.w600,
        fontSize: 15.95,
        letterSpacing: 0.15,
        color: Colors.black87),
    subtitle: base.subtitle.copyWith(
        fontFamily: 'GoogleSans',
        fontWeight: FontWeight.w400,
        fontSize: 14.5,
        letterSpacing: 0.1,
        color: black60),
  );
}
