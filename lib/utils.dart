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

  void showSnackbar({
    @required GlobalKey<ScaffoldState> scaffoldKey,
    @required String message,
    SnackBarAction action,
    int duration = 5,
    bool postFrame = true,
    Color color,
  }) {
    if (postFrame)
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showSnackBar(scaffoldKey, message, duration, action,
            backgroundColor: color);
      });
    else
      _showSnackBar(scaffoldKey, message, duration, action,
          backgroundColor: color);
  }

  void _showSnackBar(GlobalKey<ScaffoldState> scaffoldKey, String message,
      int duration, SnackBarAction action,
      {Color backgroundColor}) {
    scaffoldKey.currentState?.showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: backgroundColor,
      duration: Duration(seconds: duration),
      action: action,
    ));
  }
}

final Utils utils = Utils();
