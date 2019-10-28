import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Category {
  final String id;
  final String name;
  final bool hidden;
  final String eg;
  final IconData icon;

  Category({
    this.id,
    @required this.name,
    this.hidden = false,
    @required this.eg,
    this.icon,
  });

  Category.fromJson(Map<String, dynamic> json, {String id})
      : this.id = id ?? json["id"],
        this.name = json[NAME_KEY],
        this.hidden = json.containsKey(HIDDEN_KEY) ? json[HIDDEN_KEY] : false,
        this.eg = json[EXAMPLE_KEY],
        this.icon = categoryIcons.containsKey(json[NAME_KEY])
            ? categoryIcons[json[NAME_KEY]]
            : null;

  @override
  String toString() {
    return "Category: {\n\tid: $id,\n\t$NAME_KEY: $name,\n\t$HIDDEN_KEY: $hidden,\n\t$EXAMPLE_KEY: $eg,\n}";
  }

  static const Map<String, IconData> categoryIcons = {
    "Transport": Icons.directions_car,
    "Travel": Icons.card_travel,
    "Food": Icons.fastfood,
    "Other": Icons.attach_money,
  };

  static const String NAME_KEY = "name";
  static const String ISO_KEY = "iso";
  static const String HIDDEN_KEY = "hidden";
  static const String EXAMPLE_KEY = "eg";
}
