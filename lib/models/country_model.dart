import 'package:flutter/cupertino.dart';

class Country {
  final String id;
  final String name;
  final String iso;
  final bool hidden;
  final List<String> currencies;
  final List<double> vatOptions;

  Country({
    this.id,
    @required this.name,
    @required this.iso,
    this.hidden = false,
    this.currencies,
    this.vatOptions,
  });

  Country.fromJson(Map<String, dynamic> json, {String id})
      : this.id = id ?? json["id"],
        this.name = json[NAME_KEY],
        this.iso = json[ISO_KEY],
        this.hidden = json.containsKey(HIDDEN_KEY) ? json[HIDDEN_KEY] : false,
        this.currencies = json[CURRENCIES_KEY],
        this.vatOptions = json[VAT_OPTIONS_KEY]
                ?.map((vat) => vat.toDouble())
                ?.toList()
                ?.cast<double>() ??
            [];
  @override
  String toString() {
    return "Country {\n\tid: $id,\n\t$NAME_KEY: $name,\n\t$ISO_KEY: $iso,\n\t$HIDDEN_KEY: $hidden,\n\t$CURRENCIES_KEY: $currencies,\n\t$VAT_OPTIONS_KEY: $vatOptions,\n}";
  }

  @override
  bool operator ==(country) => country is Country && country.id == id;

  @override
  int get hashCode => id.hashCode;

  static const String NAME_KEY = "name";
  static const String ISO_KEY = "iso";
  static const String HIDDEN_KEY = "hidden";
  static const String CURRENCIES_KEY = "currencies";
  static const String VAT_OPTIONS_KEY = "vat_options";
}
