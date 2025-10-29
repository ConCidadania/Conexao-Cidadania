class Oab {
  final String value;

  const Oab._(this.value);

  factory Oab.parse(String input) {
    final cleaned = input.trim();
    
    if (cleaned.isEmpty) {
      throw InvalidOabFailure('OAB registration cannot be empty');
    }

    // OAB format: typically 6-8 digits, sometimes with state prefix
    if (cleaned.length < 4 || cleaned.length > 10) {
      throw InvalidOabFailure('OAB registration must have between 4 and 10 characters');
    }

    // Should contain only alphanumeric characters
    if (!RegExp(r'^[A-Za-z0-9]+$').hasMatch(cleaned)) {
      throw InvalidOabFailure('OAB registration must contain only alphanumeric characters');
    }

    return Oab._(cleaned.toUpperCase());
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Oab && runtimeType == other.runtimeType && value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;
}

class InvalidOabFailure implements Exception {
  final String message;
  InvalidOabFailure(this.message);
}
