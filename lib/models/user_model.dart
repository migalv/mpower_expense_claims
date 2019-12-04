class User {
  final String id, name, profilePictureUrl, userName;
  final bool blocked;
  Map<String, String> tokens;
  User({
    this.id,
    this.name,
    this.profilePictureUrl,
    this.blocked,
    this.userName,
    this.tokens,
  });

  User.fromJson(Map<String, dynamic> json, {String id})
      : this.id = id,
        this.name = json[NAME_KEY],
        this.profilePictureUrl = json[PROFILE_PICTURE_URL_KEY],
        this.blocked = json[BLOCKED_KEY] ?? false,
        this.userName = json[USER_NAME_KEY],
        this.tokens = json.containsKey(TOKENS_KEY) ? json[TOKENS_KEY] : null;

  Map<String, dynamic> toJson() => {
        NAME_KEY: name,
        BLOCKED_KEY: blocked,
        USER_NAME_KEY: userName,
        TOKENS_KEY: tokens,
      };

  @override
  bool operator ==(user) => user is User && user.id == id;

  @override
  int get hashCode => id.hashCode;

  static const String NAME_KEY = "name";
  static const String PROFILE_PICTURE_URL_KEY = "profile_picture_url";
  static const String BLOCKED_KEY = "blocked";
  static const String USER_NAME_KEY = "user_name";
  static const String TOKENS_KEY = "tokens";
}
