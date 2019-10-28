import 'package:flutter/cupertino.dart';

class Category {
  final String id;
  final String name;
  final bool hidden;
  final String eg;

  Category({
    this.id,
    @required this.name,
    this.hidden = false,
    @required this.eg,
  });

  Category.fromJson(Map<String, dynamic> json, {String id})
      : this.id = id ?? json["id"],
        this.name = json[NAME_KEY],
        this.hidden = json.containsKey(HIDDEN_KEY) ? json[HIDDEN_KEY] : false,
        this.eg = json[EXAMPLE_KEY];

  @override
  String toString() {
    return "Category: {\n\tid: $id,\n\t$NAME_KEY: $name,\n\t$HIDDEN_KEY: $hidden,\n\t$EXAMPLE_KEY: $eg,\n}";
  }

  static const String NAME_KEY = "name";
  static const String ISO_KEY = "iso";
  static const String HIDDEN_KEY = "hidden";
  static const String EXAMPLE_KEY = "eg";
}
