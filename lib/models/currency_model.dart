import 'package:flutter/cupertino.dart';

class Currency {
  final String id;
  final String name;
  final String iso;
  final bool hidden;
  final String symbol;

  Currency({
    this.id,
    @required this.name,
    @required this.iso,
    this.hidden = false,
    @required this.symbol,
  });

  Currency.fromJson(Map<String, dynamic> json, {String id})
      : this.id = id ?? json["id"],
        this.name = json[NAME_KEY],
        this.iso = json[ISO_KEY],
        this.hidden = json.containsKey(HIDDEN_KEY) ? json[HIDDEN_KEY] : false,
        this.symbol = json[SYMBOL_KEY];

  @override
  String toString() {
    return "Currency {\n\tid: $id,\n\t$NAME_KEY: $name,\n\t$ISO_KEY: $iso,\n\t$HIDDEN_KEY: $hidden,\n\t$SYMBOL_KEY: $symbol,\n}";
  }

  @override
  bool operator ==(currency) => currency is Currency && currency.id == id;

  @override
  int get hashCode => id.hashCode;

  static const String NAME_KEY = "name";
  static const String ISO_KEY = "iso";
  static const String HIDDEN_KEY = "hidden";
  static const String SYMBOL_KEY = "symbol";
}
