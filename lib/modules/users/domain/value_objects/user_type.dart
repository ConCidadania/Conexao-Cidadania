enum UserType {
  user('USER', 'Usuário'),
  admin('ADMIN', 'Administrador'),
  lawyer('LAWYER', 'Advogado');

  const UserType(this.code, this.displayName);
  final String code;
  final String displayName;

  static UserType fromString(String value) {
    switch (value.toUpperCase()) {
      case 'USER':
        return UserType.user;
      case 'ADMIN':
        return UserType.admin;
      case 'LAWYER':
        return UserType.lawyer;
      default:
        throw InvalidUserTypeFailure('Invalid user type: $value');
    }
  }
}

class InvalidUserTypeFailure implements Exception {
  final String message;
  InvalidUserTypeFailure(this.message);
}
