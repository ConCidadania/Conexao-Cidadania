class UserId {
  final String value;

  const UserId._(this.value);

  factory UserId.fromString(String value) {
    if (value.isEmpty) {
      throw InvalidUserIdFailure('User ID cannot be empty');
    }
    return UserId._(value);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserId && runtimeType == other.runtimeType && value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;
}

class InvalidUserIdFailure implements Exception {
  final String message;
  InvalidUserIdFailure(this.message);
}
