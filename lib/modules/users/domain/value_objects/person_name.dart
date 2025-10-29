class PersonName {
  final String firstName;
  final String lastName;

  const PersonName._(this.firstName, this.lastName);

  factory PersonName.create(String firstName, String lastName) {
    final trimmedFirst = firstName.trim();
    final trimmedLast = lastName.trim();

    if (trimmedFirst.isEmpty) {
      throw InvalidPersonNameFailure('First name cannot be empty');
    }
    if (trimmedLast.isEmpty) {
      throw InvalidPersonNameFailure('Last name cannot be empty');
    }

    return PersonName._(trimmedFirst, trimmedLast);
  }

  String get fullName => '$firstName $lastName';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PersonName &&
          runtimeType == other.runtimeType &&
          firstName == other.firstName &&
          lastName == other.lastName;

  @override
  int get hashCode => firstName.hashCode ^ lastName.hashCode;

  @override
  String toString() => fullName;
}

class InvalidPersonNameFailure implements Exception {
  final String message;
  InvalidPersonNameFailure(this.message);
}
