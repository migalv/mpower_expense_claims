import 'package:expense_claims_app/colors.dart';
import 'package:expense_claims_app/utils.dart';
import 'package:flutter/material.dart';

class CustomFormField extends StatelessWidget {
  final Widget child;
  final FormFieldState state;

  const CustomFormField({Key key, @required this.child, @required this.state})
      : super(key: key);

  @override
  Widget build(BuildContext context) => Column(
        children: <Widget>[
          Container(
            height: 44.0,
            padding: EdgeInsets.symmetric(horizontal: 12.0),
            decoration: BoxDecoration(
              color: formFieldBackgroundColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(4.0),
                topRight: Radius.circular(4.0),
              ),
              border: Border(
                bottom: BorderSide(width: 1.0, color: Colors.white54),
              ),
            ),
            width: double.infinity,
            child: child,
          ),
          utils.buildErrorFormLabel(state, padding: false),
        ],
      );
}
