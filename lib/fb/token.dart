class Token {
  final String access;
  final String type;
  final num expiresIn;
  Token(this.access, this.type, this.expiresIn);
  Token.fromMap(Map<String, dynamic> json)
    : access = json['access_token'],
      type = json['token_type'],
      expiresIn = json['expires_in'];
}