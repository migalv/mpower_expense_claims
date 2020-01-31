import 'package:auto_size_text/auto_size_text.dart';
import 'package:expense_claims_app/colors.dart';
import 'package:flutter/material.dart';

class ErrorFormLabel extends StatelessWidget {
  final bool padding;
  final FormFieldState state;

  const ErrorFormLabel(this.state, {Key key, this.padding = true})
      : super(key: key);
  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.symmetric(horizontal: padding ? 24.0 : 0.0),
        child: state.hasError
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      SizedBox(height: 4.0),
                      AutoSizeText(
                        state.errorText,
                        style: TextStyle(color: errorColor, fontSize: 12.0),
                      ),
                    ],
                  )
                ],
              )
            : Container(),
      );
}
