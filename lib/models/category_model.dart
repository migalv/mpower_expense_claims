import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class Category {
  final String id;
  final String name;
  final bool hidden;
  final String eg;
  final IconData icon;
  final Color color;

  Category({
    this.id,
    @required this.name,
    this.hidden = false,
    this.eg,
    this.icon,
    this.color,
  });

  Category.fromJson(Map<String, dynamic> json, {String id})
      : this.id = id ?? json["id"],
        this.name = json[NAME_KEY],
        this.hidden = json.containsKey(HIDDEN_KEY) ? json[HIDDEN_KEY] : false,
        this.eg = json[EXAMPLE_KEY],
        this.icon = categoryIcons.containsKey(json[NAME_KEY])
            ? categoryIcons[json[NAME_KEY]]
            : null,
        this.color = categoryColors.containsKey(json[NAME_KEY])
            ? categoryColors[json[NAME_KEY]]
            : null;

  @override
  bool operator ==(category) => category is Category && category.id == id;

  @override
  int get hashCode => id.hashCode;

  static const Map<String, IconData> categoryIcons = {
    "Transport": Icons.directions_car,
    "Travel": Icons.card_travel,
    "Food": Icons.fastfood,
    "Marketing": MdiIcons.lightbulb,
    "Other": Icons.attach_money,
  };

  static const Map<String, Color> categoryColors = {
    "Transport": Colors.amber,
    "Travel": Colors.brown,
    "Food": Colors.red,
    "Marketing": Colors.purpleAccent,
    "Other": Colors.black26,
  };

  static const String NAME_KEY = "name";
  static const String ISO_KEY = "iso";
  static const String HIDDEN_KEY = "hidden";
  static const String EXAMPLE_KEY = "eg";
}
