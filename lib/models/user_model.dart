class User {
  final String id, name, profilePictureUrl;
  final bool locked;
  User({
    this.id,
    this.name,
    this.profilePictureUrl,
    this.locked,
  });

  User.fromJson(Map<String, dynamic> json, {String id})
      : this.id = id,
        this.name = json[NAME_KEY],
        this.profilePictureUrl = json[PROFILE_PICTURE_URL_KEY],
        this.locked = json[LOCKED_KEY] ?? false;

  @override
  bool operator ==(user) => user is User && user.id == id;

  @override
  int get hashCode => id.hashCode;

  static const String NAME_KEY = "name";
  static const String PROFILE_PICTURE_URL_KEY = "profile_picture_url";
  static const String LOCKED_KEY = "locked";
}
