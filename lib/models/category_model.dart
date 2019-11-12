import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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
    this.eg,
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
  bool operator ==(category) => category is Category && category.id == id;

  @override
  int get hashCode => id.hashCode;

  static const Map<String, IconData> categoryIcons = {
    "Transport": FontAwesomeIcons.car,
    "Travel": FontAwesomeIcons.suitcase,
    "Communication": FontAwesomeIcons.satelliteDish,
    "Import": FontAwesomeIcons.ship,
    "Food": FontAwesomeIcons.utensils,
    "Marketing": FontAwesomeIcons.bullhorn,
    "Office supplies": FontAwesomeIcons.pencilRuler,
    "Entertainment": FontAwesomeIcons.theaterMasks,
    "Other": FontAwesomeIcons.moneyBillWave,
  };

  static const String NAME_KEY = "name";
  static const String ISO_KEY = "iso";
  static const String HIDDEN_KEY = "hidden";
  static const String EXAMPLE_KEY = "eg";
}
