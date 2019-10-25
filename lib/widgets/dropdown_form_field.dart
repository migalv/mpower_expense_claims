import 'package:expense_claims_app/colors.dart';
import 'package:flutter/material.dart';

class DropdownFormField extends StatelessWidget {
  final String Function(String) validator;
  final Function(String) onChanged;
  final String hint;
  final dynamic value;
  final List<DropdownMenuItem<String>> items;

  const DropdownFormField(
      {Key key,
      @required this.validator,
      @required this.onChanged,
      @required this.value,
      this.hint,
      @required this.items})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FormField<String>(
      validator: validator,
      builder: (FormFieldState<String> state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            DropdownButtonHideUnderline(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15.0),
                  border: Border.all(
                      // TODO: CHANGE COLOR
                      color: Colors.red,
                      style: BorderStyle.solid,
                      width: 0.80),
                ),
                child: DropdownButton<String>(
                  hint: hint != null ? Text(hint) : null,
                  value: value,
                  onChanged: (String newValue) {
                    state.didChange(newValue);
                    onChanged(newValue);
                  },
                  items: items,
                ),
              ),
            ),
            SizedBox(height: 5.0),
            Text(
              state.hasError ? state.errorText : '',
              style: TextStyle(color: primaryErrorColor, fontSize: 12.0),
            ),
          ],
        );
      },
    );
  }
}
