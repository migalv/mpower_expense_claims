import 'dart:io';

import 'package:expense_claims_app/bloc_provider.dart';
import 'package:expense_claims_app/blocs/login_bloc.dart';
import 'package:expense_claims_app/pages/login_page.dart';
import 'package:expense_claims_app/repository.dart';
import 'package:flutter/material.dart';

class Utils {
  void pushReplacement(BuildContext context, Widget to, {int delay = 0}) async {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        Future.delayed(Duration(seconds: delay)).then((_) =>
            Navigator.of(context)
                .pushReplacement(MaterialPageRoute(builder: (_) => to)));
      },
    );
  }

  void push(BuildContext context, Widget to, {int delay = 0}) async {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        Future.delayed(Duration(seconds: delay)).then((_) =>
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => to)));
      },
    );
  }

  Future<bool> isConnectedToInternet() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      }
    } on SocketException catch (_) {
      return false;
    }
    return false;
  }

  void showSnackbar({
    @required GlobalKey<ScaffoldState> scaffoldKey,
    @required String message,
    SnackBarAction action,
    int duration = 2,
    bool postFrame = true,
    Color backgroundColor,
    Color textColor,
  }) {
    if (postFrame)
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showSnackBar(scaffoldKey, message, duration, action,
            backgroundColor: backgroundColor, textColor: textColor);
      });
    else
      _showSnackBar(scaffoldKey, message, duration, action,
          backgroundColor: backgroundColor, textColor: textColor);
  }

  void _showSnackBar(GlobalKey<ScaffoldState> scaffoldKey, String message,
      int duration, SnackBarAction action,
      {Color backgroundColor, Color textColor}) {
    scaffoldKey.currentState?.showSnackBar(SnackBar(
      content: Text(
        message,
        style: TextStyle(color: textColor),
      ),
      backgroundColor: backgroundColor,
      duration: Duration(seconds: duration),
      action: action,
    ));
  }

  void logOut(BuildContext context) {
    repository.logOut();
    utils.pushReplacement(
      context,
      BlocProvider<LoginBloc>(
        initBloc: (_, bloc) => bloc ?? LoginBloc(),
        onDispose: (_, bloc) => bloc.dispose(),
        child: LoginPage(),
      ),
    );
  }
}

final Utils utils = Utils();
