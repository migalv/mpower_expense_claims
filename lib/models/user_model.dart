class User {
  final String id;
  final String name;

  User({
    this.id,
    this.name,
  });

  User.fromJson(Map<String, dynamic> json, {String id})
      : this.id = id,
        this.name = json[NAME_KEY];

  @override
  bool operator ==(user) => user is User && user.id == id;

  @override
  int get hashCode => id.hashCode;

  static const String NAME_KEY = "name";
}
