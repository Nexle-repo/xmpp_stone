import '../models/TestUser.dart';

class Preferences {
  Preferences._();

  static const String hostName = 'localhost';
  static const AuthJwtType authJwtType = AuthJwtType.secret;
  static const String secret = "secret";
  static const String jwtKeyPath = '/example/jwt_key/jwt_key.jwk';
}
