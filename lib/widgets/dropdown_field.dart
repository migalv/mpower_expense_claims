import 'package:flutter/material.dart';

class DropdownField<T> extends StatefulWidget {
  final List<DropdownMenuItem<T>> items;
  final Function onChanged;
  final T value;
  final IconData icon;

  const DropdownField({
    Key key,
    @required this.items,
    @required this.onChanged,
    @required this.value,
    this.icon,
  }) : super(key: key);
  @override
  _DropdownFieldState createState() => _DropdownFieldState<T>();
}

class _DropdownFieldState<T> extends State<DropdownField> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 16.0, right: 16.0),
      child: DropdownButton<T>(
        value: widget.value,
        items: widget.items,
        onChanged: widget.onChanged,
        isExpanded: false,
        icon: Icon(widget.icon),
      ),
    );
  }
}
