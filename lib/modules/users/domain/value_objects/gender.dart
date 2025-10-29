enum Gender {
  male('Masculino'),
  female('Feminino'),
  other('Outro'),
  notInformed('Prefiro não informar');

  const Gender(this.displayName);
  final String displayName;

  static Gender fromString(String value) {
    switch (value.toLowerCase()) {
      case 'masculino':
      case 'male':
      case 'm':
        return Gender.male;
      case 'feminino':
      case 'female':
      case 'f':
        return Gender.female;
      case 'outro':
      case 'other':
      case 'o':
        return Gender.other;
      case 'prefiro não informar':
      case 'prefiro nao informar':
      case 'not informed':
      case 'n/a':
        return Gender.notInformed;
      default:
        throw InvalidGenderFailure('Invalid gender: $value');
    }
  }
}

class InvalidGenderFailure implements Exception {
  final String message;
  InvalidGenderFailure(this.message);
}
