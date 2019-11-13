import 'package:auto_size_text/auto_size_text.dart';
import 'package:expense_claims_app/colors.dart';
import 'package:expense_claims_app/models/category_model.dart';
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

  Widget buildErrorFormLabel(FormFieldState state, {bool padding = true}) =>
      Padding(
        padding: EdgeInsets.symmetric(horizontal: padding ? 24.0 : 0.0),
        child: state.hasError
            ? Column(
                children: <Widget>[
                  SizedBox(height: 4.0),
                  AutoSizeText(
                    state.errorText,
                    style: TextStyle(color: errorColor, fontSize: 12.0),
                  ),
                ],
              )
            : Container(),
      );

  Widget buildCategoryIcon(Category category) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          width: 48.0,
          height: 48.0,
          decoration: BoxDecoration(
            color: Colors.white30,
            shape: BoxShape.circle,
          ),
          child: Icon(
            category.icon,
            size: 16,
          ),
        ),
      );
}

final Utils utils = Utils();
