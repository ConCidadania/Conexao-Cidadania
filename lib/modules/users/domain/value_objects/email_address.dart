class EmailAddress {
  final String value;

  const EmailAddress._(this.value);

  factory EmailAddress.parse(String input) {
    final email = input.trim().toLowerCase();
    
    if (email.isEmpty) {
      throw InvalidEmailFailure('Email cannot be empty');
    }

    // Basic RFC5322-ish validation
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(email)) {
      throw InvalidEmailFailure('Invalid email format');
    }

    return EmailAddress._(email);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EmailAddress && runtimeType == other.runtimeType && value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;
}

class InvalidEmailFailure implements Exception {
  final String message;
  InvalidEmailFailure(this.message);
}
